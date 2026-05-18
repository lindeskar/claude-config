# Worktrees

- Always create a worktree for feature work — never work directly on main/master
- **Exception**: personal repos under `lindeskar/*` (e.g. `lindeskar/work`, `lindeskar/dotfiles`, `lindeskar/claude-config`) have no build or CI — default to direct commit on main for docs, plans, designs, wiki pages, memory entries, and config snapshots. No worktree needed. When the repo uses GitHub Issues as a todo list (e.g. `lindeskar/work`), reference the issue in the commit message (e.g. `docs(plans): ... #61`)
- Create the worktree first, then make all edits there — don't edit in main checkout and copy files over
- **Update local master before creating a worktree.** `wt switch --create` branches from local `master`/`main`, not `origin/master`. If local is stale, the worktree starts behind and the PR is based on an outdated base. Run `git fetch origin master:master` (works from any branch when master is fast-forward-only) as a standalone Bash call before `wt switch --create`. If local master has diverged, resolve that first.
- Use `wt switch --create <branch>` to create worktrees (path template configured in worktrunk)
- Clean up after PR merge: `wt remove <branch>`
- Use `wt list` to check worktrees and `wt switch` to navigate between them
- Stay contained — never touch files in the main checkout or other worktrees
- When editing a PR in another repo, `cd` to that repo and run `wt list` to find existing worktrees — don't use `gh pr checkout`
- For detailed worktrunk usage, invoke the `worktrunk:worktrunk` skill

## Working directory in worktrees

After creating a worktree, immediately `cd` into it as a **standalone Bash call** — this sets the persistent working directory for all subsequent tool calls (Bash, Glob, Grep, Read, Edit, Write).

```
# CORRECT — standalone cd, then run commands normally
Bash: cd /path/to/worktree
Bash: git status

# WRONG — cd chained with another command (directory reverts after)
Bash: cd /path/to/worktree && git status
```

- Run `cd` alone — never chain it with `&&` or `;` (see `tooling.md` for the general no-composite-commands rule)
- Do this once right after `wt switch --create`, then all subsequent commands run in the worktree
- If you lose track of the working directory, run `pwd` to check and `cd` again if needed

## Built-in alternative

Claude Code has its own worktree support, complementary to `wt`:

- `claude --worktree <name>` launches a session in `.claude/worktrees/<name>/` on branch `worktree-<name>` — useful for one-off isolated sessions
- `claude --worktree "#1234"` checks out a PR into `.claude/worktrees/pr-1234`
- Subagents can set `isolation: "worktree"` to get a throwaway worktree per agent run (cleaned up automatically if the agent made no changes)
- `.worktreeinclude` at the repo root (gitignore syntax) seeds gitignored files like `.env` into new worktrees — useful when a fresh checkout needs local config to run

`wt` remains the default for feature work — path template, merge/squash, and lifecycle hooks are already configured. Built-in worktrees live under `.claude/worktrees/`; `wt` uses `.worktrees/`. If you mix tools, expect two locations.
