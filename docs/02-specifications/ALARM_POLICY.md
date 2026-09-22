# Alarm Policy

## Defaults

- grace interval: 3 seconds
- allowed configurable range: 1–15 seconds
- phone-side alarm enabled by default
- sound enabled by default
- vibration enabled by default

## Escalation

On transition to ALARM:
- create/update high-importance alarm notification
- request full-screen alarm surface where Android permits
- play the system alarm ringtone in looping mode where supported
- start repeating vibration waveform
- keep alarm effects idempotent

## Dismissal

- production: BIOMETRIC_STRONG or DEVICE_CREDENTIAL through Android BiometricPrompt
- developer simulation does not introduce an unsecured production dismissal path
- anchor recovery after escalation does not dismiss alarm

## Platform limitation

Full-screen intent permission/capability is OS/policy-controlled. If denied, notification/audio/vibration still provide escalation. Physical-device behavior must be validated.
