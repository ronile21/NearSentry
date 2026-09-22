# Changelog

All notable NearSentry product releases are recorded here.

## [0.0.0.1] - 2026-09-22

### Added
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

### Validation note
This implementation execution environment did not provide Flutter/Dart/Android SDK or Garmin hardware. Physical-device and build validation are therefore explicitly unverified here.

GitHub Actions is disabled and was not used as validation.
