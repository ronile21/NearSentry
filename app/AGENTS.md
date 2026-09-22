# App Scope Instructions

Applies to everything under `app/`.

Primary owner: Flutter Agent.

Before changing app behavior, read:
- root `AGENTS.md`
- `.agents/flutter/AGENT.md`
- relevant product/specification documents

Rules:
- UI must display native protection truth; it must not manufacture a healthy state.
- Do not place the only disconnect countdown or alarm decision in Dart UI lifecycle code.
- Keep platform calls behind a clear bridge abstraction.
- Add widget/unit tests for material UI/controller behavior.
