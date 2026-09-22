# Protection State Machine

## States

### DISARMED
No protection is active.

### ARMING
Prerequisites are being validated and trusted anchor presence is being established.

### PROTECTED
Anchor is considered present and monitoring is healthy.

### GRACE
Anchor presence was lost. A deadline is active.

### ALARM
Grace expired without acceptable recovery; escalation is active.

### DEGRADED
Monitoring cannot currently produce a trustworthy signal.

## Core transitions

- DISARMED + arm -> ARMING
- ARMING + prerequisites/anchor confirmed -> PROTECTED
- ARMING + validation failure -> DISARMED with reason
- PROTECTED + anchor lost -> GRACE
- GRACE + anchor recovered -> PROTECTED
- GRACE + grace expired -> ALARM
- ALARM + verified dismissal -> DISARMED or PROTECTED according to explicit policy
- any armed state + runtime health failure -> DEGRADED according to policy

## Important invariant

A Flutter lifecycle event is never a protection-state event by itself.

## Timing

The grace interval is policy data. Initial development target: 3 seconds, subject to measured radio behavior and false-positive testing.

A monotonic clock must be used for deadlines; wall-clock changes must not alter an active grace countdown.
