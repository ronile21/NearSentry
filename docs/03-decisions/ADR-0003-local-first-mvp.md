# ADR-0003: Local-First MVP

- Status: Accepted
- Date: 2026-09-22

## Context

The core value is immediate local separation detection. A backend would add availability, privacy, and delivery dependencies before local reliability is proven.

## Decision

No backend is required for the MVP. Configuration, runtime state, and bounded diagnostic history are local.

## Consequences

Faster reliability work and smaller threat surface. Remote/family features are deferred and require a future ADR.
