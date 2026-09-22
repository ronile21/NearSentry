# NearSentry

NearSentry is an Android-first anti-loss / anti-theft application that monitors separation between a protected phone and a trusted Garmin device.

## Current version

`v0.0.0.1` — first NearSentry MVP version.

## Implemented product flow

1. Complete onboarding and Android prerequisite checks.
2. Select a Garmin device exposed by Garmin Connect IQ.
3. Arm protection.
4. Android native foreground runtime monitors the anchor independently of Flutter UI lifecycle.
5. Anchor loss enters a configurable monotonic grace period (default: 3 seconds).
6. Recovery during grace cancels escalation.
7. Grace expiry starts a loud/vibrating phone alarm and high-priority/full-screen notification path where Android permits it.
8. Alarm dismissal requires Android biometric/device-credential authentication.
9. Every important transition is recorded in a bounded local event journal.

## Architecture

- `app/` — Flutter Material 3 application and Android host.
- `packages/domain/` — pure Dart deterministic domain/reference state machine.
- `native/android/` — Kotlin foreground runtime, Garmin adapter, persistence, alarm, native state engine, and Android-to-watch command bridge.
- `watch/garmin/` — Connect IQ Fenix 7X companion app, foreground separation alarm, background phone-message service, and Garmin build resources.
- `docs/` — product, design, specifications, ADRs, testing, operations, and permanent version history.
- `.agents/` — repository-native autonomous engineering contracts.
- `scripts/` — verification/bootstrap utilities.

## Development simulation

Settings → Developer simulation mode exposes deterministic connected/disconnected/recovery/degraded/alarm/service-restart scenarios. Simulated status is deliberately labeled and must never be interpreted as verified Garmin protection.

## Build

Android:

```bat
ANDROID_BUILD_INSTALL.BAT
```

Garmin Fenix 7X:

```bat
GARMIN_BUILD_WATCH.BAT
```

See `docs/06-operations/DEVELOPER_GUIDE.md`, `docs/06-operations/BUILD_AND_RUN.md`, and `docs/06-operations/GARMIN_WATCH_SETUP.md`.

## Important validation boundary

Garmin source integration uses the official Connect IQ Companion App SDK plus a Fenix 7X Connect IQ watch app. Garmin does not permit Connect IQ `Attention` vibration/tone APIs from a background process and does not expose an immediate background phone-disconnect trigger. Immediate NearSentry-controlled watch vibration therefore requires the watch app to be active; the background service provides message handling and Garmin's minimum five-minute disconnect fallback/wake request. Real-watch behavior, OEM background survival, battery impact, and alarm behavior require physical-device validation before production reliability claims.

No open-source license is granted unless a LICENSE file is explicitly added.
