---
name: company-issues
description: >-
  Create and maintain GitHub issues in the annotell and kognic-internal orgs, including auto-adding
  them to the Platform Engineering project. Use when creating a company GitHub issue, when the user
  says "add a team issue", or when structuring an issue body, adding findings or status as comments,
  or wrapping one up with a conclusion. Covers the plateng team-property gate, the devplat tracking
  repo, and problem-statement-vs-comments structure.
---

# Company GitHub Issues — Platform Engineering project

When creating a GitHub issue in a repo in the `annotell` org, automatically add it to the **Platform Engineering** project (org project number `23`, node ID `PVT_kwDOAfrIOc4Acn_s`) — but only if the repo's `team` custom property contains `plateng`.

## "Add a team issue" → `kognic-internal/devplat`

When the user says "add a team issue" (or "team issue"), create it in **`kognic-internal/devplat`** — the platform team's tracking repo — not in whatever repo the change lives in. Use full GitHub URLs for cross-repo refs in the body (a bare `#NNN` won't autolink from devplat to another repo), and link the issue from any related PR with the plain full devplat URL. Skip the manual project add for `kognic-internal/devplat`: org automation already adds every devplat issue to the PlatEng project (#23). Issue-side `projectItems` comes back empty for this cross-org project, so verify from the project side (`organization(login:"annotell").projectV2(number:23).items`).

## Procedure

After `gh issue create` returns the issue URL:

1. Read the repo's custom properties and check whether `team` contains `plateng`:
   ```
   gh api repos/annotell/<repo>/properties/values \
     --jq 'any(.[]; .property_name=="team" and (.value | (type=="array" and index("plateng")) or .=="plateng"))'
   ```
   The `team` property is a multi-select, so its value is an array (e.g. `["plateng"]`) — match membership, not equality.
2. If it returns `true`, add the issue to the project (use `--format json` — it returns the new item `id`, confirming the add; don't verify with `item-list`, which truncates at 30 items; see `github-api` → Projects):
   ```
   gh project item-add 23 --owner annotell --url <issue-url> --format json
   ```
3. If it returns `false` (or `team` is unset), do nothing — leave the issue off the project.

## Notes

- This only fires for issues created in-session, not ones opened in the GitHub UI.
- Don't add issues from non-`plateng` repos to the project, even if asked to create the issue — surface the skipped add rather than silently forcing it.
- The project auto-add applies to `annotell` repos only; for other `kognic-internal` repos, create the issue and skip the add (devplat is auto-added by org automation). Personal-repo issue tracking (`lindeskar/work`) is the `personal-issues` skill.

## Issue structure — writing and maintaining

- **Description = the stable problem statement only** — the need/why, plus any durable requirement or constraint (e.g. "remove the VM when the POC is done"). It should not change considerably over time — don't fold outcomes, changelogs, or PR lists into it. The chosen solution or implementation stays out of the body, even at creation time. When you create an issue for work you're already doing, the body is the problem and the *first comment* is your proposed/implemented solution.
- **Solution, findings, status updates, and conclusions go in comments** — and keep them few and tight: prefer one consolidated comment (chosen approach, PR links, outcome, key learnings) over many overlapping verbose comments.
- When wrapping up, add/update a single conclusion comment rather than rewriting the description; consolidate or delete redundant interim comments instead of letting them pile up.
