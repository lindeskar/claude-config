# ADR fallback structure

Used by `rules/superpowers.md` when the target repo has no `docs/adr/TEMPLATE.md` of its own. Write to `docs/adr/YYYY-MM-DD-<slug>.md`, date = day started.

```markdown
# ADR: <feature title>
```

- `## Context` — what problem, who asked, why now; reconstructable six months later without external context
- `## Goal` — desired end state in 1-3 concrete, observable bullets
- `## Non-goals` — explicit scope cuts, so reviewers don't have to ask "are you also doing Z?"
- `## Approach` — chosen design and why it beats the alternatives considered; name the seam in the architecture being extended
- `## Affected files / packages` — concrete list; readers should be able to predict the implementation diff
- `## Risks & migrations` — permissions/scopes, new secrets or env vars, behaviour changes, backfills
- `## Verification` — unit tests, e2e, manual smoke commands, production verification
