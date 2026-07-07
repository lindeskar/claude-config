# Tooling

> Full war stories and worked examples for these rules: `reference/tooling.md` in this repo (not auto-loaded). Kognic-specific procedures live in the work wiki — the rules below name the wiki entry where that applies.

## Python / uv

- Python: always use `uv run` to run scripts (e.g. `uv run main.py`)
- `uv sync`/`uv run` rewrites `uv.lock` source registries to the locally-configured index (`pypi.org` → `pypi.kognic.io`). That's local-env noise, not a dependency change — `git checkout uv.lock` before committing unless you intentionally changed deps. Check `git diff uv.lock` after any `uv` invocation in a repo you'll commit to.
- `uv sync` failing with `failed to install: <pkg>.whl` / missing `METADATA` for a normal package = corrupted shared-cache entry. Fix: `uv cache clean <pkg>`, re-run — no full cache wipe needed.

## Command sandbox

- Build caches are redirected globally via the `env` block in `settings.json` (`UV_CACHE_DIR`, `GOCACHE`, `GOLANGCI_LINT_CACHE`, `XDG_CACHE_HOME`, `npm_config_cache` → fixed `/tmp/claude/*` paths). **Do not prepend per-command cache env prefixes** for `uv`/`go`/`gh`/`npm` — run them bare so `permissions.allow` patterns match. For an uncovered tool, prefer a fixed `/tmp/claude/<tool>-cache` path over `$TMPDIR`.
- `$TMPDIR` resolves to a *different directory* in sandboxed vs non-sandboxed Bash calls. When a temp file must cross calls with different sandbox settings, note the absolute path from the first call's output and use it verbatim in the next.
- **golangci-lint can report a false clean** when its cache write is blocked (macOS ignores `XDG_CACHE_HOME`; fact-based linters under-report silently). The tells: `persist facts`/`pkgcache` `operation not permitted` warnings, or nonzero exit with `0 issues.`. Re-run with a writable `GOLANGCI_LINT_CACHE=/tmp/claude/golangci-cache` before trusting the result.
- `terraform`/`tofu` commands that launch a provider (`test`, `plan`, `apply`, `providers schema`) fail in-sandbox with `Unrecognized remote plugin message` — not a cache issue. `init` works sandboxed; run provider-launching commands with the sandbox off.
- A test that fails only under the sandbox but passes with it disabled almost always has a hidden external-network dependency — *not* a code regression, even next to recently-changed code. It can present as a plain assertion mismatch (nil/empty result), not a permission error; CI-green-but-local-red is the tell. Diagnose: re-run sandbox-off, grep the failing test for real hostnames. Fix by making the test hermetic (route its client at the local `httptest` server), not by touching product code.

## Terraform / OpenTofu

