# Component Design

## Flutter

### AppShell
Owns navigation and screen composition.

### ProtectionController
Maps UI commands to the platform bridge and renders native state snapshots.

### DiagnosticsView
Displays transition/event journal for development and support.

## Domain

### ProtectionState
Expected initial states:
- disarmed
- arming
- protected
- grace
- alarm
- degraded

### ProtectionEvent
Examples:
- armRequested
- anchorConfirmed
- anchorLost
- anchorRecovered
- graceExpired
- alarmDismissed
- runtimeDegraded

### ProtectionReducer
Pure function:
`(state, event, policy) -> decision`

## Android native

### SentryService
Long-lived foreground service while protection is armed.

### AnchorMonitor
Interface for vendor/platform-specific presence implementations.

### GarminAnchorMonitor
First adapter; exact signal source remains subject to feasibility testing.

### AlarmController
Executes phone-side escalation policy.

### SentryRepository
Persists minimal durable state and event journal.

### FlutterBridge
Translates platform channel commands/events without embedding business policy.

## Rule

Platform adapters may observe reality and execute effects. They must not silently invent state-machine rules.
