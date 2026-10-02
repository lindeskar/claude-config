---
name: feedback_no-hard-wrap-in-pr-bodies
description: Don't hard-wrap prose in PR/issue/discussion bodies — one line per paragraph or bullet; GitHub reflows markdown itself
metadata:
  type: feedback
---

Write each paragraph and each bullet in a PR, issue or discussion body as a single unwrapped line. Don't break prose at ~70–80 columns the way a commit-message or git-tool convention would.

**Why:** GitHub renders markdown and reflows text to the reader's width. Hard wraps add nothing there, and they make the body awkward to edit and to diff when it's revised. The user noticed a ~70-column wrapped Renovate PR body and asked for it not to happen again.

**How to apply:** Before posting a body drafted by an agent or copied from a commit-style draft, check for mid-sentence line breaks and join them. Leave code blocks, tables and lists that are genuinely line-structured as they are. Templates that already use one sentence per line (e.g. Renovate's PR template) can stay as they are. Related: [[feedback_pr-body-present-tense-capitalize-resource-types]].
