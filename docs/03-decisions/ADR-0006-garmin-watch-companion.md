# ADR-0006: Garmin Watch Companion and Background Attention Boundary

- Status: Accepted
- Date: 2026-09-22
- Version: 0.0.0.1

## Context

NearSentry should alert both the protected Android phone and the trusted Garmin watch when they separate.

The Android runtime can detect Garmin connection loss through the official Connect IQ Mobile SDK. Once that Bluetooth path is already lost, however, Android cannot rely on sending a new ALARM command to the watch.

The Fenix 7X exposes `System.getDeviceSettings().phoneConnected` to Connect IQ. A foreground Connect IQ watch app can poll this state and use `Toybox.Attention.vibrate()` / `playTone()`.

Garmin Connect IQ does not permit the Attention module in background context. Connect IQ also does not expose an immediate background callback dedicated to a phone connection transition. Temporal background events have a minimum five-minute interval.

## Decision

Add a Fenix 7X Connect IQ device app under `watch/garmin/`.

When the app is foreground:
- persist the synchronized ARMED state
- poll `phoneConnected` once per second
- apply the synchronized grace interval
- run a repeating local vibration/tone alarm after sustained separation

When the app is background:
- register for phone-app messages
- persist ARMED/DISARMED commands
- register a five-minute temporal fallback while armed
- on background-detected disconnection, mark an alarm pending and request application wake

Android uses `GarminWatchMessenger` and a shared Connect IQ application ID to send a versioned command protocol.

## Consequences

Positive:
- real watch-side NearSentry behavior exists in the same repository
- foreground separation detection is independent of Android sending a post-disconnect message
- phone and watch share the same grace policy
- watch installation/message status is observable from Android diagnostics

Constraint:
- immediate custom vibration/tone cannot be guaranteed while the Connect IQ app is not active
- the five-minute background fallback is not a theft-grade substitute for the phone's short grace period
- Garmin's native Phone Connectivity Alert remains the platform-level option for immediate system background separation attention

This constraint must remain explicit in product claims and validation reports.
