---
name: renovate
description: Kognic's self-hosted Renovate (Mend renovate-ce): deployment, central preset and debugging. Use when a Renovate bump PR is missing, stuck pending, not rebasing or not automerging; when reading the Dependency Dashboard; when editing annotell/renovate-config, packageRules, customManagers or a repo's renovate.json5; or when touching k8s-platform-gitops infra/renovate.
---

# Renovate at Kognic

- **Bot:** Mend renovate-ce from `k8s-platform-gitops/infra/renovate` (o11y cluster, ns `renovate`). It runs as shards `renovate-a..d`, each owning a range of repos (`shards/<x>.yaml`). It acts as the GitHub App `app/kognic-renovate`, which also authors the `Dependency Dashboard` issue.
- **Precedence:** preset `annotell/renovate-config` (`globalExtends`) < `config.js` < env (including env CE injects itself). Arrays replace. The repo's single `.github/renovate.json5` goes on top. A change that doesn't take effect is usually overridden by a higher layer.
- **Preset deploy:** the preset is served by the `renovate-config-nginx` sidecar, not fetched from GitHub. A change only goes live after a release and a sidecar tag bump, so preset PRs are `fix:`/`feat:`.
- **Which shard ran a repo** (loki-o11y; `repository` is structured metadata): `{namespace="renovate", deployment=~"renovate-[a-d]"} | repository="annotell/<repo>" |~ "Repository (started|finished)"`. You should see exactly one shard.
- **Dashboard first:** Detected Dependencies tells you whether a dep was extracted. The section it sits in and its checkbox tell you why no PR exists. Wait for the run to finish before you read it.
- **Dry run** (sandbox off; take the version from `renovateVersion` on the `Renovate started` log line): `RENOVATE_ONBOARDING=false RENOVATE_REQUIRE_CONFIG=optional RENOVATE_CONFIG_FILE=<cfg> LOG_FORMAT=json LOG_LEVEL=debug npx --package renovate@<ver> -- renovate --platform=local --dry-run=full`. Parse the output with `jq -rR 'fromjson? // empty'`. Validate config with `renovate-config-validator --strict <file>`.

## References

- `references/troubleshooting.md`: a PR is missing, parked or erroring. Dashboard checkboxes, cache vs cooldown vs disabled.
- `references/config-and-presets.md`: editing the preset or a repo config. Cooldowns, automerge, Go and Terraform quirks.
- `references/managers-and-datasources.md`: a dep isn't extracted, or you're writing a customManager. Registry auth, China registries.
- `references/ce-deployment.md`: changing the bot itself. Webhook routing, env, version chain, cache PVC, sidecar.
- `references/upstream-contributing.md`: opening a PR against `renovatebot/renovate`.

Team wiki: `kognic-internal/devplat` `docs/wiki/renovate/`.
