# ADR-0007: Fenix Local Controls and Watch Alarm Mute

- Status: Accepted
- Date: 2026-09-23
- Version: 0.0.0.1

## Context

The Fenix must expose local protection controls without allowing an unauthenticated watch button to dismiss an escalated Android alarm. The user must also be able to silence an intentionally loud watch alarm without disabling protection.

Connect IQ has no unrestricted one-second background daemon, so fast foreground detection and low-power background maintenance must remain separate.

## Decision

- Garmin Select / Fenix START-STOP toggles watch protection when no alarm is active.
- Garmin Next/Down toggles watch-local MUTE/UNMUTE while ALARM is active.
- MUTE never clears alarm state and never dismisses or silences Android.
- MUTE state is persisted across watch-app reopen.
- Background work is event-driven plus an armed-only five-minute temporal watchdog.
- One-second connection polling is foreground-only.
- Watch CONTROL/START and CONTROL/STOP messages are best-effort synchronization requests to Android.

## Consequences

The watch has usable physical controls and a safe alarm-silencing path without turning MUTE into DISARM.

Immediate custom short-grace alarm is available while the app is foreground. Fully background custom alarm timing remains constrained by Garmin.

A currently emitted short Garmin tone has no documented cancellation method; MUTE prevents all subsequent tones.
