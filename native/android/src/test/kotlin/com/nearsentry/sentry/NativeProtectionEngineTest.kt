package com.nearsentry.sentry

import org.junit.Assert.assertEquals
import org.junit.Test

class NativeProtectionEngineTest {
    @Test
    fun disconnectRecoveryDoesNotAlarm() {
        val engine = NativeProtectionEngine(3_000)
        engine.apply(NativeEngineEvent(NativeEventType.ARM, 0))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_PRESENT, 1))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_ABSENT, 2))
        val recovered =
            engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_PRESENT, 2_000))

        assertEquals(NativeProtectionState.PROTECTED, recovered.current)
    }

    @Test
    fun graceExpiresOnceDeadlineIsReached() {
        val engine = NativeProtectionEngine(3_000)
        engine.apply(NativeEngineEvent(NativeEventType.ARM, 0))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_PRESENT, 1))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_ABSENT, 100))

        assertEquals(
            NativeProtectionState.GRACE,
            engine.apply(NativeEngineEvent(NativeEventType.GRACE_EXPIRED, 3_099)).current,
        )
        assertEquals(
            NativeProtectionState.ALARM,
            engine.apply(NativeEngineEvent(NativeEventType.GRACE_EXPIRED, 3_100)).current,
        )
    }

    @Test
    fun recoveryCannotDismissAlarm() {
        val engine = NativeProtectionEngine(1_000)
        engine.apply(NativeEngineEvent(NativeEventType.ARM, 0))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_PRESENT, 1))
        engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_ABSENT, 2))
        engine.apply(NativeEngineEvent(NativeEventType.GRACE_EXPIRED, 1_002))

        assertEquals(
            NativeProtectionState.ALARM,
            engine.apply(NativeEngineEvent(NativeEventType.ANCHOR_PRESENT, 2_000)).current,
        )
        assertEquals(
            NativeProtectionState.DISARMED,
            engine.apply(
                NativeEngineEvent(NativeEventType.AUTHENTICATED_DISMISSAL, 2_001),
            ).current,
        )
    }
}
