# Central preset and repo config

## Layout

- `annotell/renovate-config` lives in `~/Code/_kognic/renovate-config`. Its git remote may still say `public-renovate-config`, but PRs and issues go to `annotell/renovate-config`. `default.json` extends per-ecosystem sub-presets (`go.json`, `python.json`, `gha.json`, `terraform.json`, `internal.json`, ...). The JSON is strict, with no comments, so the reason for each rule goes in the README section "Why each preset exists".
- The bot applies the preset with `globalExtends` and `requireConfig: 'optional'`, so a repo with no config file still gets scanned. A new repo needs no Renovate file.
- If a repo needs its own config, there's exactly one file, `.github/renovate.json5` (`RENOVATE_CONFIG_FILE_NAMES`). Keep it additive: repo-specific `packageRules`/`customManagers` only, without re-`extends`ing the central preset. A second file is ignored without any error. GitHub-hosted-app repos are the exception and use a root `renovate.json`.
- Repo config layers over the global config, so check the repo's own `minimumReleaseAge`, `prCreation` and limits before you blame the preset. For example, `k8s-platform-gitops` raises the cooldown above the preset's.

## Shipping a preset change

1. Put the rule in the right sub-preset and document it in the README.
2. Validate the way CI does: `npx --yes --package renovate -- renovate-config-validator <file>.json`.
3. Title the PR `fix:` or `feat:` whenever bot behaviour changes. `chore:`/`ci:` are hidden release-please types and don't cut a release.
4. After merge, check that a release was cut and that the `renovate-config-nginx` sidecar tag was bumped in `k8s-platform-gitops` (`infra/renovate/values.yaml`). Until then the bot still runs the old preset.

A change to a repo's own `renovate.json5` is read from that repo's default branch on the next run, with no rebuild.

## Rule patterns

- Disable a dep: `matchManagers`/`matchDatasources`/`matchPackageNames` plus `enabled: false`. For a Terraform provider, the package name is the source address (`volcengine/volcengine`).
- Cap below a known break: the same matcher with `allowedVersions: "<= X.Y.Z"`. Renovate still proposes bumps up to the cap.
- Scope to repos: `matchRepositories` with a regex, plus `!annotell/<repo>` exclusions.
- Match a customManager's deps by `depName` alone. The manager token (`regex` vs `custom.regex`) has changed between Renovate versions.

## Preset refs

`github>o/r` resolves to `default.json`, `github>o/r//<name>` to `<name>.json`, and `github>o/r#<ref>` to the preset at that git ref. A `#<branch>` ref breaks the repo completely once the branch is deleted (see troubleshooting.md), so remove the pin when the feature merges.

## Cooldowns and timestamps

- The global `minimumReleaseAge` is 7 days. `internal.json` sets it to 0 for first-party artifacts, with one rule per ecosystem. Those rules also set `prPriority: 5`, so internal bumps take the first PR slots.
- The docker datasource only returns `releaseTimestamp` for Docker Hub. GAR, gcr, ghcr, quay and `oci://` charts have none, so under the default `timestamp-required` they would wait in Pending forever. The preset sets `minimumReleaseAgeBehaviour: timestamp-optional` for the docker datasource. Its summary WARN (`did not have a releaseTimestamp`) is lowered to debug with `logLevelRemap`. To check that remap, look for the line changing from WARN to DEBUG. The line itself doesn't disappear.
- Classic `index.yaml` helm repos do return `created`, so the cooldown really applies to them. That means a chart bump can wait while OCI and image bumps in the same group ship.

## Automerge

Renovate's own `automerge: true` is the only thing that merges. The `autoreview` label only gets the kognic-github-app to review and approve. Each language preset pairs `autoreview` with an explicit `automerge` setting: GitHub Actions and Go non-major are true, the others false. The docker datasource is pinned to `automerge: false`, because timestamp-less bumps get no cooldown. If a PR is closed by hand, Renovate doesn't reopen it.

## Ecosystem quirks

- **Go:** `constraintsFiltering: strict` keeps only releases whose `go` directive has the same minor as the repo's, so deps and CVE fixes vanish without a word (tell: `look like a version`). `// indirect` requires are extracted as `enabled: false`. To get indirect CVE fixes you need both changes: drop strict, and extend `security:gomodIndirectSecurityUpdates`.
- **Terraform providers:** Renovate turns `~> 0.Y` into npm `^0.Y`, which caps at the next 0.x minor, so it proposes floor bumps the constraint already allowed. `lockFileMaintenance` uses the same conversion. Bumping a floor is right in a consumer root and wrong in a published module, so the preset disables `terraform-provider` updates in `terraform-modules-*`, majors included. Module `?ref=` sources are still tracked.
- **Volcano estate:** `terraform-*-volcano` repos point at `registry.opentofu.org`. The built-in `gitlabci` manager is disabled because it can't reach the GitLab host. A central customManager tracks the `gitlab-ci-volcano` component pin through github-releases, with a short `minimumReleaseAge` so the China image build finishes first. Renovate can't move a pin off a non-semver ref like `@master`, so the first pin has to be edited by hand.
- **volcengine provider:** capped with `allowedVersions` in `terraform.json`. Read the README for the current cap and why it's there.
