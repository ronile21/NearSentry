# Bluetooth / Garmin Monitoring Design

## Selected source

The first production adapter uses Garmin's official Connect IQ Companion App SDK for Android.

It uses:
- SDK initialization against Garmin Connect
- known-device enumeration
- device-status queries
- device event registration

The adapter normalizes Garmin status to:
- present
- absent
- unknown

## Why this path

NearSentry must not assume:
- paired == currently present
- Garmin Connect's private Bluetooth connection is an arbitrary GATT connection NearSentry can own
- RSSI == physical distance
- BLE advertisements are stable across Garmin models

The Connect IQ companion SDK is the vendor-supported application integration surface for Garmin device status.

## Observation model

Each observation includes:
- anchor ID
- monotonic timestamp
- normalized status
- signal source
- optional RSSI
- confidence
- diagnostic reason

Current Garmin adapter does not use RSSI.

## Unknown behavior

Connect IQ initialization failure, Garmin Connect service unavailability, missing enrolled device, or unrecognized status produces UNKNOWN and therefore explicit degraded protection rather than false health.

## Watch companion

A watch-side Connect IQ app is not required for the first phone-side presence detector. Watch-side vibration/alarm remains outside verified MVP behavior until implemented and tested against Garmin device APIs.

## Required physical validation

- screen on/off
- Flutter app foreground/background/killed
- Garmin Connect foreground/background
- real separation and reconnection
- watch reboot
- phone reboot
- Bluetooth toggle
- battery saver/OEM optimization
- multi-hour/day soak
