# NearSentry Documentation

This directory is the engineering source of truth for the product.

## Structure

### `00-product/`
Why the product exists, who it serves, MVP boundaries, requirements, and roadmap.

### `01-design/`
System design and implementation design: runtime architecture, state machine, Android background execution, Bluetooth monitoring, security, and component boundaries.

### `02-specifications/`
Normative behavior specifications. These documents define what the implementation must do.

### `03-decisions/`
Architecture Decision Records (ADRs). Every significant architectural decision must be recorded and remain immutable after acceptance; superseding decisions create a new ADR.

### `04-testing/`
Test strategy, acceptance criteria, failure scenarios, and device/OS matrix expectations.

### `05-versions/`
Versioning policy plus a permanent document for every project version.

### `06-operations/`
Build, run, release, diagnostics, and operational procedures.

### `templates/`
Templates for new ADRs, feature specifications, and version records.

## Documentation rules

1. Design changes require documentation in the same pull request/commit as the implementation.
2. Accepted ADRs are not rewritten to hide history.
3. Every version gets a file under `05-versions/`.
4. Requirements use stable IDs so tests and commits can reference them.
5. Unknowns and feasibility risks are written explicitly instead of being treated as solved.
