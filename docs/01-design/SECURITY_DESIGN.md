# Security Design

## Threat model

Primary scenario: the Android phone leaves the owner's physical control while the trusted Garmin remains with the owner.

## Controls

- monitoring enforced by native foreground runtime
- short monotonic grace deadline
- local alarm audio/vibration
- high-importance alarm notification/full-screen intent where permitted
- authenticated dismissal using Android BiometricPrompt with BIOMETRIC_STRONG or DEVICE_CREDENTIAL
- local transition audit trail
- explicit degraded states

## Alarm rule

Anchor recovery after ALARM does not silently stop the alarm. An authenticated dismissal or explicit authorized control action is required.

## Biometric material

NearSentry stores no fingerprint, face template, PIN, or device credential. Authentication is delegated to Android system APIs.

## Hard platform limits

NearSentry cannot guarantee prevention of:
- device power-off
- Bluetooth/radio shutdown
- OS termination
- factory reset
- bootloader/recovery actions
- every OEM notification/full-screen restriction

Product claims must preserve those limits.

## Developer simulation

Simulation is visibly labeled and cannot be treated as production Garmin evidence. It exists to test UI, state and effect orchestration without hardware.

## Privacy

No cloud service or telemetry upload exists in the MVP.
