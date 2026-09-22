# Engineering Guardrails

## Never assume

- paired == reliably observable
- connected == physically near
- RSSI == distance
- foreground service == impossible to kill
- emulator success == real-device reliability
- notification permission == full-screen alarm capability
- Garmin Connect behavior == public third-party API behavior

## Always preserve

- deterministic domain rules
- native ownership of critical monitoring
- explicit degraded states
- auditable transition history
- docs/code/test consistency
- historical ADR/version records

## Evidence classes

Use one of:
- VERIFIED: reproduced by code/test/device/docs evidence
- DOCUMENTED: confirmed by authoritative platform/vendor documentation
- HYPOTHESIS: plausible but not yet demonstrated
- REJECTED: tested or documented false for the targeted setup
