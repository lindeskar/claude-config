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

**Two work knowledge stores — private vs team.** There are now two places work knowledge can live:

- **Private work wiki** (`~/Code/_private/work/wiki/`) — yours alone. Operational memory, half-formed findings, "how *I* verify X", anything not yet team-ready. Written freely, direct commit.
- **Team wiki** — `kognic-internal/devplat`, `docs/wiki/` (locally `~/Code/_kognic/devplat/docs/wiki/`), in Open Knowledge Format. Durable, correct reference knowledge the whole platform team benefits from. Changed via reviewed PR only. Operations: see `docs/wiki/README.md` in that repo.

**Write heuristic.** One test: *would a teammate benefit, and is it correct and durable?* → propose it to the team wiki (PR). *Just for me / not yet proven / operational memory?* → private work wiki.

**Promotion.** The private work wiki is the staging ground. When a note matures and generalizes, promote it into the team wiki via PR and trim the private entry to a pointer. Never reference the private wiki or any `lindeskar/*` repo from a company repo (PRs, commits, docs, comments) — promotion means re-expressing the knowledge cleanly, not linking back.