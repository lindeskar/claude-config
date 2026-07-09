# Worktrees

> "master" below means **the repo's default branch** (`main` in some repos, `master` in others). Full war stories: `reference/worktrees.md` in this repo (not auto-loaded).

- Always create a worktree for feature work — never work directly on the default branch. **Exception**: personal repos under `lindeskar/*` have no build/CI — default to direct commit on main for docs, plans, designs, wiki pages, memory entries, and config snapshots. When the repo uses GitHub Issues as a todo list (`lindeskar/work`), reference the issue in the commit message (e.g. `docs(plans): ... #61`).
- Create the worktree first, then make all edits there — don't edit in the main checkout and copy over.
- **Update local master before creating a worktree** — `wt switch --create` branches from *local* master. `git fetch origin master:master` fails whenever master is checked out anywhere; the reliable path is `cd` to the checkout holding master and `git pull --ff-only`. If that checkout is dirty with changes that aren't yours, don't stash/discard — branch directly from the remote ref instead: `git fetch`, then `git worktree add -b <branch> <path> origin/master`. **On release-please / floating-major-tag repos (the `gha-*` action repos) this `git pull --ff-only` *fails* with `! [rejected] v1 -> v1 (would clobber existing tag)` — don't swallow the output (`-q`, `| tail -1`) or you'll branch from a stale master and hit an avoidable merge conflict later.** Recover with git.md's recipe (`git fetch origin --tags --force`, then pull) *before* `wt switch --create`.
- **Branch from `origin/<base>` when local master is *ahead* of origin** (unpushed commits — common in `lindeskar/*` repos), or unrelated local commits ride into the PR. Recovery after a squash-merge divergence: confirm the changes landed in the squash commit, then `git reset --hard origin/main`.
- Use `wt switch --create <branch>` to create worktrees; `wt list` to inspect; `wt switch` to navigate. For detailed worktrunk usage, invoke the `worktrunk:worktrunk` skill.
- **`wt` under the sandbox prints `mktemp: mkstemp failed … Operation not permitted` but still succeeds** — trust the `✓`/`◎` result line (or `wt list`). It also can't `cd` the sandboxed shell (`▲ Cannot change directory`); `cd` into the printed path yourself as the next standalone Bash call.
- Clean up after PR merge: `wt remove <branch>`. **Squash/rebase merges:** `wt remove` refuses (`Branch unmerged` — the squashed hash never matches). Confirm the PR is merged (`gh pr view <n> --json state,mergedAt`), `git pull --ff-only` on master, then `wt remove -D <branch>`.
- **Don't push more commits to a branch after its PR is merged** — origin auto-deleted the branch, so the push creates an orphan not attached to the PR. New work → fresh branch from updated master. This includes merges *you* didn't make: after any conversational gap, `gh pr view <n> --json state` before pushing.
- **Bulk worktree cleanup: match branches by *exact* names** (or an anchored regex of the names you created), never a broad substring — loose globs match unrelated worktrees and can destroy unpushed work.
- Stay contained — never touch files in the main checkout or other worktrees.
- Reviewing/editing a PR in another repo: `cd` there and `wt list` first — there's usually already a worktree. Reading the diff needs no checkout (`gh pr diff <n>`); reading files at PR HEAD → the existing worktree, `gh api …/contents/<path>?ref=pull/<n>/head`, or `claude --worktree "#<n>"`. Never `gh pr checkout` (clobbers the main worktree's HEAD) and never fetch+checkout a PR branch in the main repo path.

## Working directory in worktrees

After creating a worktree, immediately `cd` into it as a **standalone Bash call** (never chained — chained `cd` reverts after the command); that sets the persistent working directory for all subsequent tool calls. `pwd` if you lose track.

- The Edit tool's read-before-edit check is per absolute path: having Read a file in the main checkout does not allow editing it in the worktree — Read it again at the worktree path.
- To inspect another branch's files, prefer read-only access (`git show <ref>:<path>`, `git diff <a> <b> -- <path>`) over `cd`-ing out. If you must `cd` out, `cd` back *before* any write op — especially `git checkout <branch> -- <files>`, which modifies whichever tree you're standing in.

## Built-in alternative

Claude Code's own worktrees are complementary to `wt`: `claude --worktree <name>` (session in `.claude/worktrees/<name>/`), `claude --worktree "#1234"` (PR checkout), subagent `isolation: "worktree"` (throwaway, auto-cleaned), `.worktreeinclude` (seeds gitignored files like `.env` into new worktrees). `wt` remains the default for feature work — its path template, merge/squash, and lifecycle hooks are already configured. `wt` uses `.worktrees/`; built-ins use `.claude/worktrees/`.
