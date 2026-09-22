# Changelog

All notable NearSentry changes are recorded here.

## [0.1.0.0] - 2026-09-22

### Added
- End-to-end Flutter Material 3 application with onboarding, setup, dashboard, grace/alarm UX, history, settings, and diagnostics.
- Deterministic pure Dart protection engine with explicit invalid transitions and monotonic grace deadlines.
- Android connected-device foreground service and native enforcement state engine.
- Official Garmin Connect IQ Companion App SDK adapter for device-status observations.
- Durable local settings, trusted-anchor enrollment, armed intent, runtime generation, and bounded telemetry.
- Idempotent phone alarm controller with notification, system alarm audio, vibration, and full-screen intent path where Android permits.
- Biometric/device-credential alarm dismissal.
- Explicit developer simulation mode for connected/disconnected/transient/recovery/degraded/alarm/service-restart flows.
- Native/Dart state-machine architecture ADR and Garmin SDK ADR.
- Physical-device validation matrix and developer guide.

### Changed
- Project version advanced from `0.0.0.3` to `0.1.0.0`.
- Documentation now describes implemented runtime behavior rather than repository scaffolding.
- CI workflow definition expanded for domain, Flutter, and Android build checks; GitHub Actions remains disabled and was not executed.

### Validation note
This implementation execution environment did not provide Flutter/Dart/Android SDK or Garmin hardware. Physical-device and build validation are therefore explicitly unverified here.

## [0.0.0.3] - 2026-09-22

### Added
- Long-lived `master` and `develop` branch model.
- Branching strategy documentation.

### Changed
- CI configured for `master` and `develop`.
- Repository version advanced to `0.0.0.3`.

## [0.0.0.2] - 2026-09-22

### Added
- Repository-wide agent operating infrastructure.

## [0.0.0.1] - 2026-09-22

### Added
- Initial repository/documentation/application skeleton.
