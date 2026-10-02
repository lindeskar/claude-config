---
name: Scan for shared secrets before webhook rotation
description: Before rotating a GitHub webhook secret at Kognic, enumerate every webhook that validates against the same GSM/k8s secret — not just the ones named in a notification
type: feedback
---

Before rotating any GitHub webhook secret, enumerate every webhook that shares the same underlying secret on the receiving side. Plan to rotate all of them together, not just the ones named in an advisory.

**Why:** During the April 2026 rotation of the two `annotell/kognic-cd` webhooks named in GitHub's leaked-secret advisory, rotating the shared ArgoCD secret (`argocd_github_webhook` in GSM `annotell-com`, synced to `argocd/argocd-client-secret` → referenced by `argocd-secret`) invalidated every other GitHub webhook pointing to the same ArgoCD server — the staging ArgoCD hook at `argocd-webook.staging.kognic.io`, and all webhooks in `annotell/k8s-platform-gitops`. Those weren't in the advisory list but broke on rotation and had to be fixed reactively.

**How to apply:** When given a webhook-rotation task, before touching the GSM secret:
1. Find the receiving service's k8s Secret and see if a single value is used by multiple GitHub webhooks (same URL pointing to the same validator = shared secret).
2. For ArgoCD specifically, the webhook secret is shared across every repo whose hook points at that ArgoCD instance. Rotating the GSM secret requires updating every GitHub hook that targets that ArgoCD.
3. Build the full list of affected GitHub hooks first (across all repos, not just the advisory's), then rotate GSM + all GitHub hooks in one coordinated sweep.
