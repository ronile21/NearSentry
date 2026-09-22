# Versioning Policy

NearSentry uses four-part versions:

`MAJOR.MINOR.PATCH.BUILD`

Initial development starts at `0.0.0.1`.

## Meaning

- **MAJOR**: incompatible product/architecture generation.
- **MINOR**: meaningful feature milestone.
- **PATCH**: compatible fixes/refinements within a milestone.
- **BUILD**: repository/project increment used during active development.

## Rules

1. Root `VERSION` is the current repository version.
2. Every version has a permanent document under `docs/05-versions/`.
3. `CHANGELOG.md` contains concise user/engineering-visible changes.
4. Version documents contain scope, decisions, risks, verification, and known limitations.
5. Historical version documents are not rewritten to pretend later knowledge existed earlier.
