# Android Permissions Specification

## Manifest permissions

- `BLUETOOTH` / `BLUETOOTH_ADMIN` for Android <= 11 compatibility
- `BLUETOOTH_CONNECT` for modern connected-device access
- `POST_NOTIFICATIONS` on Android 13+
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_CONNECTED_DEVICE`
- `VIBRATE`
- `WAKE_LOCK`
- `USE_FULL_SCREEN_INTENT`

## Required at arm time

- Bluetooth enabled
- BLUETOOTH_CONNECT granted when runtime permission applies
- notification permission/enabled when runtime permission applies

## Recommended/conditional

- battery optimization exemption: recommended because OEM policies can interrupt monitoring
- full-screen intent capability: preferred for alarm UX but Android may restrict it

## UX behavior

Every prerequisite exposes:
- stable ID
- user-facing label
- current state
- required/recommended classification
- explanation
- action path when available

No permission is requested solely because it might be useful later.
