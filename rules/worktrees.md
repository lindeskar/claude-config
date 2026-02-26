# Worktrees

- Always create a worktree for feature work — never work directly on main/master
- Create the worktree first, then make all edits there — don't edit in main checkout and copy files over
- Use `wt switch --create <branch>` to create worktrees (path template configured in worktrunk)
- Clean up after PR merge: `wt remove <branch>`
- Use `wt list` to check worktrees and `wt switch` to navigate between them
- Stay contained — never touch files in the main checkout or other worktrees
- For detailed worktrunk usage, invoke the `worktrunk:worktrunk` skill
