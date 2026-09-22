# Local Telemetry Specification

## Purpose

Telemetry exists to explain reliability, not to track the user.

## Event fields

- eventId
- monotonic timestamp
- wall timestamp for display
- previous state
- next state
- trigger/cause
- anchor identifier (non-secret local ID)
- observation source
- optional RSSI
- confidence/status
- grace deadline when relevant
- runtime/process generation
- app version
- Android version/device model

## Storage

MVP telemetry is local and bounded by retention limits.

## Privacy

No cloud upload is part of the MVP. Any future upload requires a separate product/security decision and explicit user-facing policy.
