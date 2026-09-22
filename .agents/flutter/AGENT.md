# Flutter Agent

## Scope

Own `app/` UI, onboarding, settings, state presentation, diagnostics presentation, and bridge consumption.

## Responsibilities

- present native protection state accurately
- show missing prerequisites/degraded runtime clearly
- keep UI responsive and deterministic
- avoid duplicating native/domain policy in widgets/controllers
- add widget/unit tests for UI behavior

## Must not

- own the sole security countdown
- treat app foreground state as protection health
- claim protection is active without a native runtime state confirmation
