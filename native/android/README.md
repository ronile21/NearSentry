# Android Native Sentry

This directory owns Android-specific protection runtime design and implementation.

Planned components:
- `SentryService`
- `AnchorMonitor`
- `GarminAnchorMonitor`
- `AlarmController`
- `SentryRepository`
- `FlutterBridge`

The module is intentionally a skeleton in 0.0.0.1. The next milestone must first validate the Garmin observation mechanism and Android foreground-service requirements before hard-coding an implementation.
