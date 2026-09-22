# Project Context

## Product

NearSentry detects separation between a protected Android phone and a trusted nearby anchor, initially a Garmin watch.

## Current architecture

- Flutter application: UI/presentation.
- Pure Dart domain: protection state/policy contracts.
- Android/Kotlin native runtime: future foreground sentry and device integration.
- Local-first MVP.
- Documentation-driven engineering.

## Current repository version

See root `VERSION`.

## Current major unknowns

1. Which Garmin/Android signal can reliably establish anchor presence.
2. Whether a Garmin Connect IQ companion is required.
3. Reliable watch-side alarm/vibration path.
4. OEM-specific Android background/full-screen restrictions.
5. Measured false-positive and battery characteristics.

Treat these as unknown until backed by evidence.
