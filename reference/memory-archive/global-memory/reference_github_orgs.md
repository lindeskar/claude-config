---
name: Kognic GitHub orgs
description: Which GitHub orgs Kognic uses and what each is for — `annotell` is production code, `kognic-internal` is new and for non-production repos (plugins, internal tooling, fundraising/data-room, scratch)
type: reference
---

Kognic has two GitHub orgs:

- **`annotell`** — production code. Services, libraries, Terraform, GitOps, Helm charts, everything that ships to customers or runs in prod environments. Default target for new company code unless specified otherwise.
- **`kognic-internal`** — created later for non-production repos. Already hosts `kognic-internal/claude-plugins` (the Claude plugin marketplace). Intended for internal tooling, experiments, fundraising/investor material, and anything that shouldn't sit in the production namespace.

When provisioning new repos, ask which org the user wants — don't assume `annotell` for anything that isn't production code. If the user names a repo with a `kognic-internal/` prefix, take it at face value (the org is real, not a typo for `annotell`).
