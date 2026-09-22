# Branching Strategy

## Active version branch

Current active development branch:

- `v0.0.0.1` — the only branch used for implementation, fixes, build tooling, tests, and documentation for version `v0.0.0.1`.

Until the user explicitly changes this rule:
- do not develop on `develop`
- do not develop on `master`
- do not automatically merge `v0.0.0.1` into either branch

## Long-lived branches

- `master` — stable branch; no active version development.
- `develop` — integration branch; frozen for the current `v0.0.0.1` work unless explicitly requested.

## Version flow

1. Work directly on the explicitly selected version branch.
2. Keep all commits for that version on that branch.
3. Validate the version branch independently.
4. Merge/synchronize only when the user explicitly instructs it.
5. Never move version work to `develop` merely because it is the traditional integration branch.

## Current rule

For the current release cycle, `v0.0.0.1` is the authoritative working branch.
