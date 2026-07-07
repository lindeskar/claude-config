---
name: pr-always-draft
description: Always open PRs as draft — no exceptions, including throwaway/test PRs; ready PRs fire CODEOWNERS review-requests + notify colleagues before CI finishes
metadata:
  type: feedback
---

Every PR is created as a draft (`gh pr create --draft`), with no exceptions. A "throwaway", "test", or "I'll merge it immediately" PR is NOT an exception — that rationalization is exactly what to reject.

**Why:** On a ready (non-draft) PR, CODEOWNERS auto-requests reviewers and notifies the user's colleagues the moment it opens — before CI has run to completion. Draft holds that notification until the author marks it ready, so CI finishes first and colleagues aren't pinged prematurely about a PR that may still be red or short-lived. (Learned creating a deliberately-vulnerable `requests` downgrade test PR in `ci-terraform-status` as non-draft "because it's just a test" — it immediately notified the user's colleagues via CODEOWNERS. User: "never do this again!")

**How to apply:** Always pass `--draft`. The author marks it ready when they choose. Reinforces the standing rule in claude-config `git.md` ("Always create PRs in draft mode"). See also [[feedback_verify-ci-trigger-rules]].
