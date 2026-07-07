---
name: cross-repo-issue-refs
description: In GitHub comments/bodies, a bare #123 autolinks within the current repo — fully-qualify cross-repo references as owner/repo#123 or they break.
metadata:
  type: feedback
---

When a GitHub comment, issue, or PR body references a PR/issue in a **different** repo, write the fully-qualified `owner/repo#123` (e.g. `annotell/kognic-cd#2011`). A bare `#123` autolinks to issue/PR 123 in the *current* repo, so it renders as a wrong/broken link.

**Why:** This bites the `lindeskar/work` → company-PR cross-linking workflow constantly — the personal issue lives in `lindeskar/work`, so bare `#67` points at `lindeskar/work#67`, not the company PR. The user had to correct this on issue #74.

**How to apply:**
- Cross-linking a company PR from a personal issue (or any repo→other-repo): use `annotell/<repo>#<n>` / `kognic-internal/<repo>#<n>`.
- Confirm the org with `git remote get-url origin` if unsure (most Kognic repos are `annotell`; see [[reference_github_orgs]]).
- Still never reference `lindeskar/work` *inside* company repos — cross-linking is one-directional (personal → company only).
