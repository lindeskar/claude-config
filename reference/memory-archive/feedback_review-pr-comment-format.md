---
name: feedback_review-pr-comment-format
description: Preferred PR-comment format when posting output from the anthropic-review-pr:review-pr skill
metadata:
  type: feedback
---

When posting the result of the `anthropic-review-pr:review-pr` skill as a PR comment, wrap the review body in a collapsed `<details>` block instead of the skill's default markdown quote block (`> `-prefixed lines).

Structure:
- Prepend the marker line `` `/anthropic-review-pr:review-pr` output: `` (kept from the skill default).
- Blank line, then `<details>` with a one-line `<summary>` that states the reviewer scope and the headline verdict (e.g. "Code review (5 parallel reviewers: quality, performance, tests, docs, security) — no blocking issues").
- Blank line after `</summary>` so the markdown inside renders.
- Body grouped by severity (Critical / Warning / Suggestion) with `file:line` references, plus a short "Confirmed sound" section for checked non-issues.

**Why:** The collapsed block keeps a long review from dominating the PR thread while leaving the verdict visible in the summary line.

**How to apply:** Use this format by default for review-skill comments; don't ask which format to use. Confirmed on [annotell/kognic-github-app#340](https://github.com/annotell/kognic-github-app/pull/340).
