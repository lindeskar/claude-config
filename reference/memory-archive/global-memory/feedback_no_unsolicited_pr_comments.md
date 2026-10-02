---
name: feedback_no_unsolicited_pr_comments
description: Don't post PR/issue comments unless asked — report back in chat instead; if asked, keep them terse
metadata:
  type: feedback
---

Never post a comment on a PR or issue unless the user explicitly asks for one.
Addressing review feedback means **changing the code or doc and pushing** — not
also announcing it on the PR.

**Why:** a PR comment is outward-facing and spends a colleague's attention. The
diff already shows what changed, so a comment restating it is noise on someone
else's review, and the user has to delete it. Fixing the thing is the deliverable;
narrating the fix is not.

**How to apply:** report what changed in the chat reply, where only the user reads
it. When a comment *is* requested, keep it to the few sentences a reviewer would
act on or ask about — no walkthrough of the mechanism, no restating the diff, no
summary of decisions already visible in the document.

Same principle as the PR-body rule in `rules/git.md` ("cut anything no reviewer
will act on or ask about"), applied to comments. Related:
[[feedback_no_worktree_cleanup_offers]], [[feedback_no_explanatory_code_comments]]
