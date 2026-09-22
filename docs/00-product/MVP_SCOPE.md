# MVP Scope

## In scope

- Android phone as protected device.
- One trusted Garmin watch/anchor.
- Arm/disarm protection.
- Observe anchor availability.
- Configurable short grace interval after suspected disconnect.
- Deterministic state transition from protected to grace to alarm.
- Loud phone-side alarm escalation.
- Persistent foreground/native monitoring while armed.
- Local event history explaining state transitions.
- Recovery handling when the anchor reconnects.
- Explicit permissions/onboarding checks.
- Biometric-gated alarm dismissal where Android allows it.

## Feasibility spike required

- Reliable Garmin-specific presence signal across supported watch/phone combinations.
- Watch-side alarm/vibration command path. A Garmin Connect IQ component may be required.
- Behavior under Android vendor battery optimization.
- Full-screen alarm behavior on current Android versions and OEM skins.

## Out of scope for first MVP

- iOS.
- Cloud account.
- Multi-user/family monitoring.
- Remote wipe/remote lock.
- GPS tracking backend.
- Guaranteed prevention of power-off, airplane mode, factory reset, or OS-level termination.
- Claims that NearSentry can bypass Android security restrictions.

## MVP success condition

A supported Android/Garmin pair can remain armed for an extended real-world session, detect genuine separation within the configured policy, recover from transient radio loss, and produce a trace explaining each decision.
