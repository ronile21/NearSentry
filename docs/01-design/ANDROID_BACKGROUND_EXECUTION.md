# Android Background Execution Design

## Foreground service

When armed, `SentryService` runs as an Android foreground service with:

- `android:foregroundServiceType="connectedDevice"`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_CONNECTED_DEVICE`
- runtime `BLUETOOTH_CONNECT` prerequisite on modern Android

This matches Android's connected-device foreground-service model.

## Ownership

The service/native runtime owns:
- active anchor monitoring
- native monotonic grace timer
- alarm escalation
- durable armed intent
- telemetry
- service runtime generation

Flutter may disappear without becoming a protection-state event.

## Process/service recreation

If process state is rebuilt while protection was intentionally armed:
1. do not claim PROTECTED
2. enter degraded/revalidation semantics
3. restart monitor under the foreground service
4. require a fresh anchor observation

## OEM limits

A foreground service materially improves survivability but is not an OS-level guarantee. Samsung/Pixel/OEM battery controls must be validated on physical devices. The UI exposes battery optimization status as a recommended prerequisite.

## Reboot

Automatic reboot re-arm remains intentionally unimplemented because the existing product requirements require a separate policy/ADR before enabling it.
