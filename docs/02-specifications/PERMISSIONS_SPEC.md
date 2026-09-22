# Android Permissions Specification

Exact manifest declarations depend on the final minimum/target SDK and selected Bluetooth implementation.

Expected permission families may include:
- Bluetooth scan/connect runtime permissions on modern Android
- notifications
- foreground service
- vibration
- boot receiver only if a later ADR approves reboot behavior
- full-screen intent only if product behavior and Play policy allow it

## Rule

Do not request permissions preemptively. Each permission must map to a documented feature and Android-version condition.

## UX

The onboarding screen must distinguish:
- required permission missing
- permission permanently denied
- battery optimization risk
- Bluetooth disabled
- anchor unavailable
- service unhealthy
