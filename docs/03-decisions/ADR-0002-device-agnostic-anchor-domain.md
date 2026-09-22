# ADR-0002: Device-Agnostic Anchor Domain

- Status: Accepted
- Date: 2026-09-22

## Context

Garmin is the first anchor, but embedding Garmin semantics into the protection engine would make every future wearable integration invasive.

## Decision

The domain consumes normalized anchor observations through an AnchorMonitor contract. Garmin-specific behavior stays in an adapter.

## Consequences

The core state machine can be tested without Bluetooth hardware and future anchors can be added without rewriting protection policy.
