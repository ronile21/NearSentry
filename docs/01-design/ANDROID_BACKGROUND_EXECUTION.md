# Android Background Execution Design

## Requirement

NearSentry must not rely on a normal background Dart isolate as the sole sentry runtime.

## Initial design

When armed, NearSentry runs an Android foreground service with a persistent notification and the minimum required foreground-service type/permissions for the final implementation.

The service owns:
- armed state
- anchor observation subscription
- grace deadline
- alarm transition
- durable event logging

## Platform constraints

Modern Android versions aggressively constrain background work, exact alarms, Bluetooth permissions, notification behavior, and full-screen intents. OEMs can add additional battery restrictions.

NearSentry must test behavior on real Samsung/Pixel devices and document required user settings.

## Restart behavior

Service/process death must be detected and recorded. Restoration policy must never silently claim protection is active when monitoring was not restored successfully.

## Reboot

Reboot auto-rearm is not assumed. It requires an explicit ADR after security, permission, and UX behavior are validated.
