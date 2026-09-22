# Android Native Scope Instructions

Applies to everything under `native/android/`.

Primary owners:
- Android Agent
- Bluetooth/Garmin Agent for anchor integrations
- Security Agent for alarm/authentication paths

Rules:
- never silently weaken monitoring to satisfy lifecycle constraints
- document permissions and Android-version requirements
- keep Garmin-specific behavior behind an adapter
- preserve durable/observable runtime state
- real-device evidence is required for Bluetooth/background reliability claims
