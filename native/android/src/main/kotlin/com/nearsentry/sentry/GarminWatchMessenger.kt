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

    fun send(
        anchorId: String?,
        command: String,
        graceMs: Int,
        reason: String,
        requestOpen: Boolean,
        callback: (String) -> Unit,
    ) {
        if (anchorId.isNullOrBlank()) {
            callback("watch:no_anchor")
            return
        }

        val device = try {
            (connectIQ.knownDevices ?: emptyList()).firstOrNull {
                it.deviceIdentifier.toString() == anchorId
            }
        } catch (_: InvalidStateException) {
            callback("watch:sdk_not_ready")
            return
        } catch (_: ServiceUnavailableException) {
            callback("watch:garmin_connect_unavailable")
            return
        }

        if (device == null) {
            callback("watch:device_not_exposed")
            return
        }

        val status = try {
            connectIQ.getDeviceStatus(device)
        } catch (_: Exception) {
            IQDevice.IQDeviceStatus.UNKNOWN
        }

        if (status != IQDevice.IQDeviceStatus.CONNECTED) {
            callback("watch:device_${status.name.lowercase()}")
            return
        }

        try {
            connectIQ.getApplicationInfo(
                WATCH_APP_ID,
                device,
                object : ConnectIQ.IQApplicationInfoListener {
                    override fun onApplicationInfoReceived(app: IQApp) {
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
                        callback("watch:not_installed")
                    }
                },
            )
        } catch (_: InvalidStateException) {
            callback("watch:sdk_not_ready")
        } catch (_: ServiceUnavailableException) {
            callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to inspect NearSentry watch app", error)
            callback("watch:probe_failed:${error.javaClass.simpleName}")
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
            "sentAt" to System.currentTimeMillis(),
        )

        try {
            connectIQ.sendMessage(device, app, payload) { _, _, status ->
                val result = "watch:message_${status.name.lowercase()}"
                Log.i(TAG, "$command -> $result")
                callback(result)

                if (requestOpen) {
                    requestOpen(device, app)
                }
            }
        } catch (_: InvalidStateException) {
            callback("watch:sdk_not_ready")
        } catch (_: ServiceUnavailableException) {
            callback("watch:garmin_connect_unavailable")
        } catch (error: Exception) {
            Log.e(TAG, "Unable to send $command to NearSentry watch app", error)
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

    companion object {
        const val WATCH_APP_ID = "d3bc778912b844e69b096a9e1a3e8b42"
        const val PROTOCOL_VERSION = 1
        private const val TAG = "NearSentryWatch"
    }
}
