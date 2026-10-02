---
name: feedback_no_explanatory_code_comments
description: Keep code/config comments minimal and short — no change-justification narration and nothing readable in the config itself; a good comment states genuinely non-obvious behavior. Rationale goes in the commit/PR
metadata:
  type: feedback
---

Don't add explanatory inline comments that narrate *why* a change was made — e.g. a multi-line `#` block above a Terraform resource explaining a provider quirk, a root cause, or why an approach was chosen. The user asked me to remove these and to "stop adding inline-comments like that."

**Why:** the reasoning belongs in the commit message and PR description, not embedded in the code. Inline comments like that add noise, go stale, and duplicate what version control already records.

**How to apply:** write the rationale in the commit body / PR description instead. Also keep the comments you *do* keep **short** (one line where possible). Two tests before writing a comment:
- **Can it be read in the config a few lines down?** (label meanings, which runner a job uses, a target path, an env value.) Then don't write it — it's noise that goes stale.
- **Does it just explain *why* this was added?** Then don't, unless it's *super* special — git blame + the PR description carry reasoning.

A good comment states **genuinely non-obvious behavior the config can't convey**, especially when it's load-bearing for a choice. Worked example (accepted by the user): `# terraform_status is an OTel gauge (=1 per run) that goes stale ~5min after a run, so match it with max_over_time, not an instant value` — you cannot infer the gauge/staleness from the PromQL, and it justifies the `max_over_time`. Contrast the same PR's rejected comments that spelled out the runner tag, the proxy path, and why each var was added (all readable nearby or PR-description material).

Applies across repos and languages; came up in Terraform (`terraform-devplat-volcano` / `terraform-modules-volcano`), a CI workflow (`application-helm` `renovate-render.yaml`), and the terraform-CI-metrics PRs (`k8s-platform-gitops`, `gitlab-ci-volcano`). Also Dockerfiles (`ci-terraform-status`): step-label comments ("Install the project dependencies") and why-this-base-image blocks were cut, keeping only `# Clear the base image's /bin/sh entrypoint so GitLab's shell detection runs` above `ENTRYPOINT []` — without it the empty entrypoint looks removable. An upstream file's heavy comment style (e.g. the `base-image` apko configs) is not a template to copy either. A file already being densely commented is **not** a license to add a change-justification comment; "match surrounding comment density" means idiomatic doc comments, not narrating your diff.
