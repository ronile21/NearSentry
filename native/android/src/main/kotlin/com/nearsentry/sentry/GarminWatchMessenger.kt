package com.nearsentry.sentry

import android.content.Context
import android.util.Log
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException

class GarminWatchMessenger(
    context: Context,
) {
    private val connectIQ =
        ConnectIQ.getInstance(
            context.applicationContext,
            ConnectIQ.IQConnectType.WIRELESS,
        )

    @Volatile
    private var inboundListener: ((Map<String, Any?>) -> Unit)? = null

    @Volatile
    private var traceListener: ((String) -> Unit)? = null

    fun setInboundListener(listener: ((Map<String, Any?>) -> Unit)?) {
        inboundListener = listener
    }

    fun setTraceListener(listener: ((String) -> Unit)?) {
        traceListener = listener
    }

    fun listen(
        anchorId: String?,
        callback: (String) -> Unit,
    ) {
        if (anchorId.isNullOrBlank()) {
            callback("watch:listen_no_anchor")
            return
        }

        val device = try {
            (connectIQ.knownDevices ?: emptyList()).firstOrNull {
                it.deviceIdentifier.toString() == anchorId
            }
        } catch (_: InvalidStateException) {
            callback("watch:listen_sdk_not_ready")
            return
        } catch (_: ServiceUnavailableException) {
            callback("watch:listen_garmin_connect_unavailable")
            return
        }

        if (device == null) {
            callback("watch:listen_device_not_exposed")
            return
        }

        try {
            connectIQ.getApplicationInfo(
                WATCH_APP_ID,
                device,
                object : ConnectIQ.IQApplicationInfoListener {
                    override fun onApplicationInfoReceived(app: IQApp) {
                        registerInbound(device, app)
                        callback("watch:listen_registered")
                    }

                    override fun onApplicationNotInstalled(applicationId: String) {
                        callback("watch:listen_not_installed")
                    }
                },
            )
        } catch (_: InvalidStateException) {
            callback("watch:listen_sdk_not_ready")
        } catch (_: ServiceUnavailableException) {
            callback("watch:listen_garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to register NearSentry watch listener", error)
            callback("watch:listen_failed:${error.javaClass.simpleName}")
        }
    }

    fun send(
        anchorId: String?,
        command: String,
        graceMs: Int,
        reason: String,
        requestOpen: Boolean,
        callback: (String) -> Unit,
    ) {
        trace("start:$command:anchor=${anchorId ?: "null"}")

        if (anchorId.isNullOrBlank()) {
            trace("no_anchor")
            callback("watch:no_anchor")
            return
        }

        val knownDevices = try {
            connectIQ.knownDevices ?: emptyList()
        } catch (_: InvalidStateException) {
            trace("sdk_not_ready")
            callback("watch:sdk_not_ready")
            return
        } catch (_: ServiceUnavailableException) {
            trace("garmin_connect_unavailable")
            callback("watch:garmin_connect_unavailable")
            return
        }

        val knownSummary = knownDevices.joinToString("|") {
            "${it.friendlyName}:${it.deviceIdentifier}"
        }.ifBlank { "none" }

        val device = knownDevices.firstOrNull {
            it.deviceIdentifier.toString() == anchorId
        }

        if (device == null) {
            trace("device_not_exposed:stored=$anchorId:known=$knownSummary")
            callback("watch:device_not_exposed")
            return
        }

        val status = try {
            connectIQ.getDeviceStatus(device)
        } catch (error: Exception) {
            trace("device_status_exception:${error.javaClass.simpleName}")
            IQDevice.IQDeviceStatus.UNKNOWN
        }

        trace("device:${device.friendlyName}:${device.deviceIdentifier}:${status.name.lowercase()}")

        if (status != IQDevice.IQDeviceStatus.CONNECTED) {
            trace("device_not_connected:${status.name.lowercase()}")
            callback("watch:device_${status.name.lowercase()}")
            return
        }

        try {
            trace("app_probe:$WATCH_APP_ID")
            connectIQ.getApplicationInfo(
                WATCH_APP_ID,
                device,
                object : ConnectIQ.IQApplicationInfoListener {
                    override fun onApplicationInfoReceived(app: IQApp) {
                        trace("app_found")
                        registerInbound(device, app)
                        sendInstalled(
                            device = device,
                            app = app,
                            command = command,
                            graceMs = graceMs,
                            reason = reason,
                            requestOpen = requestOpen,
                            callback = callback,
                        )
                    }

                    override fun onApplicationNotInstalled(applicationId: String) {
                        trace("app_not_installed:$applicationId")
                        callback("watch:not_installed")
                    }
                },
            )
        } catch (_: InvalidStateException) {
            trace("app_probe_sdk_not_ready")
            callback("watch:sdk_not_ready")
        } catch (_: ServiceUnavailableException) {
            trace("app_probe_garmin_connect_unavailable")
            callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to inspect NearSentry watch app", error)
            trace("app_probe_failed:${error.javaClass.simpleName}")
            callback("watch:probe_failed:${error.javaClass.simpleName}")
        }
    }

    private fun registerInbound(device: IQDevice, app: IQApp) {
        try {
            connectIQ.unregisterForApplicationEvents(device, app)
        } catch (_: Exception) {
        }

        try {
            connectIQ.registerForAppEvents(device, app) { _, _, message, status ->
                trace("inbound:${status.name.lowercase()}:count=${message.size}")
                Log.i(TAG, "Inbound app event status=${status.name} message=$message")
                if (message.isEmpty()) {
                    inboundListener?.invoke(
                        mapOf(
                            "type" to "EMPTY",
                            "status" to status.name.lowercase(),
                        ),
                    )
                    return@registerForAppEvents
                }

                message.forEach { item ->
                    @Suppress("UNCHECKED_CAST")
                    val parsed =
                        if (item is Map<*, *>) {
                            item.entries.associate { entry ->
                                entry.key.toString() to entry.value
                            }
                        } else {
                            mapOf(
                                "type" to "RAW",
                                "value" to item?.toString(),
                            )
                        }
                    inboundListener?.invoke(
                        parsed + ("transportStatus" to status.name.lowercase()),
                    )
                }
            }
            trace("inbound_registered")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to register for NearSentry watch app events", error)
            trace("inbound_register_failed:${error.javaClass.simpleName}")
        }
    }

    private fun sendInstalled(
        device: IQDevice,
        app: IQApp,
        command: String,
        graceMs: Int,
        reason: String,
        requestOpen: Boolean,
        callback: (String) -> Unit,
    ) {
        val payload = mapOf<String, Any>(
            "protocol" to PROTOCOL_VERSION,
            "command" to command,
            "graceMs" to graceMs,
            "reason" to reason,
        )

        try {
            trace("send_dispatch:$command")
            connectIQ.sendMessage(device, app, payload) { _, _, status ->
                val result = "watch:message_${status.name.lowercase()}"
                trace("send_result:$command:${status.name.lowercase()}")
                Log.i(TAG, "$command -> $result")
                callback(result)

                if (requestOpen) {
                    requestOpen(device, app)
                }
            }
        } catch (_: InvalidStateException) {
            trace("send_sdk_not_ready:$command")
            callback("watch:sdk_not_ready")
        } catch (_: ServiceUnavailableException) {
            trace("send_garmin_connect_unavailable:$command")
            callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to send $command to NearSentry watch app", error)
            trace("send_failed:$command:${error.javaClass.simpleName}")
            callback("watch:send_failed:${error.javaClass.simpleName}")
        }
    }

    private fun requestOpen(device: IQDevice, app: IQApp) {
        try {
            connectIQ.openApplication(device, app) { _, _, status ->
                Log.i(TAG, "Watch open request: ${status.name.lowercase()}")
            }
        } catch (error: Exception) {
            Log.w(TAG, "Unable to request NearSentry watch app open", error)
        }
    }

    private fun trace(value: String) {
        Log.i(TAG, value)
        traceListener?.invoke(value)
    }

    companion object {
        const val WATCH_APP_ID = "d3bc778912b844e69b096a9e1a3e8b42"
        const val PROTOCOL_VERSION = 1
        private const val TAG = "NearSentryWatch"
    }
}
