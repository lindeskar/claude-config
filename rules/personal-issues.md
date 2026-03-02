# Personal GitHub Issues Tracking

The repo `lindeskar/work` uses GitHub Issues as a personal todo list.

## Awareness

- At the start of a session, if the task relates to a known issue, note the issue number
- Use `gh issue list --repo lindeskar/work` to browse open issues when context is needed
- Use `gh issue view <number> --repo lindeskar/work` to read issue details

## Cross-linking

When creating PRs or issues in company repos (`annotell` org) that relate to work initiated from a personal issue:

- Comment on the personal issue with a link to the company PR/issue:
  `gh issue comment <number> --repo lindeskar/work --body "PR: <url>"`

## Creating issues

When starting work on a task that doesn't match an existing open issue, ask the user if they want a personal issue created for it:
`gh issue create --repo lindeskar/work --title "<title>" --body "<description>"`

## Updating issues

- When starting work on an issue, set its project status to "In Progress":
  `gh project item-edit --project-id PVT_kwHOARWoXc4BQZd5 --id <item-id> --field-id PVTSSF_lAHOARWoXc4BQZd5zg-h5y0 --single-select-option-id 47fc9ee4`
  To find the item ID, use `gh project item-list 1 --owner lindeskar --format json` and match by issue number
- When a task from a personal issue is completed (PR merged, change deployed), comment on the personal issue with the outcome
- Close the personal issue only when explicitly asked — the user manages issue lifecycle
