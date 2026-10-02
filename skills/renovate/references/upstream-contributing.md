# Contributing to renovatebot/renovate

The fork clone is at `~/Code/_forks/renovate`.

## Toolchain

- pnpm is pinned through `packageManager`. `corepack enable` fails on Homebrew node (EPERM symlink), but `corepack pnpm <args>` works (run it with the sandbox off). `pnpm check` spawns a bare `pnpm`, so put a symlink to corepack's `dist/pnpm.js` in `/tmp/claude/corepack-bin/` and prefix `PATH` with it. As a fallback, run `npm i -g pnpm@<pinned> --prefix /tmp/claude/pnpm`.
- re2 only builds on the node version in `mise.toml`. On any other version, tests still pass with `RENOVATE_X_IGNORE_RE2=1 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LOG_LEVEL=fatal`, but CI runs the real re2.
- To run from source end to end: from a scratch git repo, run `node <checkout>/lib/renovate.ts --platform=local --dry-run=lookup` with `RENOVATE_CONFIG_FILE`, `LOG_FORMAT=json` and `LOG_LEVEL=debug`. Compare the output against an unmodified `main` checkout.

## Code and tests

- All regexes go through `regEx()`, which uses RE2. RE2 has no lookahead or lookbehind, so use `search` plus `slice` instead.
- `node_modules/.bin/vitest run <path> -t "<name>"`. CI requires 100% coverage, including branches that only run on a tie. `--coverage.include` needs a `'<dir>/**'` glob, because a single-file pattern prints an empty table. Add `--coverage.skipFull=false` to see it.
- `pnpm check [path]` mirrors CI. Run mutation tests on scratch copies, never in a shared worktree.
- To find your way around the Terraform lock code: start in `lib/modules/manager/terraform/lockfile/` (`util.ts` parses and writes the lock, and `getNewConstraint()` in `index.ts` builds the constraint text). Read Terraform's canonical constraint ordering from `hashicorp/terraform` `internal/getproviders/providerreqs/version.go` at the exact tag.

## PR rules that fail CI or bother maintainers

- Say in the PR body that AI helped, naming the model and how much.
- Keep issue-closing keywords out of commit messages. The `closes-issue-or-discussion` check scans commits and fails on them, so they belong in the PR body.
- Open the PR as a draft. Mark it ready only after the CLA is signed and the user agrees. Fill in "Who answers review comments". A PR that closes no issue needs a public reproduction repo or a stated reason. Bugs start as a Discussion.
- After review starts, push suggestions as new commits (they squash-merge), then resolve the threads.
- If `Set up job` fails with `Failed to resolve action download info ... Service Unavailable`, that's GitHub infrastructure. Re-run it.
