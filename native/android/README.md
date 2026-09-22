# NearSentry Android Native Runtime

This module is consumed by the Flutter Android host as Gradle project `:sentry`.

## Implemented

- Android foreground service using the `connectedDevice` service type.
- Durable local settings and bounded telemetry journal.
- Native monotonic grace timer.
- Native protection state engine.
- Garmin Connect IQ Mobile SDK adapter.
- Idempotent phone alarm controller.
- Full-screen alarm activity where Android permits it.
- Biometric/device-credential dismissal through the host/activity.
- Developer simulator.

## Garmin presence signal

The production adapter uses Garmin's official Connect IQ Companion App SDK device status events. It does not interpret RSSI as distance and does not assume an arbitrary Bluetooth GATT connection can be owned by NearSentry.

A watch-side Connect IQ application is not required for the first presence detector because the Mobile SDK exposes known/connected-device status. Watch-side alarm/vibration remains a separate, unverified future capability.

## Hardware status

Source integration is implemented. Real Garmin hardware behavior, OEM background survival, battery consumption, and full-screen alarm behavior remain hardware validation items.
