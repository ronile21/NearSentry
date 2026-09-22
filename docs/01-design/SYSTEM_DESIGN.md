# System Design

## Architectural goal

Protection must continue to make correct decisions even when Flutter UI is suspended, recreated, or not visible.

## Logical components

1. **Flutter application**
   - onboarding
   - settings
   - arm/disarm command surface
   - diagnostics/history
   - presentation only

2. **Protection domain**
   - pure state machine
   - grace/alarm policy
   - platform-independent events and decisions

3. **Android native sentry**
   - foreground service/runtime
   - Bluetooth/anchor observation
   - timer scheduling
   - alarm escalation
   - persistence of armed state
   - telemetry/event persistence

4. **Anchor adapter**
   - converts vendor/platform observations into normalized presence signals
   - first implementation: Garmin/Android

5. **Platform bridge**
   - explicit typed command/event boundary between Flutter and native runtime

## Critical boundary

Flutter must not own the only countdown, Bluetooth observation loop, or alarm decision. Android may suspend or kill UI execution; therefore security-critical monitoring belongs in the native service.

## Data flow

`Anchor observation -> normalized signal -> protection state machine -> decision -> alarm/runtime action -> event journal -> UI`

## Failure strategy

Unknown signal quality must be represented as unknown/degraded, not automatically treated as either safe or theft. The policy decides how degraded states affect grace/escalation.

## No backend in MVP

The first architecture is local-first. No cloud dependency is required to detect or alarm.
