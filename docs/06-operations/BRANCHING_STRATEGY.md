# Branching Strategy

## Long-lived branches

- `master` — stable integration/release branch and intended default branch.
- `develop` — active integration branch for ongoing development.

## Flow

1. Feature/fix branches should normally branch from `develop`.
2. Completed work merges back into `develop`.
3. Release-ready work moves from `develop` into `master`.
4. Hotfixes may branch from `master` and must be reconciled back into `develop`.

## Rules

- Do not develop directly on `master` unless explicitly instructed.
- Keep `master` releasable.
- CI runs on both `master` and `develop`, and on pull requests targeting either branch.
- Destructive history rewrites are not part of the normal workflow.
