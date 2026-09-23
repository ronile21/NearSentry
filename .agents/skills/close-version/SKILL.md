---
name: close-version
description: Close a NearSentry version safely: verify documentation and release notes, merge the version branch into develop, merge develop into master, then create the version tag and GitHub Release.
---

# Close Version

Use this skill when the user says to close, finalize, publish, or release the current NearSentry version.

The order is mandatory:

0. Validate documentation and release notes.
1. Merge the current version branch into `develop`.
2. Merge `develop` into `master`.
3. Create the version Git tag and GitHub Release.

Do not reorder, skip, or combine these gates.

## Inputs

Derive the version from the root `VERSION` file.

For version:

```text
0.0.0.1
```

the expected version branch and release tag are:

```text
branch: v0.0.0.1
tag:    v0.0.0.1
```

Never guess the version from chat history if `VERSION` is available.

## Safety rules

- Never force-push.
- Never rewrite `develop` or `master` history.
- Never delete the version branch as part of this skill.
- Never move or recreate an existing release tag that points to a different commit.
- Never create a GitHub Release before `master` contains the complete version.
- Never resolve merge conflicts silently. Stop and report the conflicting files.
- Never claim a build, test, hardware validation, or documentation check passed unless it was actually verified.
- All release mutations must use the exact current version.
- The version branch must be clean and synchronized with its remote before merge begins.

# Step 0 — Release preflight

This step is a hard gate. If any required item fails, stop. Do not merge anything.

## 0.1 Resolve and verify version

Read:

- `VERSION`
- current Git branch
- remote branch state

Require:

- version format is `MAJOR.MINOR.PATCH.BUILD`
- active release branch is exactly `v<version>`
- local release branch and `origin/v<version>` identify the intended release head
- working tree is clean if operating through local Git
- no uncommitted or unpushed release work is ignored

Record the release candidate commit SHA.

## 0.2 Documentation synchronization

Review the current version against all documentation affected by the implementation.

At minimum verify:

- `README.md`, when behavior/setup visible to users changed
- `docs/00-product/`, when scope or requirements changed
- `docs/01-design/`, when architecture/runtime behavior changed
- `docs/02-specifications/`, when normative behavior changed
- `docs/03-decisions/`, when an ADR was required
- `docs/04-testing/`, when validation requirements/evidence changed
- `docs/06-operations/`, when build/install/run/recovery procedures changed
- `CHANGELOG.md`
- `docs/05-versions/v<version>.md`

The current version document is the permanent release-note source of truth and must accurately describe:

- included features/fixes
- architecture decisions relevant to the version
- known limitations
- verification actually performed
- remaining unverified items

If any implementation in the release branch is missing from the relevant docs, update and commit the docs on the version branch before continuing.

## 0.3 Release notes

Require a current release note for exactly `v<version>`.

The release-note content must be derivable from:

- `docs/05-versions/v<version>.md`
- the matching `CHANGELOG.md` entry

Before merge, prepare a concise GitHub Release body containing:

- Highlights
- Fixes
- Validation
- Known limitations

Do not invent validation or remove known limitations to make the release look cleaner.

## 0.4 Release readiness

Run or inspect the verification appropriate to the version.

At minimum:

- repository/version metadata is internally consistent
- required build/test checks for changed layers are known
- security-sensitive failures are not hidden
- hardware-dependent behavior is marked verified or unverified based on real evidence

If the version is knowingly not releasable, stop before Step 1.

# Step 1 — Merge current version into develop

Source:

```text
v<version>
```

Target:

```text
develop
```

Procedure:

1. Fetch remote refs.
2. Verify the source SHA is still the preflight release candidate SHA.
3. Update local/working `develop` from `origin/develop`.
4. Merge `v<version>` into `develop`.
5. Use a normal merge commit when a merge commit is required by the repository workflow; do not squash away version history.
6. Push `develop`.
7. Verify the version branch commit is an ancestor of the new `develop` head.

Recommended verification:

```bash
git merge-base --is-ancestor origin/v<version> origin/develop
```

A non-zero result is a release blocker.

If there is a merge conflict, stop. Do not proceed to `master`.

# Step 2 — Merge develop into master

Source:

```text
develop
```

Target:

```text
master
```

Procedure:

1. Fetch again after Step 1.
2. Verify `origin/develop` contains the release candidate.
3. Update local/working `master` from `origin/master`.
4. Merge `develop` into `master`.
5. Push `master`.
6. Verify `develop` is an ancestor of the new `master` head.
7. Record the final `master` release commit SHA.

Recommended verification:

```bash
git merge-base --is-ancestor origin/develop origin/master
```

A non-zero result is a release blocker.

The tag and GitHub Release in Step 3 must identify this final `master` release commit.

# Step 3 — GitHub tag and release

In this workflow, the release "label" is the Git tag:

```text
v<version>
```

## 3.1 Create/verify tag

Check whether `v<version>` already exists.

If it does not exist:

1. Create the tag on the final `master` release commit.
2. Prefer an annotated tag.
3. Push the tag to GitHub.

Example:

```bash
git tag -a v<version> <master-release-sha> -m "NearSentry v<version>"
git push origin v<version>
```

If the tag already exists:

- if it points to the exact intended release commit, reuse it
- if it points anywhere else, STOP
- never retag or force-move it automatically

## 3.2 Create GitHub Release

Create a GitHub Release using:

- Tag: `v<version>`
- Target: the final `master` release commit
- Title: `NearSentry v<version>`
- Release body: the prepared release notes from Step 0
- Draft: false, unless explicitly requested
- Prerelease: false, unless explicitly requested or version policy says otherwise

The release body must preserve known limitations and the actual validation boundary.

## 3.3 Final verification

Verify all of the following:

- `v<version>` branch release candidate is contained in `develop`
- `develop` is contained in `master`
- Git tag `v<version>` exists
- tag points to the intended `master` release commit
- GitHub Release exists for that tag
- release title/version are correct
- release notes match the current version documentation

# Completion report

When finished, report:

- Version
- Version-branch SHA
- `develop` merge SHA
- `master` merge SHA
- Release tag
- GitHub Release URL
- Docs/release-note files verified or updated
- Verification actually executed
- Known limitations still present

Do not automatically create the next version branch. That is a separate operation unless the user explicitly requests it.
