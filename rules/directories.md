# ~/Code Directory Structure

- `_forks/` — personal forks of public repos
- `_kognic/` — repos from the `annotell` GitHub org, manually cloned when needed (Claude may clone here)
- `_kognic_terraform/` — all terraform repos from the `annotell` GitHub org; bulk clone/git operations managed by shell scripts (see its CLAUDE.md)
- `_private/` — personal repos, manually cloned when needed (Claude may clone here)
- `_public/` — public repos, manually cloned when needed (Claude may clone here)
- `_tmp/` — scratch space (Claude may clone here)

## Cloning repos

- Always use `gh repo clone` — never `git clone`: `gh repo clone annotell/kognic-pubsub-python`
- Company repos (`annotell` org) go in `/Users/alex/Code/_kognic/`
