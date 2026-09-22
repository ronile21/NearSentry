# NearSentry

NearSentry is a mobile anti-loss and anti-theft sentry that monitors proximity to one or more trusted devices and reacts when a protected device is separated from its trusted anchor.

The first MVP targets Android + Garmin as the trusted Bluetooth anchor. The architecture is intentionally device-agnostic so additional watches, earbuds, tags, and Bluetooth devices can be supported later.

## Current version

`0.0.0.1` — repository initialization and architecture baseline.

## Core invariant

When protection is armed:

1. A trusted anchor is connected/present.
2. The anchor becomes unavailable.
3. NearSentry starts a configurable grace window.
4. If the anchor does not recover before the grace window expires, the native sentry escalates.
5. Recovery inside the grace window cancels escalation.

## Architecture direction

- Flutter: application UI, settings, onboarding, history, presentation.
- Android/Kotlin: always-on sentry service, Bluetooth observation, alarm escalation, device-level integrations.
- Pure domain model: deterministic protection state machine and alarm policy.
- Platform bridge: explicit contract between Flutter and Android native code.

## Repository layout

- `app/` — Flutter application shell.
- `native/android/` — Android-native sentry components.
- `packages/domain/` — platform-independent domain contracts/state model.
- `docs/` — product requirements, architecture/design, ADRs, specifications, testing, operations, and version history.
- `scripts/` — local verification/bootstrap scripts.
- `.github/workflows/` — CI.

See [docs/README.md](docs/README.md) for the documentation index.

## Engineering rule

No important product or architectural decision should live only in chat, code comments, or memory. It must be captured in `docs/` and, when architectural, in an ADR.

## License

No open-source license is granted unless a LICENSE file is explicitly added later.
