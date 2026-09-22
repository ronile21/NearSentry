# Bluetooth / Anchor Monitoring Design

## Goal

Produce a normalized anchor-presence signal with confidence and cause.

## Important risk

A paired Garmin being connected through Garmin Connect does not automatically mean a third-party Android app can own or inspect a stable GATT connection in the way NearSentry needs.

Therefore the Garmin presence mechanism is a feasibility item, not a solved assumption.

## Candidate signal sources

- Android Bluetooth connection/profile state where accessible.
- BLE scan/advertisement observation where the Garmin model exposes a usable stable signal.
- Companion protocol through a Garmin Connect IQ application.
- Multi-signal fusion if no single signal is reliable enough.

## Normalized observation

An observation should include:
- anchorId
- timestampMonotonic
- status: present / absent / unknown
- signalSource
- optional RSSI
- confidence
- diagnostic reason

## Rule

RSSI alone must not be interpreted as physical distance. It is noisy and environment-dependent.

## Testing

Test:
- phone screen on/off
- app foreground/background
- Garmin Connect running/not running
- Bluetooth toggled
- airplane mode
- watch reboot
- phone reboot
- transient RF obstruction
- different Samsung/Pixel power modes
