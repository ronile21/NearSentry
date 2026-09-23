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
    private val appContext = context.applicationContext
    private val connectIQ =
        ConnectIQ.getInstance(
            appContext,
            ConnectIQ.IQConnectType.WIRELESS,
        )

    @Volatile
    private var ready = false

    @Volatile
    private var initializing = false

    @Volatile
    private var inboundListener: ((Map<String, Any?>) -> Unit)? = null

    @Volatile
    private var traceListener: ((String) -> Unit)? = null

    private data class PendingSend(
        val anchorId: String?,
        val command: String,
        val graceMs: Int,
        val reason: String,
        val requestOpen: Boolean,
        val callback: (String) -> Unit,
    )

    private val pending = ArrayDeque<PendingSend>()

    private val sdkListener =
        object : ConnectIQ.ConnectIQListener {
            override fun onInitializeError(errStatus: ConnectIQ.IQSdkErrorStatus) {
                ready = false
                initializing = false
                trace("sdk:error:${errStatus.name.lowercase()}")
                failPending("watch:sdk_initialize_error:${errStatus.name.lowercase()}")
            }

            override fun onSdkReady() {
                ready = true
                initializing = false
                trace("sdk:ready")
                drainPending()
            }

            override fun onSdkShutDown() {
                ready = false
                initializing = false
                trace("sdk:shutdown")
            }
        }

    init {
        ensureInitialized()
    }

    fun setInboundListener(listener: ((Map<String, Any?>) -> Unit)?) {
        inboundListener = listener
    }

    fun setTraceListener(listener: ((String) -> Unit)?) {
        traceListener = listener
    }

    fun send(
        anchorId: String?,
        command: String,
        graceMs: Int,
        reason: String,
        requestOpen: Boolean,
        callback: (String) -> Unit,
    ) {
        val request =
            PendingSend(
                anchorId = anchorId,
                command = command,
                graceMs = graceMs,
                reason = reason,
                requestOpen = requestOpen,
                callback = callback,
            )

        if (!ready) {
            synchronized(pending) {
                pending.clear()
                pending.addLast(request)
            }
            trace("send:$command:waiting_for_sdk")
            ensureInitialized()
            return
        }

        sendReady(request)
    }

    private fun ensureInitialized() {
        if (ready || initializing) return

        initializing = true
        trace("sdk:initializing")
        try {
            connectIQ.initialize(appContext, true, sdkListener)
        } catch (error: Exception) {
            ready = false
            initializing = false
            trace("sdk:initialize_exception:${error.javaClass.simpleName}")
            failPending("watch:sdk_initialize_failed:${error.javaClass.simpleName}")
        }
    }

    private fun drainPending() {
        val requests =
            synchronized(pending) {
                buildList {
                    while (pending.isNotEmpty()) {
                        add(pending.removeFirst())
                    }
                }
            }
        requests.forEach(::sendReady)
    }

    private fun failPending(status: String) {
        val requests =
            synchronized(pending) {
                buildList {
                    while (pending.isNotEmpty()) {
                        add(pending.removeFirst())
                    }
                }
            }
        requests.forEach { it.callback(status) }
    }

    private fun sendReady(request: PendingSend) {
        val anchorId = request.anchorId
        if (anchorId.isNullOrBlank()) {
            trace("device:no_anchor")
            request.callback("watch:no_anchor")
            return
        }

        val devices =
            try {
                connectIQ.knownDevices ?: emptyList()
            } catch (_: InvalidStateException) {
                ready = false
                trace("device:sdk_not_ready")
                request.callback("watch:sdk_not_ready")
                ensureInitialized()
                return
            } catch (_: ServiceUnavailableException) {
                trace("device:garmin_connect_unavailable")
                request.callback("watch:garmin_connect_unavailable")
                return
            }

        trace(
            "device:known=" +
                devices.joinToString(",") {
                    "${it.friendlyName}:${it.deviceIdentifier}"
                },
        )

        val device =
            devices.firstOrNull {
                it.deviceIdentifier.toString() == anchorId
            }

        if (device == null) {
            trace("device:not_found:$anchorId")
            request.callback("watch:device_not_exposed")
            return
        }

        val status =
            try {
                connectIQ.getDeviceStatus(device)
            } catch (error: Exception) {
                trace("device:status_error:${error.javaClass.simpleName}")
                IQDevice.IQDeviceStatus.UNKNOWN
            }

        trace("device:found:${device.friendlyName}:${status.name.lowercase()}")

        if (status != IQDevice.IQDeviceStatus.CONNECTED) {
            request.callback("watch:device_${status.name.lowercase()}")
            return
        }

        try {
            trace("app:probing")
            connectIQ.getApplicationInfo(
                WATCH_APP_ID,
                device,
                object : ConnectIQ.IQApplicationInfoListener {
                    override fun onApplicationInfoReceived(app: IQApp) {
                        trace("app:found")
                        registerInbound(device, app)
                        sendInstalled(device, app, request)
                    }

                    override fun onApplicationNotInstalled(applicationId: String) {
                        trace("app:not_installed:$applicationId")
                        request.callback("watch:not_installed")
                    }
                },
            )
        } catch (_: InvalidStateException) {
            ready = false
            trace("app:sdk_not_ready")
            request.callback("watch:sdk_not_ready")
            ensureInitialized()
        } catch (_: ServiceUnavailableException) {
            trace("app:garmin_connect_unavailable")
            request.callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to inspect NearSentry watch app", error)
            trace("app:probe_failed:${error.javaClass.simpleName}")
            request.callback("watch:probe_failed:${error.javaClass.simpleName}")
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
            trace("inbound:registered")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to register for NearSentry watch app events", error)
            trace("inbound:register_failed:${error.javaClass.simpleName}")
        }
    }

    private fun sendInstalled(
        device: IQDevice,
        app: IQApp,
        request: PendingSend,
    ) {
        val payload =
            mapOf<String, Any>(
                "protocol" to PROTOCOL_VERSION,
                "command" to request.command,
                "graceMs" to request.graceMs,
                "reason" to request.reason,
            )

        try {
            trace("send:${request.command}:dispatch")
            connectIQ.sendMessage(device, app, payload) { _, _, status ->
                val result = "watch:message_${status.name.lowercase()}"
                trace("send:${request.command}:${status.name.lowercase()}")
                Log.i(TAG, "${request.command} -> $result")
                request.callback(result)

                if (request.requestOpen) {
                    requestOpen(device, app)
                }
            }
        } catch (_: InvalidStateException) {
            ready = false
            trace("send:${request.command}:sdk_not_ready")
            request.callback("watch:sdk_not_ready")
            ensureInitialized()
        } catch (_: ServiceUnavailableException) {
            trace("send:${request.command}:garmin_connect_unavailable")
            request.callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to send ${request.command} to NearSentry watch app", error)
            trace("send:${request.command}:failed:${error.javaClass.simpleName}")
            request.callback("watch:send_failed:${error.javaClass.simpleName}")
        }
    }

    private fun requestOpen(device: IQDevice, app: IQApp) {
        try {
            connectIQ.openApplication(device, app) { _, _, status ->
                trace("open:${status.name.lowercase()}")
                Log.i(TAG, "Watch open request: ${status.name.lowercase()}")
            }
        } catch (error: Exception) {
            trace("open:failed:${error.javaClass.simpleName}")
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
