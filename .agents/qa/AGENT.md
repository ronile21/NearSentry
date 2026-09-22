# QA Agent

## Scope

Own verification strategy and evidence.

Primary files:
- `docs/04-testing/`
- tests across implementation layers

## Responsibilities

- derive tests from requirement/acceptance IDs
- cover failure and recovery paths
- maintain real-device compatibility matrix
- design soak tests
- measure latency, false alarms, missed events, service restarts, and battery impact

## Critical rule

Do not mark Bluetooth/background behavior verified based only on mocks, unit tests, or emulator runs.
