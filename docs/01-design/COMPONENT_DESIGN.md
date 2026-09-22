# Component Design

## Flutter

### ProtectionController
Single presentation controller. It consumes native snapshots/events and issues bridge commands. It does not run the security state machine.

### SentryBridge
Typed wrapper around:
- `nearsentry/control` MethodChannel
- `nearsentry/events` EventChannel

### Screens
- onboarding
- protection setup
- dashboard
- event history
- settings
- diagnostics

### Reusable components
- protection status card
- prerequisite tile
- telemetry timeline tile

## Pure Dart domain

### ProtectionEngine
Deterministic state reducer with monotonic timestamps and explicit invalid transitions.

### ProtectionPolicy
Currently owns the grace interval.

## Android native

### SentryService
Foreground service with `connectedDevice` type. Owns lifecycle entry into the native runtime.

### SentryRuntime
Coordinates monitoring, the native enforcement engine, grace scheduling, alarm effects, persistence, telemetry, and bridge snapshots.

### NativeProtectionEngine
Kotlin enforcement projection of the domain state semantics. Required because protection must remain functional without a Flutter engine.

### GarminAnchorMonitor
Adapter over the official Garmin Connect IQ Mobile SDK.

### SentryRepository
Durable local settings, enrolled anchor, intentional armed state, runtime generation, and bounded telemetry.

### AlarmController
Idempotent notification/audio/vibration alarm effects.

### AlarmActivity
Lock-screen/full-screen alarm surface when Android allows it; dismissal uses system authentication.

### PrerequisiteChecker
Maps Android permission/runtime conditions into explicit UI prerequisite records.
