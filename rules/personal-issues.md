# Personal GitHub Issues Tracking

The repo `lindeskar/work` uses GitHub Issues as a personal todo list.

## Awareness

- At the start of a session, if the task relates to a known issue, note the issue number
- Use `gh issue list --repo lindeskar/work` to browse open issues when context is needed
- Use `gh issue view <number> --repo lindeskar/work` to read issue details

## Cross-linking

Cross-linking is **one-directional**: personal issues link to company PRs, never the reverse.

When creating PRs or issues in company repos (`annotell` org) that relate to work initiated from a personal issue:

- Comment on the personal issue with a link to the company PR/issue:
  `gh issue comment <number> --repo lindeskar/work --body "PR: <url>"`
- NEVER reference personal issues (`lindeskar/work`) in company PR titles, descriptions, or commit messages — these are private and should not appear in company repos

## Creating issues

When starting work on a task that doesn't match an existing open issue, ask the user if they want a personal issue created for it. Keep titles and descriptions very brief — these are personal reminders, not formal specs:
`gh issue create --repo lindeskar/work --title "<title>" --body "<description>"`

## Updating issues

- When starting work on an issue, set its project status to "In Progress":
  `gh project item-edit --project-id PVT_kwHOARWoXc4BQZd5 --id <item-id> --field-id PVTSSF_lAHOARWoXc4BQZd5zg-h5y0 --single-select-option-id 47fc9ee4`
  To find the item ID, use `gh project item-list 1 --owner lindeskar --format json` and match by issue number
- When committing to `lindeskar/work` for work related to an issue, reference it in the commit message (e.g. `docs: add envoy notes #4`)
- When a task from a personal issue is completed (PR merged, change deployed), comment on the personal issue with the outcome
- Close the personal issue only when explicitly asked — the user manages issue lifecycle

## Sub-issues

When the user asks to add a sub-issue (or sub-task) to an existing issue:

1. Create the child issue:
   `gh issue create --repo <repo> --title "<title>" --body "<body>"`
2. Get the numeric database ID of the new issue (NOT the GraphQL node_id):
   `gh api repos/{owner}/{repo}/issues/{child_number} --jq .id`
3. Link it as a sub-issue to the parent:
   `gh api repos/{owner}/{repo}/issues/{parent_number}/sub_issues -F sub_issue_id=<numeric_id>`

Important:
- Use `-F` (not `-f`) for `sub_issue_id` — it must be sent as a number
- The parent uses its regular issue number in the URL; the child uses its REST API numeric `id` (from `.id`, not `.node_id`)
- Do NOT use `gh issue view --json id` — it returns the GraphQL `node_id`, which is wrong for this API
