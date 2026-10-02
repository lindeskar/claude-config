---
name: worktrees
description: Git worktree workflow with worktrunk (`wt`): when to branch, basing on a fresh base, staying inside the worktree, cleanup. Use when creating, entering or removing a worktree, starting feature work in a repo, reviewing a PR locally, or cleaning up after a PR merges or closes.
---

# Worktrees

"Base" is the branch work lands on, as the repo's `CLAUDE.md`/`CONTRIBUTING.md` names it. For `wt` config and hooks, see `worktrunk:worktrunk`.

## When

Feature work goes in a worktree. Create it first and edit only there. The exception is personal `lindeskar/*` repos, which have no CI: commit directly on `main` there, and in `lindeskar/work` reference the todo issue.

## Fresh base

`wt switch --create <branch>` branches from the *local* base.

- Refresh it with `git pull --ff-only` in the checkout that holds it.
- Repos whose releases move a floating `vN` tag (release-please `gha-*`, `application-helm`, `helm-devplat`) reject the pull with `would clobber existing tag`. Run `git fetch origin --tags --force` and pull again. Never run these fetches with `-q`: the rejection is the only output, so a quiet fetch fails with a bare exit 1 and leaves you on a stale base.
- If the local base is ahead of origin, or dirty with someone else's work, leave it untouched: `git fetch`, then `git worktree add -b <branch> <path> origin/<base>`.
- Before branching, check `gh pr list` and `wt list` for in-flight work on the same lines.

## Stay inside

- Under the sandbox, `wt` prints `mkstemp failed … Operation not permitted` and still succeeds, so trust the `✓` line. It can't `cd` your shell: run `cd <printed path>` as its own call.
- The Edit gate is per absolute path. A file you Read in the main checkout stays editable there, so an Edit on that path silently writes outside the worktree. Build every path from the worktree root, and run `git status` in the main checkout before finishing.
- After a `cd` detour, the next lint or check runs in the wrong tree and can report a false clean. Put `pwd` in the same call. Prefer `git show <ref>:<path>` to leaving the worktree.

## Reviewing a PR

Run `wt list` first, since a worktree may already exist. `gh pr diff <n>` needs no checkout. For files at PR head, use that worktree, `gh api …/contents/<path>?ref=pull/<n>/head`, or `claude --worktree "#<n>"`. Don't use `gh pr checkout`, which moves the main checkout's HEAD.

For `anthropic-review-pr:review-pr` on a private repo, materialize PR head into a worktree and give every reviewer subagent that absolute path. They have no Bash/`gh`, so otherwise they silently review whatever tree is checked out, usually a stale base. If you paste context instead, give every agent the same complete context; an omission reads to them as a gap in the code.

## Pushing

A push rejected with `fetch first`, where the fetch shows `(forced update)` on a branch you never force-pushed, means the branch below yours was rebased (often by a bot). Don't merge or force-push:

1. `git fetch`, then confirm origin still has your earlier work: `git diff <your-last-pushed-sha> origin/<branch> -- <your files>` is empty.
2. `git reset --hard origin/<branch>`.
3. Cherry-pick only your new commits, then push.

## Cleanup

- After a merge, run `wt remove <branch>`. Squash merges make it refuse with `Branch unmerged`: confirm the PR merged, pull the base, then run `wt remove -D <branch>`.
- `◎ … in background` isn't a result yet, so confirm with `wt list`. If the worktree is still there, run `git worktree remove --force <path>`, then `git branch -D <branch>`.
- `○ No worktree found` means git unregistered the worktree but its directory may remain. If it holds only `.claude/`, delete it.
- If the PR closed unmerged, remove the local worktree and branch but keep the remote branch, which is the only copy.
- For bulk cleanup, match exact branch names, never a substring.
- Never push to a merged PR's branch: origin deleted it, so the push makes an orphan. After a gap, check `gh pr view <n> --json state` first.

`wt` (`.worktrees/`) is the default. Built-in `claude --worktree` and subagent `isolation: "worktree"` suit throwaway cases.
