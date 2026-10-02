---
name: renovate-upstream-contributing
description: Building, testing and contributing to renovatebot/renovate locally — pnpm without corepack, re2 fallback, coverage gates, and the PR rules that fail CI (AI disclosure, no "Closes #" in commits, RE2 regex wrapper)
metadata:
  type: reference
---

Local setup and the non-obvious gates for a PR to `renovatebot/renovate` (fork clone lives under `~/Code/_forks/renovate`).

**Getting pnpm.** The repo pins pnpm via `packageManager` (and node via `mise.toml`, which isn't installed here). `corepack enable` fails on a Homebrew node with `EPERM … symlink … /opt/homebrew/…/bin/pnpm`, but `corepack pnpm <args>` works without enabling: it fetches and runs the pinned version (run sandbox-off). `pnpm check` spawns a bare `pnpm` for each sub-check, so every check "fails" in 0s unless `pnpm` is on PATH. Put symlinks to corepack's entry points in a private dir and prefix PATH for that call: `ln -s /opt/homebrew/Cellar/node@24/<ver>/lib/node_modules/corepack/dist/pnpm.js /tmp/claude/corepack-bin/pnpm`, then `PATH=/tmp/claude/corepack-bin:$PATH pnpm check --all <paths>`. The fallback is `npm i -g pnpm@<pinned> --prefix /tmp/claude/pnpm`.

**re2 builds when node matches the pin.** On the `mise.toml` node version, `pnpm install`'s prepare step reports `Checking re2 ... Ok`. On a mismatched node it fails (`MODULE_NOT_FOUND` / `NODE_MODULE_VERSION`) while JS deps still install. Renovate's `regEx()` wrapper then falls back to native `RegExp`, so tests pass with `RENOVATE_X_IGNORE_RE2=1` (plus `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LOG_LEVEL=fatal`). CI runs the real re2, so avoid regex constructs re2 rejects (below).

**Run from source for end-to-end checks:** `node <checkout>/lib/renovate.ts --platform=local --dry-run=lookup`, with `RENOVATE_CONFIG_FILE`, `LOG_FORMAT=json` and `LOG_LEVEL=debug`, from a scratch git repo. Node 24 runs the `.ts` directly. Compare before and after by running the same config against an unmodified `main` checkout. Committing needs the global-gitignore workaround in [[reference_global_gitignore_lib_dir]].

**Multi-agent work in one worktree: mutation testing must use scratch copies.** A reviewer that mutates a source file in place to prove a test discriminates taints any reviewer running at the same time (a repro run tested a mutant and reported a false regression). Two in-place mutation scripts sharing one backup path can also "restore" a mutant. Tell agents to mutate copies only. Afterwards, grep the final file for each mutant's marker before trusting it.

**Code constraint: `regEx()` means RE2 — no lookahead/lookbehind.** All regexes go through the `regEx()` wrapper; RE2 rejects lookarounds, so `str.split(/(?=[-+])/)` is not acceptable even though it works locally under the fallback. Use `str.search(regEx(/[-+]/))` plus `slice` instead. A maintainer will flag this in review.

**Tests and coverage.** `node_modules/.bin/vitest run <path>` (`-t "<describe or it substring>"` to narrow; `--coverage.enabled=false` for speed). CI requires **100% coverage**, so every branch of new code needs a test — including ones only reachable on a tie (e.g. an operator-priority tie-break never runs unless two inputs compare equal). Gotcha: `--coverage.include='<dir>/<file>.ts'` matches nothing and silently prints an empty table; use a `'<dir>/**'` glob and add `--coverage.skipFull=false` to see files that are already at 100%. Verify a pre-existing coverage gap is pre-existing by re-running the same command with the file checked out from `upstream/main`.
`pnpm check [path]` mirrors CI (add `--fix`, `--no-test`); individually: `oxlint -c .oxlintrc.json`, `biome check`, `prettier --check`, `tsc --noEmit`. A pre-commit lint-staged hook auto-fixes staged files.

**PR rules that actually fail CI or annoy maintainers:**
- **AI assistance must be disclosed** in the PR body, naming the model and extent — the template has a checklist section and contributing.md calls non-disclosure rude. Non-negotiable.
- **No issue-closing keywords in commit messages.** A `closes-issue-or-discussion` check scans commits and fails on `Closes #NNN` in a commit body — the keyword belongs in the PR description only. Fixing it means rewording the commit (the one legitimate force-push case, fine on a fresh unreviewed PR).
- **Do not force-push after review has started**; they squash-merge, so extra commits are free. Apply review suggestions as a new commit, then *resolve* the threads instead of commenting "done".
- Sign the CLA (cla-assistant bot comments on first PR).
- **Open as draft; mark ready only once the CLA is signed and the user confirms** (AGENTS.md). The template's "Who answers review comments" needs one box with a named account. A PR that closes no Issue must link a public reproduction repo, or state the reason in the template's code block. Upstream issues are admin-only, so bugs go to Discussions (Request Help) first, and a maintainer reply there is the go-ahead.
- Two failing checks may just be GitHub infra: `Failed to resolve action download info. Error: Service Unavailable` in `Set up job` clears on re-run and blocks downstream jobs as "skipping".

**Terraform lock manager orientation** (`lib/modules/manager/terraform/lockfile/`): `util.ts` parses/writes `.terraform.lock.hcl` blocks (`extractLocks`, `writeLockUpdates`); `index.ts` `getNewConstraint()` computes the new `constraints` string per provider dep and is the seam for anything about constraint text. Terraform's own canonical serialization to mirror lives in `hashicorp/terraform` → `internal/getproviders/providerreqs/version.go` (`VersionConstraintsString`, `versionSelectionsBoundaryPriority`) — read it at the tag rather than inferring the ordering rules.

See also [[verify-current-pr-state]].
