# claude-config

Version-controlled source of truth for Claude Code configuration (`~/.claude`).

## Structure

- `global-CLAUDE.md` — global developer instructions, symlinked as `~/.claude/CLAUDE.md` (loaded into every session)
- `rules/` — one markdown file per topic, symlinked as `~/.claude/rules/`. Claude Code auto-discovers every `.md` file under `~/.claude/rules/` and loads it at session start with the same priority as `CLAUDE.md`, no `@`-include needed. A rule with a `paths:` YAML frontmatter block is **path-scoped**: it loads only when Claude reads a matching file, and is excluded from the byte budget. See [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory).
- `skills/` — one directory per skill, each with a `SKILL.md`, symlinked as `~/.claude/skills/`. Skills load **on demand** rather than every session, so they hold topic knowledge you'd know to go looking for (observability queries, `gh` API traps, message drafting). `rules/skill-routing.md` indexes them — a skill nobody can find is knowledge deleted.
- `settings.json` — permissions, plugins, and feature flags, symlinked as `~/.claude/settings.json`
- `reference/` — war-story archive backing the lean rules; **not** auto-loaded, read on demand (see its README)
- `Makefile` — setup automation and `make lint` (settings validation + always-loaded byte budget)

## Setup

```bash
make link
```

Symlinks all config files to `~/.claude/`. Refuses to overwrite existing files — remove them first if re-linking.

## Making Changes

- **Add a rule**: create a new `.md` file in `rules/` (one topic per file). Ask first whether it must load *every* session — if you'd know to go looking for it when the topic came up, make it a skill or add `paths:` frontmatter instead.
- **Edit permissions or plugins**: modify `settings.json`
- **Edit global instructions**: modify `global-CLAUDE.md`
- Changes take effect in the next Claude Code session

## Conventions

- Keep `global-CLAUDE.md` concise — it consumes context window in every session
- Rule files should be short and actionable — commands, not prose
- No rule should duplicate what a linter, formatter, or hook already enforces
- New learnings: add the one-line rule (plus the diagnostic "tell" if any) to `rules/`; put the full story in the matching `reference/` file, or in the work wiki when it's Kognic-specific. `make lint` enforces the byte budget.
- **Never put a session anecdote in an always-loaded rule.** `rules/durable-writing.md` is a small fraction of the corpus, so a violation left in a sibling rule teaches the next session to violate it. Fix it in place rather than writing alongside it.
