package com.nearsentry.sentry

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.core.content.ContextCompat
import java.time.Instant
import java.util.concurrent.atomic.AtomicReference

class SentryRuntime private constructor(
    private val context: Context,
) {
    private val repository = SentryRepository(context)
    private val prerequisites = PrerequisiteChecker(context)
    private val alarmController = AlarmController(context)
    private val engine = NativeProtectionEngine()
    private val handler = Handler(Looper.getMainLooper())
    private val garminMonitor = GarminAnchorMonitor(context)
    private val eventSink = AtomicReference<((Map<String, Any?>) -> Unit)?>(null)

    @Volatile
    private var serviceHealthy = false
    private var runtimeGeneration = repository.runtimeGeneration()
    private var lastAnchorStatus = "unknown"
    private var lastMessage = "Protection is off"
    private var graceRunnable: Runnable? = null
    private var countdownRunnable: Runnable? = null

    init {
        engine.setGraceMs(repository.settings().graceSeconds * 1000L)
        engine.restoreAsDegradedIfArmed(repository.armedIntended())
        if (repository.armedIntended()) {
            lastMessage = "Protection runtime requires revalidation after process restart"
        }
    }

    fun setEventSink(sink: ((Map<String, Any?>) -> Unit)?) {
        eventSink.set(sink)
    }

    fun settings(): Map<String, Any?> {
        val value = repository.settings()
        return mapOf(
            "onboardingComplete" to value.onboardingComplete,
            "graceSeconds" to value.graceSeconds,
            "soundEnabled" to value.soundEnabled,
            "vibrationEnabled" to value.vibrationEnabled,
            "telemetryRetention" to value.telemetryRetention,
            "simulationMode" to value.simulationMode,
        )
    }

    fun updateSettings(values: Map<String, Any?>) {
        val current = repository.settings()
        val updated = SentrySettings(
            onboardingComplete =
                values["onboardingComplete"] as? Boolean ?: current.onboardingComplete,
            graceSeconds =
                (values["graceSeconds"] as? Number)?.toInt() ?: current.graceSeconds,
            soundEnabled = values["soundEnabled"] as? Boolean ?: current.soundEnabled,
            vibrationEnabled =
                values["vibrationEnabled"] as? Boolean ?: current.vibrationEnabled,
            telemetryRetention =
                (values["telemetryRetention"] as? Number)?.toInt()
                    ?: current.telemetryRetention,
            simulationMode =
                values["simulationMode"] as? Boolean ?: current.simulationMode,
        )
        val simulationChanged = current.simulationMode != updated.simulationMode
        repository.saveSettings(updated)
        engine.setGraceMs(updated.graceSeconds * 1000L)
        if (simulationChanged && repository.armedIntended()) {
            degrade("monitor_mode_changed_rearm_required", "settings")
        }
        publishSnapshot()
    }

    fun availableAnchors(): List<Map<String, Any?>> {
        val settings = repository.settings()
        if (settings.simulationMode) {
            return listOf(
                mapOf(
                    "id" to "simulator",
                    "name" to "NearSentry Simulator",
                    "status" to "present",
                ),
            )
        }
        return garminMonitor.availableAnchors().map {
            mapOf("id" to it.id, "name" to it.name, "status" to it.status)
        }
    }

    fun enrollAnchor(id: String) {
        require(id.isNotBlank()) { "Anchor id is required" }
        val descriptor = availableAnchors().firstOrNull { it["id"] == id }
            ?: throw IllegalStateException("Selected anchor is not currently available")
        repository.saveAnchor(id, descriptor["name"].toString())
        lastMessage = "Trusted device configured"
        publishSnapshot()
    }

    fun arm() {
        if (!prerequisites.requiredReady()) {
            throw IllegalStateException("Required Android prerequisites are not satisfied")
        }
        if (repository.anchorId().isNullOrBlank()) {
            throw IllegalStateException("A trusted anchor must be enrolled before arming")
        }
        if (engine.state == NativeProtectionState.ALARM) {
            throw IllegalStateException("Authenticate to dismiss the active alarm first")
        }

        repository.setArmedIntended(true)
        transition(
            NativeEngineEvent(
                NativeEventType.ARM,
                SystemClock.elapsedRealtime(),
            ),
            trigger = "arm",
            source = "user",
        )
        ContextCompat.startForegroundService(
            context,
            Intent(context, SentryService::class.java),
        )
    }

    fun disarm(source: String) {
        if (engine.state == NativeProtectionState.ALARM) {
            throw IllegalStateException("Active alarms require authenticated dismissal")
        }
        transition(
            NativeEngineEvent(
                NativeEventType.DISARM,
                SystemClock.elapsedRealtime(),
            ),
            trigger = "disarm",
            source = source,
        )
        repository.setArmedIntended(false)
        stopGraceTimer()
        garminMonitor.stop()
        alarmController.stop()
        context.stopService(Intent(context, SentryService::class.java))
        lastMessage = "Protection is off"
        publishSnapshot()
    }

    fun authenticatedDismissal() {
        if (engine.state != NativeProtectionState.ALARM) return
        transition(
            NativeEngineEvent(
                NativeEventType.AUTHENTICATED_DISMISSAL,
                SystemClock.elapsedRealtime(),
            ),
            trigger = "authenticated_dismissal",
            source = "android_authentication",
        )
        repository.setArmedIntended(false)
        alarmController.stop()
        garminMonitor.stop()
        context.stopService(Intent(context, SentryService::class.java))
        lastMessage = "Alarm dismissed after authentication"
        publishSnapshot()
    }

    fun onServiceStarted() {
        runtimeGeneration = repository.nextRuntimeGeneration()
        serviceHealthy = true
        if (repository.armedIntended() &&
            engine.state == NativeProtectionState.DEGRADED
        ) {
            transition(
                NativeEngineEvent(
                    NativeEventType.RUNTIME_RECOVERED,
                    SystemClock.elapsedRealtime(),
                    "service_started",
                ),
                trigger = "runtime_recovered",
                source = "android_service",
            )
        }
        publishSnapshot()
    }

    fun startMonitoringIfArmed() {
        if (!repository.armedIntended()) return
        if (!prerequisites.requiredReady()) {
            degrade("required_prerequisite_lost", "android")
            return
        }

        val id = repository.anchorId()
        if (repository.settings().simulationMode) {
            handleObservation(
                AnchorObservation(
                    anchorId = id ?: "simulator",
                    monotonicTimestampMs = SystemClock.elapsedRealtime(),
                    status = AnchorStatus.PRESENT,
                    source = "developer_simulator",
                    confidence = "simulated",
                    diagnosticReason = "simulation_monitor_started",
                ),
            )
            return
        }

        garminMonitor.start(id) { observation ->
            handler.post { handleObservation(observation) }
        }
    }

    fun onServiceStopped() {
        serviceHealthy = false
        if (repository.armedIntended()) {
            degrade("foreground_service_stopped", "android_service")
        }
        publishSnapshot()
    }

    fun simulate(action: String) {
        if (!repository.settings().simulationMode) {
            throw IllegalStateException("Developer simulation mode is disabled")
        }
        val id = repository.anchorId() ?: "simulator"
        when (action) {
            "connected", "recovery" -> handleObservation(
                simulated(id, AnchorStatus.PRESENT, action),
            )
            "disconnected" -> handleObservation(
                simulated(id, AnchorStatus.ABSENT, action),
            )
            "transientDisconnect" -> {
                handleObservation(simulated(id, AnchorStatus.ABSENT, action))
                handler.postDelayed(
                    { handleObservation(simulated(id, AnchorStatus.PRESENT, "auto_recovery")) },
                    1_000,
                )
            }
            "degraded" -> degrade("simulated_monitor_degraded", "developer_simulator")
            "alarm" -> {
                if (engine.state == NativeProtectionState.PROTECTED) {
                    handleObservation(simulated(id, AnchorStatus.ABSENT, action))
                }
                val deadline = engine.graceDeadlineMs ?: SystemClock.elapsedRealtime()
                handler.post {
                    transition(
                        NativeEngineEvent(NativeEventType.GRACE_EXPIRED, deadline),
                        "simulated_grace_expiry",
                        "developer_simulator",
                    )
                }
            }
            "serviceRestart" -> {
                degrade("simulated_service_restart", "developer_simulator")
                transition(
                    NativeEngineEvent(
                        NativeEventType.RUNTIME_RECOVERED,
                        SystemClock.elapsedRealtime(),
                    ),
                    "simulated_runtime_recovery",
                    "developer_simulator",
                )
                handleObservation(simulated(id, AnchorStatus.PRESENT, "service_restart"))
            }
            else -> throw IllegalArgumentException("Unknown simulation action: $action")
        }
    }

    fun telemetry(): List<Map<String, Any?>> = repository.telemetry()

    fun snapshot(): Map<String, Any?> {
        val deadline = engine.graceDeadlineMs
        val remaining = deadline?.let {
            (it - SystemClock.elapsedRealtime()).coerceAtLeast(0)
        }
        return mapOf(
            "state" to engine.state.name.lowercase(),
            "serviceHealthy" to serviceHealthy,
            "anchorName" to repository.anchorName(),
            "anchorStatus" to lastAnchorStatus,
            "simulationMode" to repository.settings().simulationMode,
            "runtimeGeneration" to runtimeGeneration,
            "message" to lastMessage,
            "graceRemainingMs" to remaining,
            "prerequisites" to prerequisites.snapshot(),
        )
    }

    fun publishSnapshot() {
        eventSink.get()?.invoke(
            mapOf(
                "type" to "snapshot",
                "payload" to snapshot(),
            ),
        )
    }

    private fun handleObservation(observation: AnchorObservation) {
        lastAnchorStatus = observation.status.name.lowercase()

        when (observation.status) {
            AnchorStatus.PRESENT -> {
                if (engine.state == NativeProtectionState.DEGRADED) {
                    transition(
                        NativeEngineEvent(
                            NativeEventType.RUNTIME_RECOVERED,
                            observation.monotonicTimestampMs,
                        ),
                        "anchor_monitor_recovered",
                        observation.source,
                        observation,
                    )
                }
                transition(
                    NativeEngineEvent(
                        NativeEventType.ANCHOR_PRESENT,
                        observation.monotonicTimestampMs,
                    ),
                    "anchor_present",
                    observation.source,
                    observation,
                )
            }

            AnchorStatus.ABSENT -> transition(
                NativeEngineEvent(
                    NativeEventType.ANCHOR_ABSENT,
                    observation.monotonicTimestampMs,
                ),
                "anchor_absent",
                observation.source,
                observation,
            )

            AnchorStatus.UNKNOWN ->
                degrade(observation.diagnosticReason, observation.source, observation)
        }
    }

    private fun degrade(
        reason: String,
        source: String,
        observation: AnchorObservation? = null,
    ) {
        transition(
            NativeEngineEvent(
                NativeEventType.DEGRADED,
                SystemClock.elapsedRealtime(),
                reason,
            ),
            "runtime_degraded",
            source,
            observation,
        )
    }

    private fun transition(
        event: NativeEngineEvent,
        trigger: String,
        source: String,
        observation: AnchorObservation? = null,
    ) {
        val result = engine.apply(event)
        if (!result.accepted) {
            publishSnapshot()
            return
        }

        lastMessage = when (result.current) {
            NativeProtectionState.DISARMED -> "Protection is off"
            NativeProtectionState.ARMING -> "Validating trusted device presence…"
            NativeProtectionState.PROTECTED -> "Monitoring is healthy"
            NativeProtectionState.GRACE -> "Trusted device connection was lost"
            NativeProtectionState.ALARM -> "Separation alarm is active"
            NativeProtectionState.DEGRADED ->
                "Monitoring cannot currently produce a trustworthy signal"
        }

        repository.appendTelemetry(
            TelemetryRecord(
                wallTimestamp = Instant.now().toString(),
                monotonicMs = event.monotonicMs,
                previousState = result.previous.name.lowercase(),
                nextState = result.current.name.lowercase(),
                trigger = trigger,
                source = source,
                detail = observation?.diagnosticReason ?: result.reason,
                anchorId = observation?.anchorId ?: repository.anchorId(),
                rssi = observation?.rssi,
                confidence = observation?.confidence,
                runtimeGeneration = runtimeGeneration,
            ),
        )
        eventSink.get()?.invoke(
            mapOf(
                "type" to "telemetry",
                "payload" to repository.telemetry().firstOrNull(),
            ),
        )

        if (result.current == NativeProtectionState.DISARMED &&
            result.reason == "anchor_not_present_at_arm"
        ) {
            repository.setArmedIntended(false)
            garminMonitor.stop()
            handler.post { context.stopService(Intent(context, SentryService::class.java)) }
        }

        when (result.current) {
            NativeProtectionState.GRACE -> scheduleGraceDeadline()
            NativeProtectionState.ALARM -> {
                stopGraceTimer()
                alarmController.start(repository.settings())
            }
            else -> {
                if (result.previous == NativeProtectionState.GRACE) {
                    stopGraceTimer()
                }
                if (result.previous == NativeProtectionState.ALARM &&
                    result.current != NativeProtectionState.ALARM
                ) {
                    alarmController.stop()
                }
            }
        }
        publishSnapshot()
    }

    private fun scheduleGraceDeadline() {
        stopGraceTimer()
        val deadline = engine.graceDeadlineMs ?: return

        graceRunnable = Runnable {
            transition(
                NativeEngineEvent(
                    NativeEventType.GRACE_EXPIRED,
                    SystemClock.elapsedRealtime(),
                ),
                "grace_expired",
                "monotonic_timer",
            )
        }.also {
            handler.postAtTime(it, deadline)
        }

        countdownRunnable = object : Runnable {
            override fun run() {
                if (engine.state != NativeProtectionState.GRACE) return
                publishSnapshot()
                handler.postDelayed(this, 200)
            }
        }.also { handler.post(it) }
    }

    private fun stopGraceTimer() {
        graceRunnable?.let(handler::removeCallbacks)
        countdownRunnable?.let(handler::removeCallbacks)
        graceRunnable = null
        countdownRunnable = null
    }

    private fun simulated(
        id: String,
        status: AnchorStatus,
        reason: String,
    ) = AnchorObservation(
        anchorId = id,
        monotonicTimestampMs = SystemClock.elapsedRealtime(),
        status = status,
        source = "developer_simulator",
        confidence = "simulated",
        diagnosticReason = reason,
    )

    companion object {
        @Volatile
        private var instance: SentryRuntime? = null

        fun get(context: Context): SentryRuntime {
            return instance ?: synchronized(this) {
                instance ?: SentryRuntime(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }
}
