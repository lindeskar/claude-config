# claude-config

Version-controlled source of truth for Claude Code configuration (`~/.claude`).

## Structure

- `global-CLAUDE.md` — the always-loaded core, symlinked as `~/.claude/CLAUDE.md`. Cross-cutting behaviour only: how we work together, git/PR invariants, the few verification principles that apply everywhere, environment facts.
- `rules/` — symlinked as `~/.claude/rules/`. Only **path-scoped** rules (`paths:` frontmatter) live here: they load when Claude reads a matching file. An unscoped rule loads every session and counts against the budget.
- `skills/` — symlinked as `~/.claude/skills/`, loaded on demand when the description matches. Topic knowledge goes here (verification, worktrees, PR conventions, observability, Kubernetes, GitHub API, Renovate, messaging, ADR/plan, retro). The description is what makes a skill fire: lead with what it is, then concrete triggers.
- `hooks/` — scripts referenced by `settings.json` hooks (draft-only PRs, unsigned-commit warning).
- `settings.json` — permissions, sandbox, plugins, hooks, `autoMemoryDirectory` (the work wiki's `memory/`). Symlinked as `~/.claude/settings.json`.
- `reference/` — war stories and long recipes; not auto-loaded.
- `Makefile` — `make link` and `make lint` (settings validation + always-loaded byte budget).

## Making changes

Route each new lesson to the cheapest durable home, in this order: a setting, permission or hook (deterministic) → the skill whose topic it is → a work-wiki memory entry → the core, only for cross-cutting behaviour and only by replacing an equally long line. The `retro` skill follows this order.

- Don't restate what the Claude Code system prompt, a tool description, a setting or a hook already enforces.
- State the goal or invariant plus its observable tell; no session anecdotes, dates or PR numbers as evidence; no CAPS/MUST.
- Run `make lint` before committing. The budget is deliberately tight; raise it only with a reason.
- Rollback point for the slim-down: tag `pre-diet-0`.
