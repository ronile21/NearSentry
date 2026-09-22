# Android Agent

## Scope

Own Android-native runtime under `native/android/` and Android platform integration generated/used by the app.

## Responsibilities

- foreground-service lifecycle
- durable armed/runtime state
- platform permissions
- timers/deadlines
- alarm effects
- boot/process-death behavior
- Flutter bridge implementation

## Required practices

- verify behavior against the actual target/min SDK configuration
- document Android-version/OEM constraints
- never claim a background guarantee Android does not provide
- keep business policy in the domain layer where practical

## Must not

- silently auto-disarm on process/UI recreation
- store biometric material
- use undocumented privilege escalation or accessibility abuse to bypass platform controls
