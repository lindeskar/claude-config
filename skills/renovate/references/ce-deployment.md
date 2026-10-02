# renovate-ce deployment (`k8s-platform-gitops/infra/renovate`)

## Shards and webhook routing

- Shards `renovate-a..d` each own a disjoint range of repo names by first character. The ranges are set by `mendRnvAutoDiscoverFilter` in `shards/<x>.yaml`. Shard `a` is primary and renders the cluster-singleton resources. Each shard has its own Cloud SQL DB.
- One org webhook goes to `renovate-webhook-proxy` (nginx + njs, rendered only on primary). It forwards each delivery only to the shard that owns the repo. Events without a `repository.name` are acked and dropped. Hourly autodiscovery picks up whatever gets dropped.
- The autodiscover filter only gates scheduled runs. Webhook jobs ignore it. So the njs first-character table and the per-shard filters are two copies that must stay in sync. If a repo gets jobs on two shards, those jobs race: one creates a branch or PR while another prunes it as stale, which closes the PR.
- Proxy routing decisions: `{namespace="renovate", app="renovate-webhook-proxy"} |= "/webhook"`. The access log shows `shard=` but not the repo.
- During a rollout, the proxy logs `Connection refused` and returns `502 shard=renovate-x` for about a minute while pods restart. Errors that only appear at rollout timestamps are expected.

## Config precedence

`defaults < globalExtends preset < config.js < env < cli`. Arrays replace, not merge.
- CE injects `gitAuthor` and `gitIgnoredAuthors` at the env layer because `mendRnvGithubBotUserId` is set. Values from the preset or config.js lose to these. Set `RENOVATE_GIT_IGNORED_AUTHORS` in `extraEnvVars` instead, and keep the legacy `<bot>[bot]@users.noreply.github.com` author in the list.
- Self-hosted-only options (`hostRules`, `allowedCommands`, `customEnvVariables`) go in the `config: |` block.
- To verify a setting, look at its effect. Its source doesn't prove anything. The CE server pod is long-lived, so confirm a new pod name in the logs before treating a `values.yaml` change as live.

## Child process env is an allowlist

Manager subprocesses (`go`, `uv`, `npm`, ...) only get `HOME`, `PATH`, proxy and CA vars, the manager's own `extraEnv`, and `customEnvVariables`. An env var on the pod spec never reaches them, so forward it through `customEnvVariables` in config.js. Check it by its effect in the next run's subprocess output, for example the Go-major `artifactErrors` saying `open /usr/local/bin/mod: read-only file system` when `GOBIN` is missing.

## Version chain

There are three tracks: the OSS CLI, the `ghcr.io/mend/renovate-ce` image that bakes in one CLI version, and the `mend-renovate-ce` chart (chart version = appVersion = image tag), which is pinned in `infra/renovate/Chart.yaml`. To find the CLI version inside an image, read `MEND_RNV_RENOVATE_VERSION` from the image config, or run `docker run --rm --entrypoint sh ghcr.io/mend/renovate-ce:<tag> -c 'renovate --version'`. There's no knob to override the CLI version (`-full` vs slim is about third-party tools), so an upstream fix has to wait for a Mend release. Overlaying `/usr/local/renovate` from `renovate/renovate` onto the CE image does work, but it leaves you maintaining an untested multi-arch build of proprietary software. Only do it if waiting isn't an option.

## Preset sidecar and pod constraints

- The preset is served by the `preset-server` native sidecar on `http://localhost:8088`. The `renovate-config-nginx` image build rewrites the sub-preset refs to localhost. `default.json`'s self-refs and that rewrite regex have to change together.
- `globalExtends` is resolved before `hostRules` and `internalHostAccess` take effect. So a `github>` preset there is fetched anonymously, and the localhost sidecar triggers an `internal host` warning on every job that no setting can grant. If upstream makes `internalHostAccess: block` the default, global preset loading will break.
- The pod is pinned to arm64 (c4a). Every sidecar image must be multi-arch, and third-party images must be pinned by index digest. CE binds 8080, so sidecars can't use that port. To build an in-house sidecar image, copy `annotell/renovate-config`'s `build-push.yaml`.

## Cache PVC and worker cleanup

- `renovate-<x>-cache` is mounted at `/tmp/renovate` (`RENOVATE_BASE_DIR`). It holds the repo clones and the datasource/HTTP cache, and it only ever grows until it hits ENOSPC. `mendRnvDiskUsageWarnThreshold` only warns. TTL options mark entries stale but don't delete files.
- Fullness (mimir-o11y): `kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes` for `persistentvolumeclaim=~"renovate-.*-cache"`. The limit is space, not inodes. ENOSPC: `{namespace="renovate"} |= "ENOSPC"`.
- Levers: `cachePersistence.size` (online expansion works, shrinking doesn't), a periodic reset of the cache dir per shard, Redis for the package cache, or `RENOVATE_PERSIST_REPO_DATA=false`.
- `mendRnvWorkerCleanup` runs `find <dir> -newercc <boot-ref> -delete` for each listed dir between jobs. It has no exclude option, so it deletes everything changed since boot and wipes a SQLite package cache. List the `cache/` subdirs explicitly and leave out `renovate/renovate-cache-sqlite`. You can see the live command in the `Resolved file system cleanup config` log line (`cleanupConfig`).

## Limits

Per-repo `prHourlyLimit`/`prConcurrentLimit` are set in config.js, and repos can override them. After a config change unblocks a backlog, branches drain a few PRs per run and sit under Rate-Limited in the meantime.
