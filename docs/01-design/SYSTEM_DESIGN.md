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

### Garmin watch companion

`watch/garmin/` is a Connect IQ watch application targeting `fenix7x`.

Android sends a small versioned command protocol through `GarminWatchMessenger`:
- `ARMED`
- `DISARMED`
- `ALARM`
- `ALARM_STOP`
- `TEST_ALARM`

The ARMED command includes the configured grace interval. While the NearSentry watch app is foreground, it independently observes `System.getDeviceSettings().phoneConnected` every second and starts its own vibration/tone alarm after the grace interval.

The Connect IQ background service registers for phone-app messages and a five-minute temporal fallback while armed. If a background check observes the phone disconnected it marks an alarm pending and requests an application wake.

Garmin runtime constraint: `Toybox.Attention` is not available in background context, and Connect IQ has no immediate background callback specifically for phone disconnection. Therefore NearSentry cannot truthfully guarantee an immediate custom watch vibration while the app is not active. ADR-0006 records this boundary.

### Platform bridge

Flutter uses a MethodChannel for commands/snapshots and an EventChannel for state/telemetry notifications.

## Data flow

`Garmin/Simulator observation -> Native protection engine -> phone effects -> telemetry -> Flutter snapshot`

`Native protection state -> GarminWatchMessenger -> Connect IQ watch app -> watch state/alarm when reachable`

The watch also performs an independent foreground `phoneConnected` check because the phone cannot send an ALARM message after the Bluetooth link has already been lost.

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
