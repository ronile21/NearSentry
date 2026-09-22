# Test Strategy

## Layer 1 — pure Dart domain

Run:
- format
- analyze
- unit tests

Coverage targets:
- arm/validation
- disconnect -> grace
- monotonic deadline
- recovery before deadline
- duplicate absent event does not extend deadline
- alarm persistence after anchor recovery
- degraded -> revalidation
- explicit invalid transition

## Layer 2 — Flutter presentation

Widget tests cover core status rendering:
- protected
- grace countdown
- alarm

Further device-level UI validation covers onboarding, permission setup, settings, diagnostics and native bridge behavior.

## Layer 3 — Kotlin native

Unit tests cover enforcement state semantics. Android/device validation must cover:
- service lifecycle
- persistence
- alarm idempotency
- BiometricPrompt dismissal
- permission mapping
- process recreation

## Layer 4 — Garmin hardware

Mocks/simulator do not prove Garmin reliability. Required real-device cases:
- normal connection/separation/recovery
- screen off
- Flutter killed
- Garmin Connect backgrounded
- Bluetooth toggle
- watch reboot
- phone reboot
- battery saver/OEM optimization

## Layer 5 — soak

Run multi-hour/day armed sessions and record:
- detection latency
- false alarms/hour
- missed separations
- recovery latency
- service restarts
- battery consumption

## CI status

Repository workflow definitions may exist, but GitHub Actions is disabled for this repository. Do not treat workflow configuration as executed validation.
