# ~/Code Directory Structure

- `_forks/` — personal forks of public repos
- `_kognic/` — company repos from the `annotell` **and** `kognic-internal` GitHub orgs, manually cloned when needed (Claude may clone here)
- `_kognic_terraform/` — all terraform repos from the `annotell` GitHub org; bulk clone/git operations managed by shell scripts (see its CLAUDE.md)
- `_private/` — personal repos, manually cloned when needed (Claude may clone here)
- `_public/` — public repos, manually cloned when needed (Claude may clone here)
- `_tmp/` — scratch space (Claude may clone here)

## Accessing other repos

- Before using the GitHub API to browse a repo's contents, check if it's already cloned locally (e.g. `ls /Users/alex/Code/_kognic/<repo-name>`) — local reads are faster and don't burn API calls
- **Refresh a local clone before reasoning about its *current* state — especially before asserting what a repo does or doesn't contain.** A working tree drifts behind `origin` between sessions, so reading it stale can produce a confidently wrong claim. `git fetch` + `git pull --ff-only` the default branch (or read `origin/<default>:<path>` if it isn't checked out / is dirty) first. (Learned asserting "the GPU nodepool isn't in terraform at all" from a `terraform-devplat-comp-volcano` working tree that was several commits behind `origin/master`; the nodepool had been added in three merged PRs — the user corrected me.)
- **For a "help me understand / establish the pattern" task spanning several repos, `git pull` *every* involved repo up front, before deep-reading — not just fetch, and not lazily per-file.** A stale tree doesn't only produce wrong assertions to the user; it produces a wrong *internal model* you then design against. The tells that you're on a stale tree: file/dir names that don't match newer docs, superseded doc sets, "this capability is missing so I'll propose building it." (Learned mapping the Keycloak SSO onboarding flow across `terraform-identity` + `user-scala` + `terraform-modules-keycloak`: I explored the stale trees first and was about to propose *building* an `external-oidc-idp` module — the user said "pull latest master", and it already existed at tag `1.1.1`, alongside directory renames and a CI-apply migration I'd have missed.)
- Always use `gh repo clone` — never `git clone`: `gh repo clone annotell/kognic-pubsub-python`
- Company repos (`annotell` and `kognic-internal` orgs) go in `/Users/alex/Code/_kognic/` (e.g. `kognic-internal/devplat`, `kognic-internal/claude-plugins`)

## Finding repos, libraries, and packages

- First check the obvious location: the current repo's `.venv`, or `~/Code/_kognic/<repo-name>`
- If not found, **ask the user** — don't run broad `find` or `glob` searches across `~/Code` or `~/`
- Broad filesystem searches are slow, noisy, and often find stale copies in the wrong venv
