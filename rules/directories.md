# ~/Code Directory Structure

- `_forks/` — personal forks of public repos
- `_kognic/` — repos from the `annotell` GitHub org, manually cloned when needed (Claude may clone here)
- `_kognic_terraform/` — all terraform repos from the `annotell` GitHub org; bulk clone/git operations managed by shell scripts (see its CLAUDE.md)
- `_private/` — personal repos, manually cloned when needed (Claude may clone here)
- `_public/` — public repos, manually cloned when needed (Claude may clone here)
- `_tmp/` — scratch space (Claude may clone here)

## Accessing other repos

- Before using the GitHub API to browse a repo's contents, check if it's already cloned locally (e.g. `ls /Users/alex/Code/_kognic/<repo-name>`) — local reads are faster and don't burn API calls
- Always use `gh repo clone` — never `git clone`: `gh repo clone annotell/kognic-pubsub-python`
- Company repos (`annotell` org) go in `/Users/alex/Code/_kognic/`

## Finding repos, libraries, and packages

- First check the obvious location: the current repo's `.venv`, or `~/Code/_kognic/<repo-name>`
- If not found, **ask the user** — don't run broad `find` or `glob` searches across `~/Code` or `~/`
- Broad filesystem searches are slow, noisy, and often find stale copies in the wrong venv
