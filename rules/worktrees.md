# Worktrees

> "master" below means **the repo's base branch**. Full war stories: `reference/worktrees.md` (not auto-loaded).

- Always create a worktree for feature work — never work directly on the default branch. **Exception**: personal repos under `lindeskar/*` have no build or CI — default to direct commit on main for docs, plans, wiki pages, memory entries, and config snapshots. In `lindeskar/work`, reference the todo issue in the commit message.
- Create the worktree first, then make all edits there — don't edit in the main checkout and copy over.
- **The base branch is not always the default branch.** Read the repo's own instructions (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`) — `gh repo view --json defaultBranchRef` tells you the default, not where work lands. Branch from that branch and target it in the PR. Known case: **`annotell/frontend-annotation` integrates on `next`**. Applies to audits and scans too, or findings it already fixed look outstanding.
- **Update local master before creating a worktree** — `wt switch --create` branches from *local* master. `git fetch origin master:master` fails whenever master is checked out anywhere; instead `cd` to the checkout holding master and `git pull --ff-only`. If that checkout is dirty with changes that aren't yours, don't stash or discard — branch from the remote ref: `git fetch`, then `git worktree add -b <branch> <path> origin/master`.
- **On release-please / floating-major-tag repos (the `gha-*` action repos) that pull *fails*** with `! [rejected] v1 -> v1 (would clobber existing tag)`. Don't swallow the output (`-q`, `| tail -1`) or you'll branch from a stale master. Recover with git.md's recipe (`git fetch origin --tags --force`, then pull) *before* `wt switch --create`.
- **Branch from `origin/<base>` when local master is *ahead* of origin** (unpushed commits, common in `lindeskar/*`), or unrelated local commits ride into the PR. After a squash-merge divergence: confirm the changes landed in the squash commit, then `git reset --hard origin/main`.
- `wt switch --create <branch>` to create, `wt list` to inspect, `wt switch` to navigate. Details: the `worktrunk:worktrunk` skill.
- **`wt` under the sandbox prints `mktemp: mkstemp failed … Operation not permitted` but still succeeds** — trust the `✓`/`◎` result line, or `wt list`. It also can't `cd` the sandboxed shell; `cd` into the printed path yourself as the next standalone call.
- **PR closed *unmerged*: clean up the local worktree and branch, but don't delete the *remote* branch unless asked.** A merged PR's branch is auto-deleted by origin and its commits live on master; an unmerged one's remote branch is the only surviving copy, so deleting it is destructive and outside a "close the PR" request. Generally: finishing a task doesn't authorize tidy-up the user didn't ask for.
- Clean up after merge with `wt remove <branch>`. **Squash/rebase merges:** it refuses (`Branch unmerged` — the squashed hash never matches). Confirm the PR is merged, `git pull --ff-only` on master, then `wt remove -D <branch>`.
- **Don't push more commits to a branch after its PR is merged** — origin auto-deleted the branch, so the push creates an orphan not attached to the PR. New work → fresh branch from updated master. Includes merges *you* didn't make: after any conversational gap, check `gh pr view <n> --json state` before pushing.
- **Bulk cleanup: match branches by *exact* names** (or an anchored regex of the names you created), never a broad substring — loose globs match unrelated worktrees and can destroy unpushed work.
- Stay contained — never touch files in the main checkout or other worktrees.
- Reviewing a PR in another repo: `cd` there and `wt list` first — there's usually already a worktree. Reading the diff needs no checkout (`gh pr diff <n>`); reading files at PR HEAD → the existing worktree, `gh api …/contents/<path>?ref=pull/<n>/head`, or `claude --worktree "#<n>"`. Never `gh pr checkout` (clobbers the main worktree's HEAD).

## Working directory in worktrees

After creating a worktree, immediately `cd` into it as a **standalone Bash call** (a chained `cd` reverts after the command). `pwd` if you lose track.

- The Edit tool's read-before-edit check is per absolute path: having Read a file in the main checkout does not allow editing it in the worktree — Read it again at the worktree path.
- **That gate runs the other way too, and there it fails silently: a file you Read in the main checkout for orientation stays editable *there* for the rest of the session.** So an Edit that names the repo-root path succeeds and writes outside the worktree — no error, and the branch shows no change. Build worktree paths from the worktree root every time rather than from the path you first read, and `git status` in the main checkout before finishing. Recover with `git checkout <path>` there, then redo the edit at the worktree path.
- To inspect another branch's files, prefer read-only access (`git show <ref>:<path>`, `git diff <a> <b> -- <path>`) over `cd`-ing out. If you must, `cd` back *before* any write op — especially `git checkout <branch> -- <files>`, which modifies whichever tree you're standing in.
- **A `cd` detour also silently invalidates the next *verification* command, and there the failure mode is a false pass.** A following `terraform fmt -check .` / `validate` / `make lint` runs against *that* directory and can report clean while your edits go unchecked. Prefer the **Read** tool with an absolute path. If you did `cd`, run `pwd` in the same call as the check, and treat an unexpected "clean" or an unrelated error as a cwd tell.

## Built-in alternative

Complementary to `wt`: `claude --worktree <name>`, `claude --worktree "#1234"` (PR checkout), subagent `isolation: "worktree"` (throwaway, auto-cleaned), `.worktreeinclude` (seeds gitignored files like `.env`). `wt` remains the default for feature work — its path template, merge/squash, and lifecycle hooks are configured. `wt` uses `.worktrees/`; built-ins use `.claude/worktrees/`.
