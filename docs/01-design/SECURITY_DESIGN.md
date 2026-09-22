# Security Design

## Threat model

Primary initial threat: a phone leaves the owner's immediate physical control while the trusted watch remains with the owner.

## Security goals

- detect separation quickly
- make silent dismissal difficult
- preserve monitoring across normal UI lifecycle changes
- keep an auditable record of why escalation occurred

## Non-goals / hard platform limits

A normal consumer Android application cannot guarantee prevention of:
- hardware power-off
- radio shutdown
- factory reset
- OS termination
- recovery/bootloader actions
- all notification suppression paths

NearSentry must not make claims that contradict Android platform control.

## Alarm dismissal

Preferred policy is biometric/device-credential verification through Android system APIs. NearSentry never stores fingerprints or biometric templates.

Exact behavior while the device is locked must be validated against Android's allowed authentication and full-screen UI flows.

## Secrets

No secrets are required for the local MVP. If cloud services are introduced later, credentials must never be committed to the repository.
