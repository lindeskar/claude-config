# Renovate troubleshooting

Start by placing the bump in one of three buckets. Each has different fixes.

| Bucket | Tell | Go to |
|---|---|---|
| Not extracted | Dep or file is missing from Detected Dependencies | managers-and-datasources.md |
| Extracted, no versions | Listed with no `(N)` count | "Disabled vs auth" below |
| Detected but parked | The new version shows in an actionable section | "Dashboard sections" below |
| Not detected yet | Dashboard still lists the old version and nothing newer | "Datasource cache" below |

## Dashboard sections and checkboxes

Edit the issue with `gh issue view <n> --json body --jq .body > f`, flip one `- [ ]` to `- [x]`, then `gh issue edit <n> --body-file f`. Ticking a box fires `issues.edited`, which is routed to the owning shard. The checkbox goes back to `[ ]` once the run has consumed it, which takes a few minutes. Don't tick again before that.

- **Pending Status Checks**: `approvePr-branch=`. Force-creates that one PR. Use this, not the top-level "run again".
- **Rate-Limited**: `unlimit-branch=`, or "Create all rate-limited PRs". This is behind `prHourlyLimit`/`prConcurrentLimit`. Only vulnerability alerts bypass the limits. `prPriority` decides order.
- **Open**: `rebase-branch=` retries or rebases.
- **PR Edited (Blocked)**: someone else committed, so Renovate stopped touching it. The checkbox discards those commits.
- **Errored**: read the branch's DEBUG lines right before `Error updating branch` (`branch` structured metadata).

**Gates clear one at a time.** After a tick, the item can move to a different section instead of opening. Tick that section's box as well. Confirm with `gh pr list --head renovate/<slug> --state open`, not with the dashboard.

**Pending Status Checks has two unrelated causes. Check whether the branch exists** (`git ls-remote --heads origin 'refs/heads/renovate/*'`):
- No branch: the internal-checks quarantine (`minimumReleaseAge`). A candidate with no `releaseTimestamp` under `timestamp-required` waits forever. See config-and-presets.md.
- Branch exists: the benign `prCreation: not-pending` delay. It resolves on its own; `prNotPendingHours` is the backstop.

**Grouped pending member is invisible.** A cooldown-held member of a group whose branch is already open has no checkbox anywhere and appears only under Detected Dependencies. The log says `Branch is not pending, removing pending upgrades`. The branch's `updates` structured metadata lists what actually made it in. Merging the group PR leaves the member alone in the branch, and its `approvePr-branch` checkbox then shows up.

## Datasource cache right after a release

When a tag was just cut, a run can execute and still resolve the old tag list, because the datasource cache has a 30-minute soft TTL that counts from the last lookup. Look at `gh issue view <n> --json updatedAt` on the dashboard. If it's more than about 30 minutes old, a trigger will see the new tag; if not, wait out the rest. This isn't `minimumReleaseAge`, which is 0 for first-party artifacts. Check that `cacheTtlOverride` isn't set in `infra/renovate`.

## Disabled vs auth

`Dependency: <pkg>, is disabled` comes from a `packageRule` with `enabled: false`, not from credentials. The dep is skipped before any lookup. Look through every layer: central preset, `config.js`, and the repo's own `renovate.json5`. `k8s-platform-gitops` uses an opt-out allowlist: a catch-all disable, then re-enable rules per path. A new `infra/<app>/` with no env subdir matches no re-enable rule and stays off without any warning. The tell is a `Chart.yaml` that lags its siblings and an empty `git log --author=renovate -- infra/<app>`. A matched disable rule and a failed credential lookup look the same, so rule out disables before you blame auth.

## Repo produces no PRs at all

- Preset resolution fails in `initRepo` (`Repository has invalid config`, `Cannot find preset's package`). The tell is a job that finishes in seconds without `Dependency extraction complete`. The usual cause is `extends` pinned to `#<branch>` after that branch was deleted. It only affects that repo, and it stops the repo's own sidecar bumps too. Find affected repos across shards with `kubectl -n renovate logs <pod> -c mend-renovate-ce --since=24h | jq -rR 'fromjson? // empty | select(.msg=="Repository has invalid config") | .repository' | sort | uniq -c`.
- A second repo config file was added. Renovate reads only one file, and the dashboard's `renovate-config` section names it.

## Branch and CI problems

- A stale Renovate branch fails CI on config that exists on master. The tell is a branch that's many commits behind. Fix it with `git merge --no-ff origin/master` and a normal push. Never rebase or force-push a Renovate branch.
- A config change that is live but inert: the branch-modified result is cached by SHA (`using cached result "true"`). A rebase or a fresh run makes Renovate recompute it.

## Logs (loki-o11y)

Pods ship DEBUG. `repository`, `branch`, `depName`, `dependency`, `versions` and `updates` are structured metadata, so filter them with `| repository="annotell/<repo>"`, not with `|=` or a selector label. Some lines are plain text, so use `jq -rR 'fromjson? // empty'`. Before you trust an empty result, test the filter against a dep you know is there (`kognic-observability` skill). Useful lines: `N flattened updates found`, `Returning N branch(es)`, `look like a version` (dropped by constraints), `Digest is not updated`, `Open PR Count: N, Existing Branch Count: M`.
