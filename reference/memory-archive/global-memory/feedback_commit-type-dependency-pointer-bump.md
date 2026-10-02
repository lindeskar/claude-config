---
name: commit-type-dependency-pointer-bump
description: Bumping a pinned dependency/image-tag default is chore/fix, not feat! — even when the new version contains a breaking change
metadata:
  type: feedback
---

A commit that only bumps a pinned dependency version or an image-tag default
(e.g. moving a Terraform component's `TF_RUNNER_IMAGE_TAG` from one tag to a
newer one) should be `chore` (or `fix(deps)`), **never `feat!`** — even if the
new image/version embodies a breaking change.

**Why:** Conventional-Commit semver tracks the component's own public interface.
The breaking-change (`!`/major) bump belongs to the single commit that changes
that interface — e.g. removing an input option. A later commit that just points
a default at the image which implements that already-declared change is
maintenance; marking it `feat!` **double-counts the major bump** and inflates
the next release version (e.g. an unwarranted 3.0.0 when 2.0.0 already captured
the break). Real example: gitlab-ci-volcano #173 (`feat!`, removed the
`terraform` TF_BINARY option → 2.0.0) was correct; #174 (bumped the image-tag
default to 2.0.0) should have been `chore`, not `feat!`.

**How to apply:** before adding `!` or `feat`, ask "does THIS commit change the
component's inputs/outputs/contract?" If it only moves a version pointer or
default, it's `chore`/`fix`. Be conservative with `!` — it triggers a major
release. See [[gh-pr-title-bang-backslash]] for the related `!`-in-title gotcha.
