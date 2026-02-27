# Git

- Conventional commit messages, single line: `<type>[scope]: <description>`
- Append a `!` after `<type>[scope]` to indicate a BREAKING change
- Always create PRs in draft mode: `gh pr create --draft`
- Never amend commits
- Never force-push
- Run git commands without `-C` when already in the repo directory
- Run `git add` and `git commit` as separate Bash tool calls — never chain them with `&&` or `;`
- For multi-line commit messages: pass a multi-line string directly to `git commit -m` — never use command substitution (`$(...)`) in commit commands
