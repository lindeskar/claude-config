# ~/Code Directory Structure

- `_forks/` — personal forks of public repos
- `_kognic/` — company repos from the `annotell` **and** `kognic-internal` orgs, cloned when needed (Claude may clone here)
- `_kognic_terraform/` — all terraform repos from `annotell`; bulk clone/git operations managed by shell scripts (see its CLAUDE.md)
- `_private/` — personal repos (Claude may clone here)
- `_public/` — public repos (Claude may clone here)
- `_tmp/` — scratch space (Claude may clone here)

## Accessing other repos

- Before using the GitHub API to browse a repo, check whether it's already cloned locally (`ls ~/Code/_kognic/<repo>`) — local reads are faster and don't burn API calls.
- **Refresh local clones before reasoning about their current state — and for multi-repo "understand the pattern" tasks, `git pull` *every* involved repo up front, before deep-reading.** A stale tree produces confidently wrong claims and a wrong internal model you then design against (e.g. proposing to build a capability that already exists). `git fetch` + `git pull --ff-only` the default branch, or read `origin/<default>:<path>` if it isn't checked out or is dirty. Tells of a stale tree: file or directory names that don't match newer docs, superseded doc sets, "this is missing so I'll propose building it." Case studies: `reference/directories.md`.
- Always use `gh repo clone`, never `git clone`: `gh repo clone annotell/kognic-pubsub-python`.
- Company repos (`annotell` and `kognic-internal`) go in `~/Code/_kognic/`.

## Finding repos, libraries, and packages

- First check the obvious location: the current repo's `.venv`, or `~/Code/_kognic/<repo-name>`.
- If not found, **ask the user** — broad `find`/glob searches across `~/Code` or `~/` are slow, noisy, and often find stale copies in the wrong venv.
