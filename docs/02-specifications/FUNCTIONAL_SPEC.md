# Functional Specification

## Arm

Preconditions:
- trusted anchor configured
- required Bluetooth permissions granted
- notifications/foreground-service prerequisites satisfied
- anchor monitor healthy
- anchor presence established according to policy

Success:
- native runtime persists armed state
- foreground monitoring starts
- state becomes PROTECTED
- event is journaled

Failure:
- state returns to DISARMED
- explicit reason is returned to UI

## Disconnect

On a normalized absent observation while PROTECTED:
- transition to GRACE
- store monotonic deadline
- journal reason/source
- expose countdown/status to UI

## Recovery

If acceptable presence is restored before the deadline:
- cancel deadline
- transition to PROTECTED
- journal recovery

## Alarm

If deadline expires without accepted recovery:
- transition atomically to ALARM
- execute phone alarm policy
- journal escalation before/with effects so diagnostics survive crashes

## Dismissal

Dismissal must use the configured verified-user policy. UI-only button dismissal is not sufficient for the security profile unless explicitly enabled as a development mode.
