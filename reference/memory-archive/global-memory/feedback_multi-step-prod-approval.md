---
name: multi-step-prod-approval
description: For multi-step prod operations (e.g. Terraform blue/green migrations across many PRs), wait for explicit user approval between each step — don't stage the next PR or proceed even after the current one is merged.
metadata:
  type: feedback
---

When executing a multi-step production change that spans multiple PRs and Terraform applies (e.g. VKE blue/green cluster swap per the Notion runbook), do **one PR at a time** and stop after each. Wait for explicit user approval before starting the next step.

**Why:** Each apply in this kind of flow has to be verified live (cluster state, addon compatibility, traffic routing, ArgoCD sync) before the next step is safe. Pre-staging "ready-to-apply" PRs invites a wrong-order apply or a stale plan if the prior step needed adjustment. The user wants the gate explicit, not implicit-on-merge.

**How to apply:**
- After opening/landing each step's PR, stop and report. Do not start the next step's worktree, branch, or PR until told.
- Don't pre-stage a draft "step N+1" PR ahead of time, even if "ready to apply after #N lands" feels helpful — see [[prod-multi-step-approval]] reason above.
- Applies between steps (e.g. comp-cloud Terraform applies) are done by the user, not by me; confirm the prior apply succeeded and the new cluster/state is healthy before moving on.
- Surfaces beyond Terraform blue/green: the same gate applies to staged DB migrations, cutover PRs across repos, or any change where the next PR's correctness depends on the previous one having been applied and verified.
