# MVP Acceptance Criteria

The MVP is not accepted until all critical requirements below pass on the declared support matrix.

- **AC-001** Protection remains active after Flutter UI is backgrounded/recreated.
- **AC-002** Confirmed anchor loss enters grace and records the cause.
- **AC-003** Recovery before deadline cancels escalation.
- **AC-004** Grace expiry enters alarm exactly once.
- **AC-005** Alarm remains active until an allowed verified dismissal path succeeds.
- **AC-006** Every transition is visible in local diagnostics.
- **AC-007** Bluetooth off, permission loss, and service failure produce explicit degraded/failure states.
- **AC-008** No supported normal lifecycle event silently disarms protection.
- **AC-009** Battery impact is measured during soak testing.
- **AC-010** Supported Garmin/Android combinations are listed from actual testing.
