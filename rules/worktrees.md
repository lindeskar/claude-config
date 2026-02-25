# Worktrees

- Always create a git worktree for feature work — never work directly on main/master
- Default location: `~/.worktrees/<project-name>.<branch-slug>` (slugify: `feat/add-auth` → `feat-add-auth`)
- Clean up after PR merge: `git worktree remove <path>`, then delete the branch
- Check for stale worktrees: `git worktree list`
- Stay contained — never touch files in the main checkout or other worktrees
