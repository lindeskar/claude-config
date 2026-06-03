# Superpowers Plugin Overrides

## Output locations and formats

Superpowers' default output paths (`docs/superpowers/specs/`, `docs/superpowers/plans/`) are overridden to match the ADR/plan convention used in `annotell/kognic-github-app` (which follows the mattpocock/skills workflow). Keep using the superpowers process (brainstorming → writing-plans → execution); only the artifacts change:

- **Brainstorming design output → ADR.** Write to `docs/adr/YYYY-MM-DD-<slug>.md` (date = day started, slug describes the feature). If the repo has a `docs/adr/TEMPLATE.md`, follow it. Otherwise use this section structure:
  - `# ADR: <feature title>`
  - `## Context` — what problem, who asked, why now; reconstructable six months later without external context
  - `## Goal` — desired end state in 1-3 concrete, observable bullets
  - `## Non-goals` — explicit scope cuts, so reviewers don't have to ask "are you also doing Z?"
  - `## Approach` — chosen design and why it beats the alternatives considered; name the seam in the architecture being extended
  - `## Affected files / packages` — concrete list; readers should be able to predict the implementation diff
  - `## Risks & migrations` — permissions/scopes, new secrets or env vars, behavior changes, backfills
  - `## Verification` — unit tests, e2e, manual smoke commands, production verification
- **Implementation plan → `docs/plans/YYYY-MM-DD-<slug>.md`.** Keep the superpowers plan format (header for agentic workers, tasks with `- [ ]` checkbox steps); add a `**Spec:**` link to the ADR.
- **ADR lifecycle:** ADRs are kept after implementation as the historical record. If a decision turns out wrong, don't rewrite the ADR — add a follow-up ADR that supersedes it.

## Commit strategy

- Do NOT make per-task commits during plan execution
- Accumulate all changes across tasks and make a single commit when the full plan (or a logical milestone) is complete
- The single commit message should summarize all changes, not list each task
