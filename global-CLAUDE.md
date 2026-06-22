You are working with a Platform Engineer with a focus on infrastructure, observability, security, and automation.

## Memory scoping

- **Global memory** (`~/.claude/memory/`) — for knowledge useful across repos: Grafana datasources, company-wide patterns, cross-project feedback
- **Project memory** (`~/.claude/projects/<project>/memory/`) — for knowledge specific to one repo: repo structure, project-specific workflows

When saving a memory, always consider scope: if it would be useful in a different repo, store it globally. When in doubt, prefer global.

- For work-related tasks, project-scoped memory is routed to the work wiki instead — see the **Work wiki** section below for the trigger and exact path.

## Work wiki

`~/Code/_private/work/wiki/` is the long-term memory for work-related tasks. Consult and update it whenever work at Kognic is in scope — regardless of which repo is the current working directory.

**Default trigger — path-based.** Treat the task as work-related when CWD is under:
- `~/Code/_kognic/`
- `~/Code/_kognic_terraform/`
- `~/Code/_private/work/`

**Override verbs.** In any other context, assume not work unless the user says so:
- User says "this is work" → treat as work-related.
- User says "not work" / "don't touch the wiki" → skip wiki reads/writes.

**Operations.** Read `~/Code/_private/work/wiki/CLAUDE.md` for ingest/query/lint details.

**Memory routing.** When the task is work-related (by trigger above), project-scoped memory writes go to `~/Code/_private/work/wiki/memory/` instead of `~/.claude/projects/<project>/memory/`. The auto-memory rules otherwise behave as normal (file shape, MEMORY.md index, global vs. project split).

**Private vs team — write heuristic.** Two of the registered wikis (see **Knowledge wikis** below) hold work knowledge: `my-work` (private, yours alone — operational memory, half-formed findings, "how *I* verify X") and `platform-team` (shared platform-team reference, reviewed via PR). One test: *would a teammate benefit, and is it correct and durable?* → `platform-team` (PR). *Just for me / not yet proven / operational memory?* → `my-work`. The private wiki is the staging ground — promote matured notes to the team wiki via PR (re-expressed cleanly), and never reference the private wiki or any `lindeskar/*` repo from a company repo.

## Knowledge wikis

Registry for the `kognic-claude-wiki:knowledge-wiki` skill — it selects the wiki whose `use:` fits the task (asking if ambiguous), writes OKF-conformant pages, and commits per `write:`. If this list is empty the skill asks and adds an entry. One entry per line:

- **platform-team** — `kognic-internal/devplat` · path `docs/wiki/` · write: pr · use: durable platform-team reference knowledge, shared with the team
- **my-work** — `lindeskar/work` · path `wiki/` · write: direct · use: my private work memory, operational notes, half-formed findings
- **personal** — `lindeskar/wiki` · path `.` · write: direct · use: personal non-work knowledge (cars, finance, home, civic)

**Freshness — refresh the clone before reading or writing.** A local clone drifts from the remote between sessions, so the working tree may be stale. Before consulting or editing a registered wiki: in the main checkout, `git fetch`, then `git pull --ff-only` the default branch when it's checked out and clean; if it isn't, read pages straight from the remote ref (`git show origin/<default>:<path>`) rather than the stale working tree. For writes, branch the worktree from `origin/<default>` (see `rules/worktrees.md`) so the base is current regardless of local state. This matters most for the shared **`platform-team`** wiki — teammates change it between sessions — but still catches edits made from another machine on the single-author `my-work`/`personal` wikis.