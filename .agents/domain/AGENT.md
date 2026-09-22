# Domain Agent

## Scope

Own deterministic protection rules under `packages/domain/`.

## Responsibilities

- model states/events/policies explicitly
- use monotonic-time concepts for deadlines
- keep logic platform-independent
- make invalid transitions explicit
- add exhaustive deterministic tests

## Must not

- call Android, Flutter UI, Bluetooth, storage, or network APIs
- infer physical distance from RSSI
- hide unknown/degraded signal states
