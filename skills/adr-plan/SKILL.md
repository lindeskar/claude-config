---
name: adr-plan
description: >-
  The user's design-to-plan convention: settle intent, record the decision as an ADR in
  docs/adr/, then write a local-only implementation plan in docs/plans/. Use when asked to
  "design" something, "write an ADR", "plan this", "brainstorm", or before multi-step feature
  work in a repo that has docs/adr/.
---

# ADR and plan

## Does it need an ADR?

Write one when the change restructures components, alters an interface others depend on, or chooses between alternatives a later reader will ask "why this?" about. A bounded change to an existing flow gets a few sentences of design in chat, with no files. If hidden complexity appears mid-task, stop and step up.

## Settle intent first

Use plan mode or a short Q&A covering outcome, audience, success criteria and constraints. Ask only about gaps, one question at a time. Write back your understanding, keeping what the user said apart from your assumptions, and get it confirmed. Split work that spans independent subsystems into separate ADRs. Offer 2-3 approaches with a recommendation, and cut features nobody asked for.

## ADR

Path: `docs/adr/YYYY-MM-DD-<slug>.md`, dated the day work started. Follow the repo's `docs/adr/TEMPLATE.md` if it has one, otherwise use these sections:

- `# ADR: <title>`
- `## Context`: the problem, who asked, why now; self-contained
- `## Goal`: 1-3 observable end-state bullets
- `## Non-goals`: explicit scope cuts
- `## Approach`: the chosen design, why it beats the alternatives, and which seam it extends
- `## Affected files / packages`: enough that a reader can predict the diff
- `## Risks & migrations`: permissions, secrets, behaviour changes, backfills
- `## Verification`: tests, smoke commands, how to confirm in production

ADRs are committed and kept. When a decision proves wrong, write a new ADR that supersedes it; leave the old one unchanged.

## Plan

Path: `docs/plans/YYYY-MM-DD-<slug>.md`. Header: goal, approach, and `**Spec:** <ADR path>`. Tasks are `- [ ]` checkboxes, each naming exact files, independently testable, with no placeholders. Check that every ADR goal maps to a task.

Plans stay local: the global `~/.gitignore` excludes `docs/plans/` on purpose, so never stage or force-add one.

## Executing

Commit once per completed plan or milestone, not per task. For independent parts, consider subagents or a dynamic workflow (fan-out implementers plus an adversarial reviewer). This is a judgment call, not a fixed process.
