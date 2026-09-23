# Garmin Watch Runtime, Controls, Background Policy and Alarm

Version: 0.0.0.1

## Implemented controls

NearSentry uses Garmin behavior events rather than hard-coded key numbers.

On the Fenix five-button layout:
- top-right START/STOP is the Select behavior
- bottom-left DOWN is the Next/Down behavior

NearSentry maps START/STOP to protection START/STOP. During an active alarm, DOWN toggles watch-local MUTE/UNMUTE.

## START

START requires the watch to currently report PHONE CONNECTED.

START persists the watch armed state, clears stale alarm/mute state, enables the background policy and sends a best-effort CONTROL/START message to Android.

While the Connect IQ UI remains foreground, NearSentry polls `System.getDeviceSettings().phoneConnected` once per second and applies the configured grace interval.

## STOP

STOP clears the watch armed state, pending alarm and mute state, deletes the temporal watchdog and sends CONTROL/STOP to Android.

STOP is blocked while ALARM is active. An escalated Android alarm still requires Android authentication.

## MUTE

DOWN is a watch-local MUTE control during ALARM.

MUTE:
- persists `alarmMuted=true`
- stops the repeating watch alarm timer
- replaces ongoing vibration with a zero-duty vibration profile
- prevents all subsequent watch tone/vibration pulses
- leaves `alarmPending=true`
- leaves the watch screen in ALARM
- does not disarm protection
- does not mute or dismiss the Android alarm

DOWN again performs UNMUTE and resumes watch output.

Connect IQ does not expose a documented stop-tone method. The predefined tone already emitted is short; MUTE prevents subsequent tones while the current short tone is allowed to finish.

## Foreground alarm path

1. Check `phoneConnected` every second.
2. First disconnected sample records a monotonic disconnect time.
3. Reconnection during grace cancels escalation.
4. Sustained disconnection sets a pending alarm.
5. The watch enters ALARM.
6. Vibration plus alternating loud Garmin tones repeat every 2.5 seconds.
7. DOWN can mute only the watch output.

This path does not depend on Android sending an ALARM after Bluetooth has already disappeared.

## Background and battery policy

Connect IQ does not provide an unrestricted one-second daemon for a watch app.

NearSentry therefore uses:
- event-driven phone-app message events
- a five-minute temporal watchdog only while armed
- no one-second timer after the watch UI exits
- no background sound/vibration loop
- watchdog deletion when stopped

The temporal service checks `phoneConnected`. On a detected disconnect it persists an alarm and requests application wake.

The five-minute fallback is not a three-second background guarantee. Garmin's native phone connectivity alert should be enabled for immediate platform-level background attention.

## Watch to Android controls

The watch sends:
- `CONTROL / START`
- `CONTROL / STOP`

Android registers a Connect IQ application listener at runtime startup and retries briefly while the Garmin SDK becomes ready.

`GarminAnchorMonitor.stop()` unregisters device events only. It deliberately does not call `unregisterAllForEvents()`, because that would remove the independent application-message listener.

If the Android process has been fully killed, watch-to-phone CONTROL remains best-effort; Connect IQ callbacks are not an Android process-wake guarantee.

## Code map

- `NearSentryInputDelegate.mc`: START/STOP and DOWN behavior mapping.
- `NearSentryController.mc`: foreground polling, grace, local START/STOP, alarm, MUTE.
- `NearSentryBackgroundPolicy.mc`: event registration and armed-only five-minute watchdog.
- `NearSentryServiceDelegate.mc`: background commands and fallback disconnect check.
- `NearSentryState.mc`: durable armed/alarm/mute/grace state.
- `NearSentryTransport.mc`: ACK and CONTROL messages.
- `NearSentryView.mc`: functional status and button hints.
- Android `GarminWatchMessenger.kt`: phone-to-watch transport and watch-to-phone listener registration.
- Android `GarminAnchorMonitor.kt`: Garmin device-status monitoring only.
- Android `SentryRuntime.kt`: CONTROL/START and CONTROL/STOP enforcement.

## Physical validation

1. Install both the Android APK and watch PRG.
2. Open NearSentry on Fenix and verify `Last: BOOT-2`.
3. With PHONE CONNECTED, press START/STOP and verify ARMED.
4. Close/reopen the app; ARMED must persist.
5. With the app foreground, disable Android Bluetooth.
6. After grace, verify ALARM, vibration and tone.
7. Press DOWN and verify WATCH MUTED and no further watch pulses.
8. Confirm Android alarm remains active.
9. Press DOWN again and verify watch output resumes.
10. Restore Bluetooth; an escalated alarm must not silently dismiss itself.
11. Authenticate on Android to dismiss the real alarm.
12. When not alarming, START/STOP must switch to DISARMED.

## Garmin references

- BehaviorDelegate: https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/BehaviorDelegate.html
- Five-button interaction model: https://developer.garmin.com/connect-iq/user-experience-guidelines/designing-workflows-and-interactions/
- Background: https://developer.garmin.com/connect-iq/api-docs/Toybox/Background.html
- Attention: https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html
