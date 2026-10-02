---
name: personal-issues
description: >-
  Track personal work using GitHub Issues in the private lindeskar/work repo. Use when creating,
  browsing, updating, or closing a personal todo issue, adding a sub-issue, setting project status,
  or cross-linking a company PR back to a personal issue. Covers the one-directional cross-linking
  rule (personal issues may reference company PRs, never the reverse) and the sub-issue REST API.
---

# Personal GitHub Issues Tracking

The repo `lindeskar/work` uses GitHub Issues as a personal todo list.

## Awareness

- At the start of a session, if the task relates to a known issue, note the issue number
- Use `gh issue list --repo lindeskar/work` to browse open issues when context is needed
- Use `gh issue view <number> --repo lindeskar/work` to read issue details

## Cross-linking

Cross-linking is **one-directional**: personal issues link to company PRs, never the reverse.

When creating PRs or issues in company repos (`annotell` or `kognic-internal` orgs) that relate to work initiated from a personal issue:

- Comment on the personal issue with a link to the company PR/issue:
  `gh issue comment <number> --repo lindeskar/work --body "PR: <url>"`
- Don't reference `lindeskar/*` repos or issues anywhere in company repos (titles, bodies, commits, comments).

## Creating issues

When starting work on a task that doesn't match an existing open issue, ask the user if they want a personal issue created for it. Keep titles and descriptions very brief — these are personal reminders, not formal specs:
`gh issue create --repo lindeskar/work --title "<title>" --body "<description>"`

## Updating issues

- When starting work on an issue, set its project status to "In Progress":
  `gh project item-edit --project-id PVT_kwHOARWoXc4BQZd5 --id <item-id> --field-id PVTSSF_lAHOARWoXc4BQZd5zg-h5y0 --single-select-option-id 47fc9ee4`
  To find the item ID: `gh project item-list 1 --owner lindeskar --format json --limit 1000 --jq '.items[]|select(.content.number==<n>)|.id'`. The default limit of 30 truncates silently.
- When committing to `lindeskar/work` for work related to an issue, reference it in the commit message (e.g. `docs: add envoy notes #4`)
- When a task from a personal issue is completed (PR merged, change deployed), comment on the personal issue with the outcome
- Close the personal issue only when explicitly asked — the user manages issue lifecycle

## Sub-issues

When the user asks to add a sub-issue (or sub-task) to an existing issue:

1. Create the child issue:
   `gh issue create --repo <repo> --title "<title>" --body "<body>"`
2. Get the numeric database ID of the new issue (the REST `.id`, not the GraphQL `node_id`):
   `gh api repos/{owner}/{repo}/issues/{child_number} --jq .id`
3. Link it as a sub-issue to the parent:
   `gh api repos/{owner}/{repo}/issues/{parent_number}/sub_issues -F sub_issue_id=<numeric_id>`

Important:
- Use `-F` (not `-f`) for `sub_issue_id` — it must be sent as a number
- The parent uses its regular issue number in the URL; the child uses its REST API numeric `id` (from `.id`, not `.node_id`)
- `gh issue view --json id` returns the GraphQL `node_id`, which this API rejects.
