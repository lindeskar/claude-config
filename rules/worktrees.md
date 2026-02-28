# Worktrees

- Always create a worktree for feature work — never work directly on main/master
- Create the worktree first, then make all edits there — don't edit in main checkout and copy files over
- Use `wt switch --create <branch>` to create worktrees (path template configured in worktrunk)
- Clean up after PR merge: `wt remove <branch>`
- Use `wt list` to check worktrees and `wt switch` to navigate between them
- Stay contained — never touch files in the main checkout or other worktrees
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

- Run `cd` alone — never chain it with `&&` or `;`
- Do this once right after `wt switch --create`, then all subsequent commands run in the worktree
- If you lose track of the working directory, run `pwd` to check and `cd` again if needed
