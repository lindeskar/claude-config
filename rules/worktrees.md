# Worktrees

- Always create a worktree for feature work — never work directly on main/master
- **Exception**: personal repos under `lindeskar/*` (e.g. `lindeskar/work`, `lindeskar/dotfiles`, `lindeskar/claude-config`) have no build or CI — default to direct commit on main for docs, plans, designs, wiki pages, memory entries, and config snapshots. No worktree needed. When the repo uses GitHub Issues as a todo list (e.g. `lindeskar/work`), reference the issue in the commit message (e.g. `docs(plans): ... #61`)
- Create the worktree first, then make all edits there — don't edit in main checkout and copy files over
- **Update local master before creating a worktree.** `wt switch --create` branches from local `master`/`main`, not `origin/master`. If local is stale, the worktree starts behind and the PR is based on an outdated base. As a standalone Bash call before `wt switch --create`: from a feature branch run `git fetch origin master:master`; **if master is the currently checked-out branch this fails** (`refusing to fetch into branch 'refs/heads/master'`) — use `git pull --ff-only` instead. If local master has diverged, resolve that first.
- Use `wt switch --create <branch>` to create worktrees (path template configured in worktrunk)
- Clean up after PR merge: `wt remove <branch>`
- Use `wt list` to check worktrees and `wt switch` to navigate between them
- Stay contained — never touch files in the main checkout or other worktrees
- When reviewing or editing a PR in another repo, `cd` to that repo and run `wt list` first to find an existing worktree for the PR branch. Never check out the PR in the main repo path — it pollutes the default checkout, leaves cleanup work, and there's almost always already a worktree.
  - **Reading the diff:** `gh pr diff <n>` is enough — no checkout needed.
  - **Reading files at PR HEAD:** if `wt list` finds a worktree, `cd` there; otherwise use `gh api repos/.../contents/<path>?ref=pull/<n>/head` or `claude --worktree "#<n>"` for a sandboxed checkout under `.claude/worktrees/pr-<n>/`.
  - Do not use `gh pr checkout` (clobbers the main worktree's HEAD), and do not `git fetch + git checkout` a PR branch in the main repo path.
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
