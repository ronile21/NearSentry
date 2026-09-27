# Branching Strategy

## Active version branch

Current active development branch:

- `v0.0.0.2` — the only branch used for implementation, fixes, build tooling, tests, and documentation for version `v0.0.0.2`.

Version `v0.0.0.1` is released and frozen.

Until the user explicitly changes this rule:
- do not develop on `develop`
- do not develop on `master`
- do not modify released `v0.0.0.1`
- do not automatically merge `v0.0.0.2` into long-lived branches

## Long-lived branches

- `master` — stable released branch.
- `develop` — integration branch and source used to open the current version branch.

## Version flow

1. Open the next version branch from the synchronized released/integration head.
2. Work directly on the explicitly selected version branch.
3. Keep all commits for that version on that branch.
4. Validate the version branch independently.
5. Close the version using `.agents/skills/close-version/SKILL.md`.
6. Merge/synchronize only when the user explicitly instructs version closure.

## Current rule

For the current release cycle, `v0.0.0.2` is the authoritative working branch.
