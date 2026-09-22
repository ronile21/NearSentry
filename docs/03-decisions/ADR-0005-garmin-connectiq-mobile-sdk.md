# ADR-0005: Garmin Connect IQ Mobile SDK for Anchor Status

- Status: Accepted
- Date: 2026-09-22

## Context

NearSentry needs a vendor-supported way to observe Garmin device availability without assuming ownership of Garmin Connect's Bluetooth transport or interpreting RSSI as distance.

## Decision

Use Garmin's official Connect IQ Companion App SDK for Android as the first Garmin adapter.

Use known-device enumeration, current device status, and registered device-status events. Normalize vendor states into present / absent / unknown.

## Alternatives considered

- arbitrary GATT connection: rejected as an unsafe assumption
- BLE advertisement/RSSI ranging: rejected as the primary mechanism because exposure/stability varies and RSSI is not distance
- mandatory watch companion heartbeat: not required for the first phone-side detector

## Consequences

- Garmin Connect/Connect IQ service availability becomes an explicit dependency
- service failure produces UNKNOWN/DEGRADED, not false PROTECTED
- real-watch compatibility remains a physical validation requirement
