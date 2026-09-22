# Functional Specification

## Onboarding

The user is shown:
- what NearSentry protects
- local-first privacy model
- native monitoring behavior
- authenticated alarm dismissal model

Completion is stored locally.

## Prerequisites

Before arming, required prerequisites must be healthy:
- Bluetooth enabled
- BLUETOOTH_CONNECT permission where required
- notifications permission/enabled where required

Battery-optimization exemption and full-screen intent capability are surfaced as important/recommended but do not falsely block all protection if unavailable.

## Trusted anchor

The user selects one Garmin device returned by the Connect IQ Mobile SDK. The selected ID/name are persisted locally.

## Arm

1. validate required prerequisites
2. require enrolled anchor
3. persist intentional armed state
4. transition DISARMED -> ARMING
5. start foreground service
6. start real Garmin monitor or explicitly selected developer simulator
7. require fresh PRESENT observation before PROTECTED

## Disconnect

PROTECTED + ABSENT:
- transition to GRACE
- create monotonic deadline
- record telemetry
- publish countdown snapshots

## Recovery

GRACE + PRESENT before deadline:
- cancel grace callback
- transition to PROTECTED
- record recovery

## Alarm

Deadline reached without recovery:
- transition to ALARM
- persist telemetry
- start idempotent notification/audio/vibration
- offer native full-screen alarm surface where allowed

## Dismissal

Production dismissal requires Android system authentication. Anchor recovery alone does not stop an active alarm.

## Diagnostics

UI exposes:
- state
- service health
- runtime generation
- anchor
- normalized anchor status
- simulation flag
- recent transitions

## Developer simulator

When explicitly enabled, the diagnostics screen can inject connected, disconnected, transient disconnect, recovery, degraded, alarm, and service-restart scenarios.
