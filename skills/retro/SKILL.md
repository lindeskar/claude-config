---
name: retro
description: >-
  Close out a long or bumpy session: tidy what the session created, then propose at most three
  lessons, each routed to its cheapest durable home. Use when the user says "retro", "retrospective",
  "what did we learn", or at the end of a session that hit repeated failures, corrections or detours.
  Not for routine sessions. Use this rather than kognic-claude-toolkit:retrospective.
---

# Retro

The goal is fewer, better instructions, not more. "Nothing worth keeping" is a good outcome; say so and stop.

## 1. Tidy what this session created

Remove only things you can name as this session's own: worktrees and local branches by exact name, scratch files under `/tmp/claude`. Leave anything you can't attribute. The remote branch of an unmerged PR is the only copy of that work, so it stays. Confirm each removal took effect (`wt list`, `git branch`).

## 2. Find candidate lessons

A lesson qualifies only if both hold:

- a future session would plausibly get it wrong without it, and
- it isn't already written down.

Before proposing one, grep the always-loaded core (`~/.claude/CLAUDE.md`), the skills (`/Users/alex/Code/_private/claude-config/skills/`) and wiki memory (`/Users/alex/Code/_private/work/wiki/memory/`). If it was already covered and still got missed, report that as the finding (wrong home, weak wording, a skill that didn't fire) instead of adding a second copy.

Discard one-off fixes, things the code or git log already shows, and anything only this exact task would hit.

## 3. Route each lesson to the cheapest durable home

Take the first option that fits:

1. **Setting, permission or hook.** Deterministic, so it costs no attention.
2. **The skill whose topic it is.** Edit it in place, or sharpen its `description` if it should have fired and didn't.
3. **Wiki memory entry**: `/Users/alex/Code/_private/work/wiki/memory/<type>_<slug>.md`, one fact per file. Frontmatter is `name`, `description` (110 characters at most, because it becomes the index line), and `metadata.type`. Then run `uv run scripts/gen-memory-index.py` from `/Users/alex/Code/_private/work`.
4. **Always-loaded core.** Only for behaviour that cuts across every task, and only when you remove a line of equal length to make room.

Write the invariant and its observable tell, never the story. No dates, PR numbers or "this session" as evidence.

## 4. Propose, then wait

Present the tidy-up results and 0-3 proposals. For each one give the lesson in one line, where it goes and why, and the exact text. Wiki memory entries may be written straight away. Everything else (settings, skills, the core) waits for the user's go.

## 5. Commit

Commit wiki memory changes in `/Users/alex/Code/_private/work` with an explicit pathspec, covering only the files you wrote and the regenerated `MEMORY.md`. Leave claude-config changes uncommitted unless the user asks.
