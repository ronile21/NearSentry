package com.nearsentry.sentry

import android.content.Context
import android.os.SystemClock
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException

class GarminAnchorMonitor(
    context: Context,
) : AnchorMonitor {
    private val appContext = context.applicationContext
    private val connectIQ =
        ConnectIQ.getInstance(appContext, ConnectIQ.IQConnectType.WIRELESS)

    @Volatile
    private var ready = false
    private var listener: ((AnchorObservation) -> Unit)? = null
    private var enrolledAnchorId: String? = null
    private val devices = linkedMapOf<Long, IQDevice>()

    private val sdkListener = object : ConnectIQ.ConnectIQListener {
        override fun onSdkReady() {
            ready = true
            refreshDevices(registerEvents = true)
        }

        override fun onInitializeError(errStatus: ConnectIQ.IQSdkErrorStatus) {
            ready = false
            publishUnknown("connectiq_initialize_error:${errStatus.name}")
        }

        override fun onSdkShutDown() {
            ready = false
            publishUnknown("connectiq_sdk_shutdown")
        }
    }

    init {
        connectIQ.initialize(appContext, true, sdkListener)
    }

    override fun start(
        enrolledAnchorId: String?,
        listener: (AnchorObservation) -> Unit,
    ) {
        this.enrolledAnchorId = enrolledAnchorId
        this.listener = listener
        if (ready) {
            refreshDevices(registerEvents = true)
            publishCurrentStatus()
        } else {
            publishUnknown("connectiq_initializing")
        }
    }

    override fun stop() {
        listener = null

        // Do not unregister application-message listeners owned by
        // GarminWatchMessenger. Only remove this monitor's device callbacks.
        devices.values.forEach { device ->
            try {
                connectIQ.unregisterForDeviceEvents(device)
            } catch (_: Exception) {
            }
        }
    }

    override fun availableAnchors(): List<AnchorDescriptor> {
        if (ready) refreshDevices(registerEvents = false)
        return devices.values.map { device ->
            val status = safeStatus(device)
            AnchorDescriptor(
                id = device.deviceIdentifier.toString(),
                name = device.friendlyName,
                status = status.name.lowercase(),
            )
        }
    }

    private fun refreshDevices(registerEvents: Boolean) {
        val known = try {
            connectIQ.knownDevices ?: emptyList()
        } catch (_: InvalidStateException) {
            emptyList()
        } catch (_: ServiceUnavailableException) {
            publishUnknown("connectiq_service_unavailable")
            emptyList()
        }

        devices.clear()
        known.forEach { device ->
            device.status = try {
                connectIQ.getDeviceStatus(device)
            } catch (_: Exception) {
                IQDevice.IQDeviceStatus.UNKNOWN
            }
            devices[device.deviceIdentifier] = device
            if (registerEvents) {
                try {
                    connectIQ.unregisterForDeviceEvents(device)
                    connectIQ.registerForDeviceEvents(device) { changed, status ->
                        changed.status = status
                        devices[changed.deviceIdentifier] = changed
                        if (changed.deviceIdentifier.toString() == enrolledAnchorId) {
                            publish(changed, status)
                        }
                    }
                } catch (_: InvalidStateException) {
                    publishUnknown("connectiq_device_event_registration_failed")
                }
            }
        }
    }

    private fun publishCurrentStatus() {
        val id = enrolledAnchorId ?: return
        val device = devices.values.firstOrNull {
            it.deviceIdentifier.toString() == id
        }
        if (device == null) {
            listener?.invoke(
                AnchorObservation(
                    anchorId = id,
                    monotonicTimestampMs = SystemClock.elapsedRealtime(),
                    status = AnchorStatus.UNKNOWN,
                    source = SOURCE,
                    confidence = "low",
                    diagnosticReason = "enrolled_device_not_exposed_by_connectiq",
                ),
            )
            return
        }
        publish(device, device.status ?: IQDevice.IQDeviceStatus.UNKNOWN)
    }

    private fun publish(device: IQDevice, status: IQDevice.IQDeviceStatus) {
        val normalized = when (status.name) {
            "CONNECTED" -> AnchorStatus.PRESENT
            "NOT_CONNECTED", "NOT_PAIRED" -> AnchorStatus.ABSENT
            else -> AnchorStatus.UNKNOWN
        }
        listener?.invoke(
            AnchorObservation(
                anchorId = device.deviceIdentifier.toString(),
                monotonicTimestampMs = SystemClock.elapsedRealtime(),
                status = normalized,
                source = SOURCE,
                confidence = if (normalized == AnchorStatus.UNKNOWN) "low" else "high",
                diagnosticReason = "connectiq_device_status:${status.name.lowercase()}",
            ),
        )
    }

    private fun safeStatus(device: IQDevice): AnchorStatus {
        val status = device.status ?: return AnchorStatus.UNKNOWN
        return when (status.name) {
            "CONNECTED" -> AnchorStatus.PRESENT
            "NOT_CONNECTED", "NOT_PAIRED" -> AnchorStatus.ABSENT
            else -> AnchorStatus.UNKNOWN
        }
    }

    private fun publishUnknown(reason: String) {
        val id = enrolledAnchorId ?: return
        listener?.invoke(
            AnchorObservation(
                anchorId = id,
                monotonicTimestampMs = SystemClock.elapsedRealtime(),
                status = AnchorStatus.UNKNOWN,
                source = SOURCE,
                confidence = "low",
                diagnosticReason = reason,
            ),
        )
    }

    companion object {
        const val SOURCE = "garmin_connectiq_mobile_sdk"
    }
}
