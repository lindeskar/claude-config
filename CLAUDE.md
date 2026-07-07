# claude-config

Version-controlled source of truth for Claude Code configuration (`~/.claude`).

## Structure

- `global-CLAUDE.md` — global developer instructions, symlinked as `~/.claude/CLAUDE.md` (loaded into every session)
- `rules/` — one markdown file per topic, symlinked as `~/.claude/rules/`. Claude Code auto-discovers every `.md` file under `~/.claude/rules/` and loads it at session start with the same priority as `CLAUDE.md`, no `@`-include needed. See [docs.claude.com/en/docs/claude-code/memory#user-level-rules](https://docs.claude.com/en/docs/claude-code/memory#user-level-rules).
- `settings.json` — permissions, plugins, and feature flags, symlinked as `~/.claude/settings.json`
- `reference/` — war-story archive backing the lean rules; **not** auto-loaded, read on demand (see its README)
- `Makefile` — setup automation and `make lint` (settings validation + always-loaded byte budget)

## Setup

```bash
make link
```

Symlinks all config files to `~/.claude/`. Refuses to overwrite existing files — remove them first if re-linking.

## Making Changes

- **Add a rule**: create a new `.md` file in `rules/` (one topic per file)
- **Edit permissions or plugins**: modify `settings.json`
- **Edit global instructions**: modify `global-CLAUDE.md`
- Changes take effect in the next Claude Code session

## Conventions

- Keep `global-CLAUDE.md` concise — it consumes context window in every session
- Rule files should be short and actionable — commands, not prose
- No rule should duplicate what a linter, formatter, or hook already enforces
- New learnings: add the one-line rule (plus the diagnostic "tell" if any) to `rules/`; put the full story in the matching `reference/` file, or in the work wiki when it's Kognic-specific. `make lint` enforces the byte budget.
