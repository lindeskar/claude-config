---
name: feedback_docs-omit-rejected-alternatives
description: In durable docs (README, preset/config description fields), don't document why an alternative was rejected or why something is excluded from a rule — that's PR-description material; keep the doc to what the thing does plus the invariants
metadata:
  type: feedback
---

Durable docs state **what the thing does and which invariants must not be broken**. They do not carry the deliberation that produced it: why the neighbouring option was *not* also matched, why a rejected alternative was rejected, or why a scope was narrowed. The user calls this an anti-pattern — "don't document point-in-time things that could have been a PR description or comment" — and separately flagged the resulting prose as "way too long".

**Why:** exclusion rationale answers a question only the author was asking, at the moment of authoring. A reader six months later needs the rule and its constraints, not the road not taken. Length costs attention on every future read, and git blame plus the PR already hold the reasoning.

**How to apply:** put "why not X" in the PR description, where it genuinely helps a reviewer. Keep in the doc only: what it does, and anything a future editor could silently break (ordering that makes an override work, an omitted field whose presence would collide with another rule). Cut sentences of the form "not Y, because Y would…" and "Z is the wrong tool for this". Also check the file's own convention before adding a `description` at all — sibling entries that carry none are telling you rationale lives in the README instead.

Same principle as [[feedback_no_explanatory_code_comments]], applied to prose docs and to config `description` fields rather than inline comments. Reinforces the `durable-writing.md` rule's "keep it short" and "no point-in-time observations".
