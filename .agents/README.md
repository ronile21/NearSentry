# NearSentry Agent Infrastructure

The `.agents/` tree defines reusable engineering roles, workflows, shared context, and handoff contracts.

## Agents

- `orchestrator/` — decomposes work, assigns ownership, enforces handoffs.
- `product/` — requirements, scope, acceptance criteria, roadmap.
- `architect/` — system boundaries, ADRs, cross-component design.
- `domain/` — deterministic protection model and policies.
- `android/` — Android native runtime, lifecycle, permissions, alarm execution.
- `bluetooth-garmin/` — anchor observation and Garmin feasibility/integration.
- `flutter/` — UI, onboarding, diagnostics presentation, bridge consumption.
- `security/` — threat model, dismissal/authentication, security review.
- `qa/` — automated tests, device matrix, soak/failure testing.
- `docs/` — documentation coherence and traceability.
- `release/` — versioning, CI, release readiness.

## Shared directories

- `context/` — stable project context agents should load before work.
- `workflows/` — repeatable multi-agent execution flows.
- `templates/` — standard handoff/review/task formats.

## Rule

This directory contains durable agent instructions, not transient chain-of-thought, hidden reasoning, or scratchpads.

Do not commit private reasoning. Commit only useful engineering context, decisions, evidence, and concise handoffs.
