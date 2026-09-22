# System Design

## Goal

NearSentry must continue to monitor and make security-critical decisions while Flutter UI is backgrounded, recreated, or absent.

## Runtime topology

### Flutter application

Owns:
- onboarding and permission UX
- trusted-device selection
- arm/disarm command surface
- state presentation
- settings
- history and diagnostics
- developer simulation controls

Flutter never owns the only protection countdown or alarm decision.

### Pure Dart domain

`packages/domain/` is the platform-independent deterministic reference model for:
- protection states
- event semantics
- grace policy
- valid/invalid transitions

It has no Flutter, Android, Bluetooth, storage, or vendor dependencies.

### Android native sentry

`native/android/` owns the durable enforcement runtime:
- foreground service
- Garmin status observation
- monotonic grace deadline
- alarm effects
- persistence
- transition telemetry
- process/runtime recovery

Because the enforcement runtime must survive Flutter UI lifecycle loss, it contains a Kotlin projection of the same protection state semantics. ADR-0004 records this deliberate native enforcement boundary.

### Garmin adapter

`GarminAnchorMonitor` uses Garmin's Connect IQ Companion App SDK and normalizes device status to present / absent / unknown. Garmin-specific behavior never enters the product domain.

### Platform bridge

Flutter uses a MethodChannel for commands/snapshots and an EventChannel for state/telemetry notifications.

## Data flow

`Garmin/Simulator observation -> Native protection engine -> effects -> telemetry -> Flutter snapshot`

## Failure model

Unknown signal is never silently treated as healthy. Runtime, permission, Bluetooth, or Garmin-service failures move the armed runtime toward DEGRADED until revalidation succeeds.

## Storage

The MVP is local-first:
- Android SharedPreferences for settings/anchor/intentional armed state
- bounded JSON event journal in local preferences
- no cloud account
- no telemetry upload

## Reliability boundary

Source code and simulation tests can validate state semantics. Physical Garmin behavior, OEM background execution, battery usage, and alarm UI restrictions require real-device evidence.
