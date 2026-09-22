# Local Telemetry Specification

## Purpose

Explain protection behavior and support reliability debugging without uploading user data.

## Fields

Every accepted transition records:
- eventId
- wallTimestamp
- monotonicMs
- previousState
- nextState
- trigger
- source
- detail
- anchorId
- optional rssi
- optional confidence
- runtimeGeneration
- appVersion

## Runtime generation

Each foreground-service creation increments a local runtime generation so process/service restarts are visible in history.

## Storage

- local only
- JSON-backed bounded journal
- configurable retention 50–1000 events
- default 250

Malformed journal data is discarded locally rather than treated as valid protection history.

## Privacy

No telemetry backend, analytics SDK, or upload path is present in the MVP.
