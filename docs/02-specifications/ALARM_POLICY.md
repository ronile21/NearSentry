# Alarm Policy

## Development default

- Grace duration: 3 seconds.
- Escalation target: phone first.
- Watch-side escalation: pending Garmin companion feasibility.

## Phone escalation

Expected effects, subject to Android restrictions:
- high-priority ongoing alarm notification
- audible alarm at the strongest policy-compliant volume path
- vibration pattern
- full-screen alarm UI where allowed

## Dismissal

Production target:
- biometric or device credential via Android system authentication
- dismissal action recorded

## False-positive handling

Do not silently lengthen grace windows to hide radio instability. First classify the signal source and improve presence confidence.

## Safety / UX

Provide an explicit development mode during engineering so alarm testing can be stopped safely without weakening the production policy.
