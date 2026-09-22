# Domain Scope Instructions

Applies to everything under `packages/domain/`.

Primary owner: Domain Agent.

Rules:
- no Flutter dependency
- no Android dependency
- no Bluetooth/vendor dependency
- deterministic state/policy logic only
- invalid transitions and degraded states must be explicit
- deadline semantics must be based on monotonic time concepts
- every rule change requires tests
