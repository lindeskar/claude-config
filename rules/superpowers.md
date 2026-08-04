# Superpowers Plugin Overrides

## Output locations and formats

Superpowers' default output paths (`docs/superpowers/specs/`, `docs/superpowers/plans/`) are overridden to match the ADR/plan convention in `annotell/kognic-github-app`. Keep the superpowers process (brainstorming → writing-plans → execution); only the artifacts change.

- **Brainstorming design output → ADR** at `docs/adr/YYYY-MM-DD-<slug>.md` (date = day started). Follow the repo's `docs/adr/TEMPLATE.md` if present; otherwise use the section structure in `reference/adr-template.md`.
- **Implementation plan → `docs/plans/YYYY-MM-DD-<slug>.md`.** Keep the superpowers plan format (header for agentic workers, tasks with `- [ ]` steps); add a `**Spec:**` link to the ADR.
- **Plans are local-only — don't commit them.** `docs/plans/` is excluded by the global `~/.gitignore` deliberately: the committed record is the ADR; the plan is a working artifact. Don't force-add past the ignore, and don't include `docs/plans` in `git add`.
- **ADR lifecycle:** ADRs are kept after implementation as the historical record. If a decision turns out wrong, don't rewrite it — add a follow-up ADR that supersedes it.

## Commit strategy

- No per-task commits during plan execution. Accumulate changes across tasks and make a single commit when the full plan (or a logical milestone) is complete, with a message summarizing all changes rather than listing each task.
