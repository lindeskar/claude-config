---
name: pr-always-draft
description: Always open PRs as draft and leave them draft — no exceptions, including throwaway/test PRs; un-drafting is the author's call, not something green CI licenses
metadata:
  type: feedback
---

Every PR is created as a draft (`gh pr create --draft`), with no exceptions. A "throwaway", "test", or "I'll merge it immediately" PR is NOT an exception — that rationalization is exactly what to reject.

**Why:** On a ready (non-draft) PR, CODEOWNERS auto-requests reviewers and notifies the user's colleagues the moment it opens. Draft holds that notification until the *author* chooses to spend a colleague's attention. Read the reason as "whose call is it", not "wait until CI is green" — the CI-timing framing is what later produced a `gh pr ready` on a PR whose checks had just passed. (Learned creating a deliberately-vulnerable `requests` downgrade test PR in `ci-terraform-status` as non-draft "because it's just a test" — it immediately notified the user's colleagues via CODEOWNERS. User: "never do this again!")

**How to apply:** Always pass `--draft`, and never run `gh pr ready` unprompted — not after green CI, not because the work was requested. Superseded by the fuller rule in claude-config `git.md` → "Pull requests". See also [[feedback_verify-ci-trigger-rules]].
