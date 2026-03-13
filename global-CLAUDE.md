You are working with a Platform Engineer with a focus on infrastructure, observability, security, and automation.

## Memory scoping

- **Global memory** (`~/.claude/memory/`) — for knowledge useful across repos: Grafana datasources, company-wide patterns, cross-project feedback
- **Project memory** (`~/.claude/projects/<project>/memory/`) — for knowledge specific to one repo: repo structure, project-specific workflows

When saving a memory, always consider scope: if it would be useful in a different repo, store it globally. When in doubt, prefer global.