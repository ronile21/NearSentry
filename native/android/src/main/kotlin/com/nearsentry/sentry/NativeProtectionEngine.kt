package com.nearsentry.sentry

enum class NativeProtectionState {
    DISARMED,
    ARMING,
    PROTECTED,
    GRACE,
    ALARM,
    DEGRADED,
}

enum class NativeEventType {
    ARM,
    DISARM,
    ANCHOR_PRESENT,
    ANCHOR_ABSENT,
    GRACE_EXPIRED,
    DEGRADED,
    RUNTIME_RECOVERED,
    AUTHENTICATED_DISMISSAL,
    SERVICE_RESTARTED,
}

data class NativeEngineEvent(
    val type: NativeEventType,
    val monotonicMs: Long,
    val detail: String = "",
)

data class NativeTransition(
    val previous: NativeProtectionState,
    val current: NativeProtectionState,
    val reason: String,
    val graceDeadlineMs: Long?,
    val accepted: Boolean,
)

class NativeProtectionEngine(
    private var graceMs: Long = 3_000,
) {
    var state: NativeProtectionState = NativeProtectionState.DISARMED
        private set

    var graceDeadlineMs: Long? = null
        private set

    fun setGraceMs(value: Long) {
        graceMs = value.coerceIn(1_000, 15_000)
    }

    fun restoreAsDegradedIfArmed(armedIntended: Boolean) {
        state = if (armedIntended) {
            NativeProtectionState.DEGRADED
        } else {
            NativeProtectionState.DISARMED
        }
        graceDeadlineMs = null
    }

    fun apply(event: NativeEngineEvent): NativeTransition {
        val previous = state
        var next = previous
        var accepted = true
        var reason = "ignored:${event.type.name.lowercase()}"

        when (previous) {
            NativeProtectionState.DISARMED -> when (event.type) {
                NativeEventType.ARM -> {
                    next = NativeProtectionState.ARMING
                    reason = "arm_requested"
                }
                NativeEventType.DISARM -> reason = "already_disarmed"
                else -> accepted = false
            }

            NativeProtectionState.ARMING -> when (event.type) {
                NativeEventType.ANCHOR_PRESENT -> {
                    next = NativeProtectionState.PROTECTED
                    reason = "anchor_confirmed"
                }
                NativeEventType.ANCHOR_ABSENT -> {
                    next = NativeProtectionState.DISARMED
                    reason = "anchor_not_present_at_arm"
                }
                NativeEventType.DISARM -> {
                    next = NativeProtectionState.DISARMED
                    reason = "disarm_requested"
                }
                NativeEventType.DEGRADED, NativeEventType.SERVICE_RESTARTED -> {
                    next = NativeProtectionState.DEGRADED
                    reason = event.detail.ifBlank { "runtime_degraded" }
                }
                else -> accepted = false
            }

            NativeProtectionState.PROTECTED -> when (event.type) {
                NativeEventType.ANCHOR_ABSENT -> {
                    next = NativeProtectionState.GRACE
                    graceDeadlineMs = event.monotonicMs + graceMs
                    reason = "anchor_lost"
                }
                NativeEventType.DISARM -> {
                    next = NativeProtectionState.DISARMED
                    reason = "disarm_requested"
                }
                NativeEventType.DEGRADED, NativeEventType.SERVICE_RESTARTED -> {
                    next = NativeProtectionState.DEGRADED
                    reason = event.detail.ifBlank { "runtime_degraded" }
                }
                NativeEventType.ANCHOR_PRESENT -> reason = "anchor_still_present"
                else -> accepted = false
            }

            NativeProtectionState.GRACE -> when (event.type) {
                NativeEventType.ANCHOR_PRESENT -> {
                    next = NativeProtectionState.PROTECTED
                    reason = "anchor_recovered"
                }
                NativeEventType.GRACE_EXPIRED -> {
                    val deadline = graceDeadlineMs
                    if (deadline != null && event.monotonicMs >= deadline) {
                        next = NativeProtectionState.ALARM
                        reason = "grace_expired"
                    } else {
                        reason = "grace_not_expired"
                    }
                }
                NativeEventType.ANCHOR_ABSENT -> reason = "anchor_still_absent"
                NativeEventType.DISARM -> {
                    next = NativeProtectionState.DISARMED
                    reason = "disarm_requested"
                }
                NativeEventType.DEGRADED, NativeEventType.SERVICE_RESTARTED -> {
                    next = NativeProtectionState.DEGRADED
                    reason = event.detail.ifBlank { "runtime_degraded" }
                }
                else -> accepted = false
            }

            NativeProtectionState.ALARM -> when (event.type) {
                NativeEventType.AUTHENTICATED_DISMISSAL -> {
                    next = NativeProtectionState.DISARMED
                    reason = "alarm_authenticated_dismissal"
                }
                NativeEventType.ANCHOR_PRESENT -> {
                    next = NativeProtectionState.PROTECTED
                    reason = "anchor_recovered_after_alarm"
                }
                else -> accepted = false
            }

            NativeProtectionState.DEGRADED -> when (event.type) {
                NativeEventType.RUNTIME_RECOVERED, NativeEventType.SERVICE_RESTARTED -> {
                    next = NativeProtectionState.ARMING
                    reason = "runtime_recovered_revalidation_required"
                }
                NativeEventType.DISARM -> {
                    next = NativeProtectionState.DISARMED
                    reason = "disarm_requested"
                }
                NativeEventType.DEGRADED -> reason = event.detail.ifBlank { "runtime_degraded" }
                else -> accepted = false
            }
        }

        if (next != NativeProtectionState.GRACE) {
            graceDeadlineMs = null
        }
        state = next
        return NativeTransition(
            previous = previous,
            current = next,
            reason = reason,
            graceDeadlineMs = graceDeadlineMs,
            accepted = accepted,
        )
    }
}
