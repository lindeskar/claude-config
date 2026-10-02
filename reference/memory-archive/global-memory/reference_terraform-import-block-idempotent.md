---
name: reference_terraform-import-block-idempotent
description: A config-driven Terraform `import` block whose target is already in state is a silent no-op — plan reports 0 changes, no error, so leftover import blocks are cosmetic debt not a break
metadata:
  type: reference
---

After a config-driven `import` block has been applied, leaving it in the config is **harmless**: Terraform skips it and plans 0 changes rather than erroring "already managed by Terraform". Verified on TF 1.15 with a scratch config, and against a real CI plan of a state whose imports were applied a year earlier.

Consequences:
- Don't diagnose a stale `import` block as the cause of a broken plan — it produces no error and no diff.
- Conversely, an `import` block still sitting in config is **not** evidence the resource is unmanaged. Check whether the apply landed (the PR's apply comment, or a current plan showing no import lines) before concluding anything from the config alone. This is exactly how a "repo X is not managed by Terraform" issue can stay open for a year after it was actually fixed.
- Still worth removing after the apply — it's dead config that misleads readers.

Sibling mechanism for the reverse direction (making state forget a resource): [[reference_terraform-removed-block-module-internal]].
