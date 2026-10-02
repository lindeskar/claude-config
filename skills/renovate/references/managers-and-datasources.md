# Managers, customManagers and datasources

## Built-in manager blind spots

- `dockerfile` only sees `FROM` lines. `github-actions` only sees `uses:` pins. A version in an apt pin (`tofu=1.12.1`), a workflow `default:` input, or an env var has no datasource, so it needs a customManager.
- `helm-values` only extracts a value whose own key matches `/image$/i`, either as an inline string or as an object with `repository` plus `tag`/`version`. `images.envoy` is never extracted, so a `helm-values` disable rule aimed at it does nothing. To fix it, rename the key or add a regex customManager with `versioning: "regex:..."`.
- Dashboard tell: a file whose deps are all disabled still appears, with an empty list. A file where nothing was extracted doesn't appear at all.
- Renovate can't tie one dep's version to another's, such as an image tag to a sibling chart version. Use a hand cap, `postUpgradeTasks` (which needs a global `allowedCommands` change), or a CI rewrite.

## Annotation customManager recipe

```dockerfile
# renovate: datasource=github-releases depName=opentofu/opentofu extractVersion=^v(?<version>.+)$
RUN apt install -y tofu=1.12.1
```
```json5
customManagers: [{
  customType: "regex",
  managerFilePatterns: ["<path>/Dockerfile"],
  matchStrings: ["# renovate: datasource=(?<datasource>\\S+) depName=(?<depName>\\S+)(?: extractVersion=(?<extractVersion>\\S+))?\\s+RUN apt install -y \\S+=(?<currentValue>[0-9.]+)"],
}]
```
- `extractVersion` removes the tag's `v` so the result matches a bare pin. The `currentValue` capture has to match the pin's exact shape, including any suffix.
- For a workflow input: `default:\\s*\"(?<currentValue>[^\"]+)\"` with `extractVersionTemplate: "^v?(?<version>.+)$"` and `versioningTemplate: "semver"`.
- Before shipping, test `matchStrings` offline against the real file with `python3 re`. A typo in a named group extracts nothing and raises no error. After shipping, the dep should appear under the dashboard's `regex` section. That's the proof it works.
- **Field order:** the `# source_repository:` Chart.yaml managers in `k8s-platform-gitops-volcano` only match `name`, then `# source_repository`, then `repository`, then `version`, with version last. A dep in a different order is skipped without any error. That repo's `CLAUDE.md` documents the convention.

## pinDigests on values that can't hold a digest

The preset inherits `docker:pinDigests`. If a docker-datasource dep has no `currentDigest` slot (a customManager that only captures `currentValue`, or an OCI chart `version:`), Renovate tries to pin it, can't write the digest, logs `Digest is not updated`, and fails the whole `pin dependencies` branch with `update failure`. Turn off `pinDigests: false` for just those files or deps (`matchFileNames`, `matchDepNames`). Keep it on for real images. Also give pins a stable `groupName`, because templated group names collapse when a group spans several directories.

## Registry auth

- The docker datasource authenticates to `*-docker.pkg.dev`/`gcr.io` automatically through GCP ADC/Workload Identity, but only when no static-credential hostRule matches that host. GAR docker lookups need no hostRule, and adding one turns ADC off. Maven has no ADC path and needs a static hostRule. `hostRules` live in `config.js` in `infra/renovate/values.yaml`.
- The bot runs in the EU and has no credentials for China registries (`*.cr.volces.com`, `harbor.common-cn-pub.kognic.io`). `k8s-platform-gitops-volcano` also disables those hosts on purpose. Ways to make such a dep trackable:
  - Keep canonical refs in manifests and let Kyverno rewrite them at admission (the volcano image-mutation model).
  - Point a customManager at the GAR copy of a dual-published first-party image. Tags are identical, and ADC works.
  - Look up upstream charts from the `# source_repository:` comment instead of the mirror `repository:`.
- For a repo's own release-tagged image, use release-please `extra-files` with `# x-release-please-version` instead of Renovate. Renovate would track the repo's own tags one release behind.

## Terraform modules

GitHub-canonical module sources (`github.com/annotell/terraform-modules-volcano//modules/<m>?ref=X`) are tracked through github-tags, so don't bump them by hand. `oci://` module sources aren't supported by the terraform manager. In `terraform-*-volcano` (with `-lockfile=readonly`), provider bump PRs have their locks fixed automatically. A module major bump can still need a manual lock commit.
