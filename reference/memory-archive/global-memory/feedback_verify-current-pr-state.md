---
name: verify-current-pr-state
description: When asked to look at/act on an existing PR, establish its CURRENT state first; don't trust a stale remote-tracking ref
metadata:
  type: feedback
---

When the user asks me to look at or act on an existing PR or branch, establish ground truth of its **current** state before forming any conclusion or starting work.

On 2026-06-05, asked to "open PRs to reverse module sources" and pointed at an already-open PR (terraform-devplat-volcano#400), I ran `git grep origin/<branch>` against a stale remote-tracking ref, concluded the migration was *partial* ("10 files remaining"), and spun up a worktree to "complete" it — when the PR was already complete. The reverse CLI returning 0 changes was what finally exposed the wrong premise. I had even seen a contradictory signal (`gh pr diff` showed 8 files while my grep claimed Kognic modules remained) and pushed past it instead of resolving it.

**Why:** Acting on a stale or misread snapshot wastes effort and can produce confidently-wrong analysis presented to the user. Remote-tracking refs go stale between fetches; an early grep is not the live state.

**How to apply:**
- First thing when handed an existing PR: `git fetch` then read the live state — `gh pr view <n> --json ...` and/or `gh pr diff <n>`, or grep the actual worktree HEAD — before analyzing or planning changes.
- Never conclude "incomplete/partial" and start "completing" someone's work without confirming against the current head.
- Treat contradictory signals (diff says X files, grep says otherwise) as a STOP-and-reconcile trigger, not noise to push past. Resolve the contradiction before acting.

**A bot-managed PR is a moving target — artifacts captured earlier in the *same* session go stale.** A Renovate/Dependabot PR can be rebased mid-investigation, which invalidates any `gh pr diff` output *and* any check-run/job ID you captured from an earlier `gh pr checks`. Reusing them produces two specific false reports: a phantom "these two PRs behave differently" discrepancy, and a "CI is failing" verdict read from a job belonging to a superseded run. So: capture `headRefOid` once, re-derive the diff and checks from it, and confirm a check belongs to the current head (`gh api repos/<o>/<r>/commits/<sha>/status` shows per-status `created_at`) before reporting pass/fail. When a fresh run is `pending`, say pending — don't report the previous run's failure as the current state. Reconcile a surprising result *before* surfacing it to the user, not after.

**This applies to *reporting* a PR's state, not just acting on it — including PRs I opened myself.** A status line in a summary ("still outstanding: #NNN, still a draft") is a claim about the live world, and after any conversational gap the user may have merged it. Quoting my memory of creating the PR produced a wrong report that the user had to correct. Before naming a PR's state in a report, re-read it (`gh pr view <n> --json state,mergedAt`) — it costs one call, and a stale "still open" both misinforms and reads as though no one is watching. Same for "CI is still running" and "not yet reviewed".

**Read a lock/config diff with enough context to attribute lines to the right block.** Grepping only `^[+-].*(version|constraints)` out of a multi-provider `.terraform.lock.hcl` diff drops the `provider "..."` headers, so changed lines get attributed to the wrong provider. Include the block header (or `-B`/`@@` context) whenever the same field name repeats per block.

See also [[verify-ci-trigger-rules]].
