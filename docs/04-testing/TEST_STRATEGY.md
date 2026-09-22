# Test Strategy

## Layer 1: Pure domain tests

Exhaustively test state transitions and timing policy without Android or Bluetooth.

Required cases:
- arm success/failure
- disconnect -> grace
- recovery before deadline
- expiry -> alarm
- duplicate/out-of-order observations
- degraded runtime
- monotonic deadline behavior

## Layer 2: Android component tests

Test service lifecycle, durable state, timers, alarm controller, permissions, and bridge behavior.

## Layer 3: Hardware integration tests

Real phone + real Garmin watch. Mocks are insufficient for Bluetooth/background reliability.

## Layer 4: Soak tests

Armed sessions lasting hours/days with:
- screen off
- UI process killed/reopened
- normal movement
- intermittent RF conditions
- charging/not charging
- battery saver

## Metrics

Track:
- disconnect detection latency
- false alarm count/hour
- missed separation count
- recovery latency
- service restarts
- battery consumption
