# Product Requirements

## Functional requirements

- **FR-001** The user can enroll exactly one trusted anchor in the first MVP.
- **FR-002** The user can arm and disarm protection.
- **FR-003** Arming is rejected when mandatory permissions or runtime prerequisites are missing.
- **FR-004** While armed, the native sentry continuously derives anchor presence.
- **FR-005** Loss of anchor presence moves the protection engine into a grace state.
- **FR-006** Anchor recovery during grace returns the system to protected without alarm.
- **FR-007** Grace expiry without recovery escalates to alarm.
- **FR-008** Every transition records timestamp, previous state, next state, cause, and relevant signal metadata.
- **FR-009** Alarm dismissal requires strong local user verification when available and permitted by Android.
- **FR-010** App UI can display current state and recent decision history.
- **FR-011** Process/UI recreation must not silently disarm an armed native sentry.
- **FR-012** Device reboot behavior must be explicit and observable; auto-rearm, if implemented, requires a documented policy.

## Non-functional requirements

- **NFR-001 Reliability:** detection must survive Flutter UI process recreation.
- **NFR-002 Latency:** the engine must not add avoidable polling latency to a confirmed disconnect.
- **NFR-003 Battery:** monitoring must have measurable and bounded power cost.
- **NFR-004 Explainability:** an alarm decision must be reconstructable from local telemetry.
- **NFR-005 Privacy:** MVP data remains local unless a later version explicitly introduces backend services.
- **NFR-006 Security:** no secret or biometric material is stored by NearSentry.
- **NFR-007 Testability:** state transitions are pure/deterministic outside platform adapters.
- **NFR-008 Compatibility:** supported Android/Garmin combinations are defined by a tested compatibility matrix, not assumed universal.
