---
name: verification
description: How to back a claim with evidence before stating it — absence, root cause, regression, fix, speed-up, or a delegated finding. Use before asserting that something is absent, clean, unsupported, fixed, faster, a regression, or the root cause; when a query, grep, log search or subagent sweep comes back empty; when relaying subagent or reviewer findings; when confirming a fix from metrics or logs; when a live system changed and you need to know why. Also use when starting work on an existing issue, writing a test fake for a vendor SDK, removing or unifying a config key across several items, writing a rule to suppress a tool's unwanted change, or planning a rollout that narrows what a sync or reconciler manages.
---

# Verification

A claim is only as strong as the check behind it. For each situation below, find the check that would have come out differently if you were wrong, and run it.

## Proving a negative or absence

- An empty result only means something if the method could have matched. Run it against a known positive first. If you keep getting the same empty query while the user insists it happened, suspect your filter and switch to a field you have seen populated.
- Empty output from a command that failed looks the same as a real "none found". Keep stderr. Watch for parsers that stop early (bare `jq` on mixed logs: use `jq -R 'fromjson? // empty'`), Docker Desktop mounts (it doesn't share `/tmp`, so `-v /tmp/claude/…:/src` is silently empty: mount a path under `~/Code` and prove it with `docker run --rm -v "$PWD:/src" <img> ls -la /src`), and linters that report clean when they can't write their cache.
- A tool limit is not absence. When WebFetch says it "can't tell" because the page was truncated, fetch the page yourself, or call the JSON endpoint the page uses.
- A template language without conditionals can still derive a value by interpolating a key into a name or reference (GitLab `extends: .base-$[[ inputs.TAG ]]`). Check for that before proposing another caller-set input.
- "X can't do Y" needs a concrete artifact behind it: a real run, log line, PR or command output, not something you inferred from related notes.
- Check facts about how a system behaves against its source (code, Dockerfile, config at the deployed ref), not its README or CLAUDE.md, which drift. When the docs are wrong, fix them as part of the work.

## Naming a root cause

- Something being different from the last good run doesn't make it the cause. List what differs, then for each item ask "confirmed causal, or only present?" Leave unconfirmed suspects alone; harden the observed failure path or re-run to rule out a transient. Tell: you are pinning or reverting something you only saw *next to* the failure.
- An upstream issue with the same error string shows *one* way to get that error. Check that issue's own discriminator before adopting it.
- The compiler or build output is authoritative. LSP diagnostics are a hint.
- If something passes locally and fails in CI, compare pinned tool versions before you suspect the code. Reproduce with the binary CI uses.
- A test that fails only under the sandbox isn't a regression. If the error is `operation not permitted` on a path (`t.TempDir()`, a cache), re-run sandbox-off. If it is a plain assertion mismatch or a connection error, it has a hidden network dependency: make it hermetic.
- A dynamic credential helper (AWS `credential_process`, `op run`, assume-role) that seems ignored is usually shadowed by a higher-precedence static source (AWS: env vars, then `~/.aws/credentials`, before `credential_process` in `~/.aws/config`). Check those first.
- A change with no visible effect is inert for a reason (precedence, scope, cache, never loaded). Read the effective, resolved value the process used before trying the setting somewhere else.
- When you suppress a tool's unwanted change, match on the *role* of the thing (repo shape, published artifact vs consumer, prod vs staging), not on a pattern copied from the bad value. Tell: you explain the matcher by describing the bug.

## Claiming a regression or a fix

- Before calling something a regression, run the base version through the same probe. The gap often existed already, which makes it an incomplete fix rather than a break.
- A red check on a PR may not be the PR's fault. Reproduce on the base. Tells: the diff can't reach the failing code, or several PRs fail the same check.
- If the bug only shows up under condition X, a green run without X proves nothing. Say so, and name the run that would prove it.
- Before fixing an issue, check that its premise still holds at HEAD. The permalink shows a past state. `git log -S` tells you who changed the line.
- "This test doesn't discriminate" can be checked: copy the artifact and its test to a scratch dir, mutate the copy, and confirm that the named test fails. If you mutate in place, show `git diff` is clean afterwards — and remember `git checkout <path>` restores from the index, wiping every unstaged edit in that file, not just the mutant.
- Removing a config key falls back to the tool's or chart's default, which may be permissive. Before applying one value across a set, read each item's current default and verify its behaviour rather than assuming it matches the old safe value.
- A fake built from your own reading of an SDK only proves your code matches your assumption. Take field names from the installed package or a recorded response.

## Claiming a speed-up

- Measure; don't reason from geography or hop counts. Alternate runs of the same payload.
- A shorter runtime only counts if the work still happened. Check that real bytes moved, not dedupe or cache hits.

## Confirming via metrics or logs

- The signal has to be specific to the path you changed, not ambient traffic on a shared component. Pick a discriminator that was measurably different during the outage, and require a second independent signal to agree.

## Reviewing delegated findings

- Findings from subagents and reviewers are claims. Reproduce the exact trigger before adopting a severity, because an imprecise repro often changes the severity.
- For a "which of N don't do X" sweep, give the sweeper known-positive *and* known-negative anchors, require it to report both, and tell it where the fact must live so it enumerates authoritatively rather than relying on an index-lagged search. An all-clean result with no anchors looks exactly like a broken method. Verify any positives that survive yourself.

## A live system that changed at a known time

- Find what *ran* in that window (a merged PR's apply, a bot, a scheduled job) before you theorise from object metadata. Metadata tells you when something changed, rarely who changed it. Tell: you are weighing theories about an unknown actor.

## Delivery failures

- Get the sender's delivery record first (the provider dashboard, a GitHub App's Advanced tab) and join on delivery id. Receiver logs only cover what arrived. Tell: your mechanism explains only a minority of the failures.

## Fractional failures behind a load balancer

- A steady failure *ratio* points to per-connection selection across backends, some of them bad. Count the backends before blaming the network. A reset one RTT away comes from a rejecting backend, not transit.

## Before a rollout that narrows a reconciler's scope

- The first run has to delete everything it wrote before, so its size scales with history, not with the steady state. Count the items and check that count against every ceiling, including whole-request timeouts.
