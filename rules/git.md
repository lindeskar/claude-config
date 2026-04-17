# Git

- Conventional commit messages, single line: `<type>[scope]: <description>`
- Append a `!` after `<type>[scope]` to indicate a BREAKING change
- Always create PRs in draft mode with a description: `gh pr create --draft --title "..." --body "..."`
- PR body: match detail to the change size. For small/simple PRs (single-file or narrow scope), write one or two sentences — no `## Summary` header, no bullet list. Use backticks for identifiers/zones/paths and bold for the key takeaway (e.g. `**in log mode**`). Only use a `## Summary` section with bullets when the change genuinely spans multiple concerns that benefit from enumeration.
- PR body should describe what changed, not what was intentionally omitted — don't enumerate things you didn't do unless a reviewer would otherwise be surprised by the gap.
- Never amend commits
- Never force-push
- Never use `git -C <path>` — always `cd` to the repo directory first, then run git commands without `-C`
- Run `git add` and `git commit` as separate Bash tool calls — never chain them with `&&` or `;`
- For multi-line commit messages: pass a multi-line string directly to `git commit -m` — never use command substitution (`$(...)`) in commit commands
- Match commit granularity to the task — bulk-adding new files (migrations, scaffolding) is one commit, not one per directory. Split commits only when changes are incremental to existing code and benefit from independent review or rollback.
