---
name: confirm-cause-before-remediating
description: Don't ship a mitigation for the component that merely *differs* from the last good run until you've confirmed it's actually the cause
metadata:
  type: feedback
---

Separate "what changed / differs from the last good run" from "what *caused* this failure." Only remediate a component once you've confirmed it is causal — don't pin/revert/pre-empt the merely-suspicious thing.

On 2026-07-09 the `gha-k8s-gitops` copy-and-sign CI failed. I correctly traced it to a GitHub Actions/OIDC incident, but *also* built and pushed a cosign `v3.0.6` pin because master carried a renovate-auto-merged cosign `v3.1.1` — the component that was *different*. The user pushed back: "if you're not sure that's why it failed, leave it." v3.1.1 had only ever run via a fallback *during* the outage and never under healthy OIDC, so it was correlated-but-unconfirmed, not the cause. I reverted the pin; the real fix was hardening the failure path.

**Why:** remediating the merely-different component adds unvalidated change and noise to the fix, can mask the real cause, and commits the team to a rollback that may be wrong.

**How to apply:** when a run fails, list what differs from the last green run, then for each ask "have I confirmed this is causal, or just that it's present?" If unconfirmed, say so explicitly and leave it alone — harden the actual observed failure path, or re-run to confirm the failure is transient, before touching the suspect. See also [[verify-claims-against-source-not-docs]], [[cheapest-interpretation-first]].
