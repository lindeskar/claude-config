---
name: act-on-obvious-next-step
description: When a task has an obvious, mechanical, reversible next step that completes it (e.g. the deploy PR for a fix just released), do it as a draft PR — don't stop to ask "want me to open that PR?"
metadata:
  type: feedback
---

When executing a task that has an obvious, mechanical, low-risk step left to complete it — most often the **deploy/rollout PR that actually ships a fix I just merged and released** — open that PR (as a draft) and report, rather than stopping to ask "want me to do that?". If I can already state the exact change and have described it, that's the signal to act, not to ask.

**Why:** The user pointed me at the problem to fix it end-to-end; a merged-but-undeployed fix isn't done. Asking permission for the obvious completion — which I'd already spelled out in full, with a precedent PR to copy — reads as stalling. The user's words: *"yes, i expected you to do it."* A draft PR is reversible and takes effect only on the user-controlled merge, so the downside of just doing it is near-zero.

**How to apply:**
- If the next step is mechanical, unambiguous, and reversible (a draft PR that doesn't take effect until merged), execute it and report — don't gate it behind a question.
- This especially covers the "bump the consumer/template pin to the version I just released" follow-on (e.g. bumping `GH_SCRIPT_RUNNER_IMAGE_TAG` in `gitlab-ci-volcano` after a reporter release).
- **Boundary — "act" means *opening* the draft PR, never flipping it to ready.** `gh pr ready` is not an obvious next step; it spends a colleague's attention and belongs to the user (`rules/git.md` → "Pull requests"). Green CI does not convert it into one.
- **Boundary — this is NOT the multi-step prod-cutover case** (see [[multi-step-prod-approval]]). That gate still holds when the next step is a prod *apply* whose correctness depends on live-verifying the previous step. The line: opening a draft PR (reversible, user merges) → just do it; performing or sequencing an irreversible apply → pause for explicit approval.
