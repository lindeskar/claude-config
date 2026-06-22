# Worktrees

> Terminology: the bullets below say `master`, but it means **the repo's default branch** — which is `main` in some repos (e.g. `lindeskar/work`) and `master` in others. Use whichever the current repo actually uses.

- Always create a worktree for feature work — never work directly on the default branch (`main`/`master`)
- **Exception**: personal repos under `lindeskar/*` (e.g. `lindeskar/work`, `lindeskar/dotfiles`, `lindeskar/claude-config`) have no build or CI — default to direct commit on main for docs, plans, designs, wiki pages, memory entries, and config snapshots. No worktree needed. When the repo uses GitHub Issues as a todo list (e.g. `lindeskar/work`), reference the issue in the commit message (e.g. `docs(plans): ... #61`)
- Create the worktree first, then make all edits there — don't edit in main checkout and copy files over
- **Update local master before creating a worktree.** `wt switch --create` branches from local `master`/`main`, not `origin/master`. If local is stale, the worktree starts behind and the PR is based on an outdated base. As a standalone Bash call before `wt switch --create`, update local master. `git fetch origin master:master` **fails whenever master is checked out in any worktree** — including the main checkout, which is the usual case in a worktree setup (`refusing to fetch into branch 'refs/heads/master' checked out at <path>`). The reliable path: `cd` to the checkout that holds master and run `git pull --ff-only`. If local master has diverged, resolve that first. **If the pull is blocked because the master checkout is dirty with unrelated changes that aren't yours** (e.g. a local `uv.lock` index-rewrite or untracked scratch files), don't stash or discard them — branch the worktree directly from the remote ref instead: `git fetch` then `git worktree add -b <branch> <path> origin/master`. That gets a current base and leaves the dirty checkout untouched (`wt switch --create` can't, since it always branches from local master).
- **Branch a PR from `origin/<base>`, not local `main`/`master`, when local is *ahead* of origin** (unpushed commits — common in `lindeskar/*` repos where the norm is direct-to-main commits that don't get pushed promptly). Otherwise those unrelated local commits ride into the PR as extra commits, and after a squash-merge local `main` diverges so `git pull --ff-only` fails. Recovery: confirm the changes are contained in the squash commit (`git log --oneline origin/main`), then `git reset --hard origin/main`. (The bullet above covers the opposite case — local *behind* origin.)
- Use `wt switch --create <branch>` to create worktrees (path template configured in worktrunk)
- **`wt` prints `mktemp: mkstemp failed … Operation not permitted` under the command sandbox but still succeeds.** Every `wt switch --create` / `wt remove` emits one or two of these lines, then the real result line (`✓ Created branch … and worktree @ …`, `◎ Removing … in background`). Treat the mktemp lines as harmless sandbox noise, not failure — trust the `✓`/`◎` line (or confirm with `wt list`). `wt switch --create` also can't `cd` the sandboxed shell (`▲ Cannot change directory — shell requires restart`); that's expected — `cd` into the printed worktree path yourself as the next standalone Bash call.
- Clean up after PR merge: `wt remove <branch>`. **Squash/rebase merges:** `wt remove` refuses (`Branch unmerged`) and removes only the worktree dir, leaving the branch — because the squashed/rebased commit hash never matches the local branch, so git's `--merged` check never sees it. After confirming the PR is merged (`gh pr view <n> --json state,mergedAt`), `git pull --ff-only` on master, then `wt remove -D <branch>` to force-delete the branch.
- **Don't push more commits to a branch after its PR is merged.** Origin auto-deletes the branch on merge, so `git push` succeeds but creates an orphan branch with the same name that is *not* attached to the closed PR. The PR's `head_sha` will not advance, and any new commits sit on a dangling ref. If you spot more work to do after a merge, start a fresh branch from updated master (`git pull --ff-only` → `wt switch --create`). When in doubt, `gh pr view <n> --json state` before pushing — `MERGED` means new commits need a new PR.
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
- The Edit tool's read-before-edit check is per absolute path: having Read a file in the *main checkout* does not allow editing the same file in the worktree — Edit fails with "File has not been read yet". If you explored files before creating the worktree, Read them again at the worktree path before editing
- To inspect another branch's files while in a worktree, prefer read-only access (`git show <ref>:<path>`, `git diff <a> <b> -- <path>`) over `cd`-ing to the main checkout. If you must `cd` out to look at master, `cd` back to the worktree *before* any write op — especially `git checkout <other-branch> -- <files>`, which silently modifies whichever working tree you're standing in

## Built-in alternative

Claude Code has its own worktree support, complementary to `wt`:

- `claude --worktree <name>` launches a session in `.claude/worktrees/<name>/` on branch `worktree-<name>` — useful for one-off isolated sessions
- `claude --worktree "#1234"` checks out a PR into `.claude/worktrees/pr-1234`
- Subagents can set `isolation: "worktree"` to get a throwaway worktree per agent run (cleaned up automatically if the agent made no changes)
- `.worktreeinclude` at the repo root (gitignore syntax) seeds gitignored files like `.env` into new worktrees — useful when a fresh checkout needs local config to run

`wt` remains the default for feature work — path template, merge/squash, and lifecycle hooks are already configured. Built-in worktrees live under `.claude/worktrees/`; `wt` uses `.worktrees/`. If you mix tools, expect two locations.
