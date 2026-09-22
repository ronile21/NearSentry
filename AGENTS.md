# NearSentry Agent Operating Contract

This file is the repository-wide instruction set for coding agents and autonomous engineering workflows.

## Active development branch

For version `v0.0.0.1`, all implementation, fixes, documentation updates, build tooling, and tests MUST be committed only to branch `v0.0.0.1`.

Do not modify `develop` or `master` while working on this version unless the user explicitly instructs a merge, synchronization, or hotfix outside the version branch.

## Instruction precedence

1. Human instructions in the active task.
2. The nearest `AGENTS.md` file in the directory tree.
3. This root `AGENTS.md`.
4. Agent-specific instructions under `.agents/<agent>/AGENT.md`.
5. General defaults of the agent/tool.

If instructions conflict, stop destructive work and follow the higher-precedence instruction.

## Repository mission

NearSentry is an Android-first anti-loss / anti-theft system. The first protected device is an Android phone and the first trusted anchor is a Garmin watch.

The security-critical runtime must not depend on Flutter UI execution remaining alive.

## Source of truth

Before changing behavior, read the relevant documents under `docs/`.

Required baseline:
- `docs/00-product/REQUIREMENTS.md`
- `docs/01-design/SYSTEM_DESIGN.md`
- `docs/01-design/STATE_MACHINE.md`
- `docs/02-specifications/FUNCTIONAL_SPEC.md`
- accepted ADRs under `docs/03-decisions/`

Important decisions must not exist only in chat, agent notes, or code comments.

## Architecture invariants

- Flutter owns UI, configuration, onboarding, diagnostics presentation, and non-critical orchestration.
- Android/Kotlin owns continuous monitoring, platform lifecycle, Bluetooth/platform observation, durable timers, and alarm effects.
- Domain rules must be deterministic and testable without Android hardware.
- Vendor-specific Garmin behavior stays behind an anchor adapter.
- The MVP is local-first and must not gain an undeclared backend dependency.
- RSSI is not distance.
- Never claim Android can guarantee prevention of power-off, radio disablement, OS termination, or factory reset.
- Never treat an unverified Garmin integration assumption as implemented fact.

## Change protocol

For any non-trivial change:

1. Identify affected requirement IDs and design documents.
2. Check whether an ADR is required.
3. Implement the smallest coherent change.
4. Add/update tests.
5. Update documentation in the same change.
6. Update `CHANGELOG.md` when behavior or repository capabilities materially change.
7. Update version records when the repository version changes.
8. Run applicable verification.
9. Report exactly what was verified and what remains unverified.

## Versioning

The repository version is stored in `VERSION`.

Version format:
`MAJOR.MINOR.PATCH.BUILD`

Every version must have:
- a `docs/05-versions/vX.Y.Z.B.md` record
- a `CHANGELOG.md` entry

Do not silently change version semantics.

## Git rules

- For `v0.0.0.1`, work only on branch `v0.0.0.1`.
- Do not force-push unless explicitly instructed.
- Do not rewrite accepted history merely to make it look cleaner.
- Do not delete ADRs or version records.
- Do not commit secrets, tokens, keystores, local machine configuration, or generated build output.
- Prefer focused commits with meaningful messages.
- Do not mix unrelated refactors with functional/security changes.

## Security rules

- Treat alarm/dismissal logic as security-sensitive.
- Do not weaken authentication or alarm behavior merely to make tests pass.
- Never store biometric material.
- Do not add network telemetry/cloud upload without an explicit product/security decision.
- Do not log secrets or personally sensitive payloads.
- Fail visibly when monitoring health is unknown; never silently present degraded protection as healthy.

## Testing rules

A code change is incomplete without tests appropriate to its layer.

Minimum expectations:
- domain rule change -> deterministic unit tests
- Android runtime change -> Android/component tests where feasible
- bridge contract change -> contract/integration tests
- Bluetooth behavior -> real-device validation plan/evidence
- security-sensitive behavior -> explicit failure-path tests

Mocks do not prove Bluetooth/background reliability.

## Documentation rules

Use `docs/templates/` when creating ADRs, feature specs, or version records.

Accepted ADRs are historical records. Supersede them with a new ADR instead of rewriting the original decision.

## Agent coordination

Agent definitions live under `.agents/`.

Agents must:
- stay within their declared scope unless explicitly delegated broader authority
- record assumptions
- distinguish verified facts from hypotheses
- leave actionable handoff notes
- avoid duplicating work already owned by another agent
- never invent successful test/build/device results

## Completion contract

A task is complete only when the final handoff includes:
- files changed
- requirements/design affected
- tests/verification executed
- known risks or unverified items
- recommended next action, if any
