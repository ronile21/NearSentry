# Workflow: Runtime / Device Incident

1. Preserve evidence before changing code.
2. Record app version, device model, Android version, Garmin model/firmware, permissions, battery mode, and reproduction steps.
3. Reconstruct NearSentry state transitions from local telemetry.
4. Separate signal failure from state-machine failure from alarm-effect failure.
5. Form one falsifiable hypothesis at a time.
6. Add regression coverage for verified software defects.
7. Update support/operations docs for platform-specific failure modes.
