# NearSentry v0.0.0.1 Release Notes

Release date: 2026-09-23

## Highlights

- First end-to-end NearSentry MVP for Android + Garmin Fenix 7X.
- Android native foreground protection runtime independent of Flutter UI lifetime.
- Garmin Connect IQ companion with physical START/STOP control.
- Foreground watch-side phone-disconnect detection with configurable grace period.
- Audible + vibration alarm on the watch.
- Watch-local DOWN-button MUTE/UNMUTE that silences only the watch while preserving alarm/protection state.
- Bidirectional Android/Garmin messaging with diagnostics and ACK/control transport.
- Automatic recovery after a real separation alarm when the trusted phone reconnects: alarm effects stop and monitoring returns to ARMED/PROTECTED.
- Local-first architecture with no cloud/backend dependency.

## Fixes

- Restored the known-good Garmin Android transport after an SDK-lifecycle regression.
- Manual watch diagnostics now bypass developer simulation mode so physical Garmin transport is actually exercised.
- Garmin app-message listeners remain registered independently of device-status monitoring shutdown.
- Added stable watch startup diagnostics (`BOOT-2`) and transport tracing.
- Added Garmin foreground sound/vibration alarm and persistent watch-local MUTE.
- Added watch-to-Android CONTROL/START and CONTROL/STOP behavior.
- Real reconnect after a separation alarm now stops alarm effects and resumes protected monitoring instead of leaving ALARM latched.

## Validation

Physically verified during the development cycle on Samsung Android + Garmin Fenix 7X:

- Android APK build/install succeeded.
- Garmin PRG build/install succeeded before the final reconnect-recovery patch.
- Android-to-watch commands were observed on the physical watch.
- Physical watch START/STOP arming was observed.
- Foreground Bluetooth disconnect produced PHONE DISCONNECTED -> ALARM.
- Watch vibration and audible alarm were observed.

Final release gate before publishing:

- rebuild Android from the final release-candidate HEAD
- rebuild Garmin from the final release-candidate HEAD
- verify physical reconnect stops the real separation alarm and returns watch/Android to ARMED/PROTECTED

## Known limitations

- Connect IQ does not expose an unrestricted continuously running one-second watch background daemon.
- NearSentry's short-grace custom watch disconnect detection is therefore foreground-only.
- While armed in watch background, NearSentry uses event-driven phone-app messages and a five-minute temporal watchdog.
- Garmin's native Phone Connectivity Alert should be enabled for immediate system-level watch attention when NearSentry is fully backgrounded.
- Android OEM background execution, long-duration battery behavior, and full-screen alarm behavior are not exhaustively validated across devices.
- A fully killed Android process cannot be treated as reliably wakeable by a Connect IQ watch callback.

## Version metadata

- Version: `0.0.0.1`
- Version branch: `v0.0.0.1`
- Release tag: `v0.0.0.1`
