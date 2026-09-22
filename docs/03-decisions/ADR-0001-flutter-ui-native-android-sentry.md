# ADR-0001: Flutter UI with Native Android Sentry

- Status: Accepted
- Date: 2026-09-22

## Context

NearSentry needs rapid UI development but cannot depend on Flutter execution remaining alive for security-critical monitoring.

## Decision

Use Flutter/Dart for product UI and presentation. Use Kotlin/Android native components for continuous monitoring, platform integration, timers, and alarm effects.

## Consequences

Positive:
- clean UI velocity
- direct access to Android lifecycle/Bluetooth/security APIs
- critical runtime survives Flutter UI recreation

Cost:
- two-language boundary
- platform bridge contract must be tested
- more integration complexity than pure Flutter
