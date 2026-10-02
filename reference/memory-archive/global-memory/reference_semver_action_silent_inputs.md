---
name: semver-action-silent-inputs
description: ietf-tools/semver-action needs BOTH noVersionBumpBehavior and noNewCommitBehavior set to silent for scheduled releases to skip quiet weeks
metadata:
  type: reference
---

`ietf-tools/semver-action` has two distinct no-release inputs that both default to `error`:

- `noVersionBumpBehavior` — commits exist since the last tag but none are bump-worthy types
- `noNewCommitBehavior` — zero commits at all since the last tag ("Couldn't find any commits between branch HEAD and latest tag.")

For scheduled (cron) release workflows that should skip quiet weeks instead of failing, **both must be `silent`**. Under `silent`, the action exits without setting `next`/`nextStrict` outputs, so downstream steps gate cleanly on `if: steps.semver.outputs.nextStrict != ''`.

Used in Kognic's `create-release.yaml` pattern (ci-terraform-status is the template; rollout tracked in lindeskar/work#79). Dependabot/Renovate commit as `fix(deps):` so dependency bumps count as a patch (`fix` is in the default `patchList`; matching is on the parsed conventional-commit *type*, scope ignored).
