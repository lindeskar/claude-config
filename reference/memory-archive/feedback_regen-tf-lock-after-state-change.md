---
name: regen-tf-lock-after-state-change
description: After changing a Terraform/OpenTofu state dir, always regenerate the lock multi-platform (init -backend=false -upgrade; providers lock -platform=linux_amd64 -platform=darwin_arm64)
metadata:
  type: feedback
---

After making changes in a Terraform/OpenTofu state directory, always regenerate
the `.terraform.lock.hcl` for **both** platforms before committing:

```sh
tofu init -backend=false -upgrade
tofu providers lock -platform=linux_amd64 -platform=darwin_arm64
```

**Why:** the committed lock must carry hashes for the CI runner (`linux_amd64`)
*and* the laptop (`darwin_arm64`). A lock that's missing a platform's hashes — or
stale after a provider/version change — fails CI `tofu init`. Running both
commands keeps it complete and current. Both are download-only, so they work
under the command sandbox.

**How to apply:** run them in the changed state dir, then check `git diff
'*.terraform.lock.hcl'` touches only the providers you intended (siblings that are
exact-pinned shouldn't move). Learned after the user had to recreate the lock in
`terraform-devplat-volcano#450` (a `volcengine 0.0.176 → 0.0.186` bump). See also
[[verify-ci-trigger-rules]].