- **`terraform` (HashiCorp) vs `tofu` (OpenTofu) — pick by repo; default `terraform`.** Only the **volcano estate** (`terraform-*-volcano`, incl. `terraform-common-volcano`) runs `tofu`/OpenTofu today. **Every other Kognic terraform repo** — `terraform-identity`, `terraform-bootstrap`, the `terraform-*` domain repos — runs HashiCorp **`terraform`** (e.g. `required_version = "~> 1.11"` is Terraform, not OpenTofu). Running `tofu` in a terraform repo mostly works for `validate`/`init` but rewrites `.terraform.lock.hcl` from the `registry.terraform.io` namespace to `registry.opentofu.org` (local-env noise — `git checkout` it before committing) and can produce a lock CI rejects. If unsure which a repo uses: `grep -rE 'setup-opentofu|setup-terraform' .github/`. Full estate split + lock recipe: work wiki `reference_terraform-bootstrap-uses-hashicorp-terraform`.
- Never `tail`/`head` `validate`/`plan` output to check for errors — error blocks span ~10 lines and the *last* block is often the known-benign one. Enumerate all blocks: `… 2>&1 | grep -iE 'error|warning'` to count, `grep -A6 'Error:'` for context. Claim "clean" only after confirming every remaining error is environment-only and none reference your changed files.
- Regenerating `.terraform.lock.hcl` without backend access (use the repo's CLI — `terraform` for non-volcano, `tofu` for volcano): `<cli> init -backend=false` (add `-upgrade` when a pin changed, especially downgrades), then `<cli> providers lock -platform=linux_amd64 -platform=darwin_arm64 …`; verify the lock diff touches only the intended provider. Recipes: work wiki `reference_tofu-lockfile-regen` (volcano) and `reference_terraform-bootstrap-uses-hashicorp-terraform` (non-volcano).
- Before relying on version-specific behaviour of a tool the CI runs, check the version the CI actually pins and reproduce against it before shipping a fix that depends on it.
- Generated files that CI verifies via "regenerate + `git diff --exit-code`" (terraform-docs READMEs, codegen output, lock files) must be produced by the generator, never hand-edited — phantom whole-file diffs are usually line endings (`make docs` runs via docker → CRLF; confirm with `file <path>`). If you can't run the generator, say so rather than guessing.
- Helm: read chart values with `helm show values`

## Bash tool discipline

- Use built-in tools for all file operations — never shell equivalents: **Read** not `cat`/`head`/`tail`/`sed -n`; **Glob** not `find`/`ls`; **Grep** not `grep`/`rg`/`awk`; **Edit** not `sed`/`awk`; **Write** not `echo >`/`cat <<EOF`. Narrow exception: a single mechanical, identical edit across many files may use one `sed`/`perl -pi` pass, only when verified afterward by a compiler/linter/test or a zero-stragglers Grep — never for context-dependent edits.
- Never chain Bash commands with `&&`, `||`, or `;` — one command per Bash call (includes `cd`, `git add` + `git commit`, multi-step inspection). Parallel *independent* calls in one message are fine, but parallel calls share one cwd — never fan out cross-repo git ops in one batch (a `git push` can silently run in the wrong repo); do each repo's `cd` + commands sequentially.
- A dispatched sub-agent's Bash cwd does **not** persist between its calls (unlike the main session) — instruct sub-agents to use absolute paths: `git -C <abs>` and absolute file targets, or `cd <abs> && <cmd>` in one call.
- Never use command substitution (`$(...)`/backticks) — capture output in a prior step, or use built-in tools. One exception — injecting a secret, e.g. `GITHUB_TOKEN=$(gh auth token)`: substitution is *required* there, since pasting the literal token gets blocked as credential leakage.
- Interactive zsh mangles `!` via history expansion — *even inside single quotes and quoted heredocs* (`feat!: x` → `feat\!: x`). It corrupts file content written via `echo`/`cat`, CLI arguments (`gh pr create --title "feat!: …"`), and inline `jq`/`python -c` programs (commonest trigger: `<!--…-->` markers). Use the **Write** tool for any content containing `!` and pass it via `@file` (`gh api … -F title=@<titlefile> -F body=@<bodyfile>`); set the real PR title at creation, never placeholder-then-rename (see `git.md`); for inline programs, match a distinctive substring without the `!` or run the program from a Write-created file. Verify suspect output with `od -c`.

## Verification & investigation

- Use LSP diagnostics and go-to-definition to understand and troubleshoot code — don't guess at types, imports, or call sites by grepping. When investigating errors: LSP/compiler output first, then read the relevant source — don't shotgun-grep.
- Before asserting a tool or system **can't**/**won't** do something — especially into long-term memory or as fact to the user — verify against a concrete artifact (a real PR, CI run, log line, command output). Confident negatives extrapolated from related notes are how wrong "facts" get recorded.
- A deployed change with **no observable effect** is a signal to find out *why it's inert* (config precedence, higher-priority layer, wrong scope, stale cache, not loaded) — not a cue to try the same setting elsewhere. Verify the **effective/resolved value** the process actually used, then read the source/issue tracker for the override mechanism before re-placing. Case study: work wiki `renovate-ce-config-precedence`.
- When confirming a fix or recovery from a metric/log signal, the signal must be **specific to the path you changed**, not ambient traffic on a shared component. Pick a discriminator that was measurably different during the outage, and require a second independent signal to agree. Case study: work wiki `o11y-loki-write-path`.
- A review subagent's findings are **claims to verify, not facts to relay** — before adopting a severity/repro, reproduce the exact trigger with a throwaway test (e.g. `go test -run …` on a probe file, then delete it). Subagent exploit examples are often directionally right but imprecise, and the imprecision changes the severity.
- When a request says "all uses" / "everywhere" / a plural or glob, enumerate the full match set first (Grep across the dir glob) and reflect the scope back ("that's N refs across M dirs, all of them?") before editing.
- When telling the user the exact invocation of an unfamiliar CLI, verify its flag-passing convention (`--flag=value` vs `--flag value`) against `--help`/docs/source first — many vendor CLIs (e.g. Volcengine `ve`) only accept space-separated values.
- When wiring dynamic credential fetching (AWS `credential_process`, `op run`, assume-role helpers), check the higher-precedence credential sources *first* — a leftover static entry (e.g. a `[profile]` block in `~/.aws/credentials`) silently wins and the helper never runs.

## GitHub API

- Multi-repo lookups via looped `gh api` hit the secondary rate limit after ~100 calls, and error-swallowing loops (`>/dev/null 2>&1`, `|| true`) turn that into false "all missing" results. Prefer **one batched GraphQL query** (alias per repo). If you must loop: keep stderr, pace with `sleep`, spot-check one item directly before trusting an all-negative result. Query files: write with **Write** (heredocs corrupt `!`/`@`) and pass with `gh api graphql -F query=@/abs/path` — `-F`, not `-f` (`-f` sends the literal string `@…`).
- To copy a file **verbatim** from a GitHub repo: `gh api repos/<o>/<r>/contents/<path> -H 'Accept: application/vnd.github.raw'`, then `cp` into place. Never WebFetch for byte-exact content — it returns a summarized rewrite.

## Kognic observability

- Grafana: always use the Grafana MCP server tools for dashboards, logs, metrics, alerts, and incidents — never curl or WebFetch the Grafana web UI.
- Validate PromQL/LogQL via `query_prometheus`/`query_loki_logs` (concrete values substituted for `${var}`) before it lands in a dashboard or alert — catches regex escaping, `label_replace` duplicate labelsets, rate-vs-counter mismatches.
- When investigating alerts, crash loops, or performance issues: invoke `kognic-devops:investigate` first — it has the LogQL/PromQL patterns and datasource UIDs.
- Querying apps that log huge structured-JSON DEBUG lines in Loki (token-cap blowouts, `|~` matching inside embedded blobs): use the patterns in the work wiki `reference_loki-noisy-json-queries` — `!=` pre-filters on tell-tale keys, structured-metadata equality over line substrings, distinctive event-marker anchors, minutes-tight windows.
