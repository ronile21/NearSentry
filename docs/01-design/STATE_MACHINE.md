# Protection State Machine

## States

- **DISARMED** — no protection active.
- **ARMING** — runtime is validating prerequisites and trusted-anchor presence.
- **PROTECTED** — monitoring healthy and anchor present.
- **GRACE** — anchor absent and a monotonic deadline is active.
- **ALARM** — deadline expired without recovery.
- **DEGRADED** — monitoring cannot produce a trustworthy signal.

## Core transitions

- DISARMED + arm -> ARMING
- ARMING + anchor present -> PROTECTED
- ARMING + anchor absent -> DISARMED
- PROTECTED + anchor absent -> GRACE
- GRACE + anchor present -> PROTECTED
- GRACE + grace deadline reached -> ALARM
- ALARM + authenticated dismissal -> DISARMED
- ALARM + anchor recovery -> PROTECTED
- any armed monitoring state + runtime failure -> DEGRADED
- DEGRADED + runtime recovery -> ARMING, then anchor must be revalidated
- any non-disarmed state + explicit disarm -> DISARMED

## Timing invariant

Grace deadlines use monotonic elapsed time:
- Dart reference: caller-provided monotonic microseconds
- Android enforcement: `SystemClock.elapsedRealtime()`

Wall-clock changes do not extend or shorten an active grace period.

## Duplicate events

Repeated absent observations while already in GRACE do not extend the original deadline. Repeated ALARM effects are idempotent. A real anchor recovery after ALARM stops alarm effects and returns protection to PROTECTED; it does not disarm the system.

## Process recovery

Persisted `armedIntended=true` does not restore a false PROTECTED state. A recreated native runtime starts DEGRADED/ARMING and requires fresh monitor validation.
