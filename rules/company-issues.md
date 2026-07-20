# Company GitHub Issues — Platform Engineering project

When creating a GitHub issue in a repo in the `annotell` org, automatically add it to the **Platform Engineering** project (org project number `23`, node ID `PVT_kwDOAfrIOc4Acn_s`) — but only if the repo's `team` custom property contains `plateng`.

## "Add a team issue" → `kognic-internal/devplat`

When the user says "add a team issue" (or "team issue"), create it in **`kognic-internal/devplat`** — the platform team's tracking repo — not in whatever repo the change lives in. Use full GitHub URLs for cross-repo refs in the body (a bare `#NNN` won't autolink from devplat to another repo), and link the issue from any related PR with the plain full devplat URL. The PlatEng-project auto-add below is `annotell`-org-scoped and does **not** apply to `kognic-internal/devplat`.

## Procedure

After `gh issue create` returns the issue URL:

1. Read the repo's custom properties and check whether `team` contains `plateng`:
   ```
   gh api repos/annotell/<repo>/properties/values \
     --jq 'any(.[]; .property_name=="team" and (.value | (type=="array" and index("plateng")) or .=="plateng"))'
   ```
   The `team` property is a multi-select, so its value is an array (e.g. `["plateng"]`) — match membership, not equality.
2. If it returns `true`, add the issue to the project (use `--format json` — it returns the new item `id`, confirming the add; don't verify with `item-list`, which truncates at 30 items — see `tooling.md` GitHub API):
   ```
   gh project item-add 23 --owner annotell --url <issue-url> --format json
   ```
3. If it returns `false` (or `team` is unset), do nothing — leave the issue off the project.

## Notes

- This only fires for issues *I* create during a session — it does not catch issues opened by others in the GitHub UI. For org-wide coverage a GitHub Actions workflow would be needed (deferred).
- Don't add issues from non-`plateng` repos to the project, even if asked to create the issue — surface the skipped add rather than silently forcing it.
- Applies to the `annotell` org only. Personal-repo issue tracking (`lindeskar/work`) is handled separately in `personal-issues.md`.
