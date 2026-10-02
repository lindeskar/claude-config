---
name: verify-ci-trigger-rules
description: Before creating a "dummy" / test PR whose purpose is to trigger CI, read the pipeline's trigger conditions (path filters, branch rules, etc.) and pick a change that satisfies them — don't just touch an arbitrary file.
metadata:
  type: feedback
---

When the user asks for a test/dummy PR to verify CI changes, the FIRST step is to read the CI config and confirm what kind of change actually triggers the jobs you want to exercise. Many pipelines are gated on path filters or compare-to-base rules; a change outside those paths produces a green PR that ran nothing useful.

**Why:** Got burned in annotell/terraform-devplat-volcano#389 — I added an override line to `.gitlab-ci.yml` and pushed, but the gitlab-ci-volcano template's `terraform-plan-*` / `github-status-*` jobs are all gated on `$TF_PATH/**/*` changes (compared to master for PR branches), so a `.gitlab-ci.yml`-only change runs nothing. User had to correct me with "the CI is conditional". The fix was a trailing newline in `devplat-pub-base/outputs.tf` — i.e. *inside* one of the TF state paths declared in the include.

**How to apply:**
- Before pushing a test PR, read the jobs you expect to run and confirm their `rules:` / `on:` / `if:` conditions match your change.
- For GitLab `.gitlab-ci.yml`/template components: look for `changes:` blocks with `paths:` — a `.gitlab-ci.yml`-only change does *not* satisfy a `$VAR/**/*` rule.
- For GitHub Actions: look at `on.*.paths` and `on.*.branches` filters in the workflow.
- For monorepos with per-package CI: confirm which package directory you need to touch.
- Specifically for `annotell/gitlab-ci-volcano/templates/terraform.yml`: all `terraform-plan-*`, `terraform-apply-*`, and `github-status-*` jobs are gated on `$TF_PATH/**/*`. The right "dummy" change is whitespace inside one of the `TF_PATHS` directories declared in the consuming repo's `.gitlab-ci.yml` include.
