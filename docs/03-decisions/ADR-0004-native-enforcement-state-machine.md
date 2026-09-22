# ADR-0004: Native Enforcement State Machine

- Status: Accepted
- Date: 2026-09-22

## Context

The pure Dart domain is valuable for deterministic specification and tests, but security-critical monitoring must continue when Flutter UI/engine lifecycle is absent.

## Decision

Keep the pure Dart protection engine as the platform-independent reference model and implement a deliberately small Kotlin enforcement projection in the Android native runtime.

The two models share the same states, grace semantics, alarm persistence rule, degraded/revalidation rule, and monotonic timing invariant.

## Alternatives considered

### Run the only state machine in Flutter
Rejected because it would make critical enforcement depend on Flutter runtime survival.

### Put all rules only in Kotlin
Rejected because it would remove the platform-independent domain/reference model required by the architecture.

## Consequences

- native protection remains functional without Flutter
- parity must be reviewed/tested whenever state semantics change
- domain and native tests are both mandatory for behavior changes
