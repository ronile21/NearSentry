# Changelog

All notable NearSentry product releases are recorded here.

## [0.0.0.1] - 2026-09-22

### Added
- Fenix 7X physical controls: START/STOP toggles protection and DOWN toggles persistent watch-local MUTE/UNMUTE during ALARM without disarming or dismissing Android.
- Watch-to-Android CONTROL/START and CONTROL/STOP synchronization plus passive Android Connect IQ listener registration.
- Armed-only Garmin background policy: event-driven phone messages and a five-minute watchdog; one-second connection polling remains foreground-only for battery efficiency.
- Fenix 7X Connect IQ companion app with synchronized armed state, foreground phone-disconnect detection, watch vibration/tone alarm, background phone-message handling, five-minute Garmin background fallback, diagnostics and build tooling.
- Android-to-watch command bridge using the official Garmin Connect IQ Mobile SDK and the shared NearSentry watch application ID.
- First end-to-end NearSentry MVP.
- Flutter Material 3 application with onboarding, setup, dashboard, grace/alarm UX, history, settings, and diagnostics.
- Deterministic pure Dart protection engine with explicit invalid transitions and monotonic grace deadlines.
- Android connected-device foreground service and native enforcement state engine.
- Official Garmin Connect IQ Companion App SDK adapter for device-status observations.
- Durable local settings, trusted-anchor enrollment, armed intent, runtime generation, and bounded telemetry.
- Idempotent phone alarm controller with notification, system alarm audio, vibration, and full-screen intent path where Android permits.
- Biometric/device-credential alarm dismissal.
- Explicit developer simulation mode for connected/disconnected/transient/recovery/degraded/alarm/service-restart flows.
- Native/Dart state-machine architecture ADR and Garmin SDK ADR.
- Physical-device validation matrix and developer guide.

### Added
- NearSentry Android launcher icon with shield/proximity visual identity.
- `ANDROID_BUILD_INSTALL.BAT` for fast incremental build, in-place install, and launch on the directly connected Android device without cleaning or uninstalling.

### Fixed
- Garmin anchor monitoring now unregisters only device-status callbacks on stop and preserves the independent application-message listener used by Fenix controls.
- Garmin Android watch messaging now owns explicit Connect IQ SDK initialization/readiness, queues the most recent command until `onSdkReady()`, and exposes transport-stage diagnostics for SDK, device, app and send operations.
- Garmin watch app now registers foreground phone messaging during both `onStart()` and `getInitialView()`, and resets persisted Last-command diagnostics to `BOOT-1` on each foreground startup so stale messages cannot be mistaken for live transport.
- Added self-repair for the trusted Garmin anchor after watch reset/re-pair: when the stored device identifier is stale but exactly one connected Garmin with the same enrolled name is present, NearSentry refreshes the stored identifier before watch messaging.
- Added bidirectional Garmin watch handshake and diagnostics: PING/ACK, foreground/background command acknowledgements, Android app-event registration, and visible last-ACK state.
- Silent phone alarm path: alarm playback now uses MediaPlayer with USAGE_ALARM, requests transient exclusive audio focus, temporarily raises STREAM_ALARM to maximum, loops playback, restores the previous alarm volume on dismissal, and logs audio diagnostics.
- Android resource linking failure caused by invalid alarm-theme lock-screen style attributes; lock-screen/screen-on behavior remains implemented through the Activity API and manifest.
- Dart 3.10 compile failure caused by a non-constant `Duration.isNegative` assertion in the const protection policy.
- Deprecated Flutter radio selection API in trusted-device setup.
- Android full-clean installer no longer requires a globally installed Gradle distribution and now validates the active version branch and direct ADB authorization.

### Validation note
This implementation execution environment did not provide Flutter/Dart/Android SDK or Garmin hardware. Physical-device and build validation are therefore explicitly unverified here.

GitHub Actions is disabled and was not used as validation.
