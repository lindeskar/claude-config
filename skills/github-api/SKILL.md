---
name: github-api
description: >-
  Use the gh CLI and GitHub REST/GraphQL APIs without hitting the traps that turn a broken query
  into a confident wrong answer. Use when calling gh api, polling or reading CI runs and job logs,
  doing multi-repo lookups, fetching file contents from a repo, or working with GitHub Projects.
  Covers null --jq reads, secondary rate limits, empty-log false negatives, job selection by name,
  and project item verification.
---

# GitHub API

## Reading results you can trust

- **A `--jq` on a field the payload doesn't have returns `null`, not an error — so a boolean check silently reads as false.** REST and GraphQL name the same fields differently (`gh api repos/<o>/<r>` → `.archived`; `gh repo view --json isArchived` → `.isArchived`), so reaching for the wrong one reports "not archived" for an archived repo. When a negative result would change what you tell the user or do next, print the whole object once (`gh api repos/<o>/<r> --jq '{archived,disabled}'`, or no `--jq` at all) and confirm the key exists rather than trusting a bare falsy value.
- **Multi-repo lookups via looped `gh api` hit the secondary rate limit after ~100 calls**, and error-swallowing loops (`>/dev/null 2>&1`, `|| true`) turn that into false "all missing" results. Prefer **one batched GraphQL query** with an alias per repo. If you must loop: keep stderr, pace with `sleep`, and spot-check one item directly before trusting an all-negative result. Query files: write with the **Write** tool (heredocs corrupt `!`/`@`) and pass with `gh api graphql -F query=@/abs/path` — `-F`, not `-f` (`-f` sends the literal string `@…`).

## Fetching content

- To copy a file **verbatim** from a GitHub repo: `gh api repos/<o>/<r>/contents/<path> -H 'Accept: application/vnd.github.raw'`, then `cp` into place. Never WebFetch for byte-exact content — it returns a summarized rewrite.
- **When an explanation hinges on a version-specific constant or default** — a hardcoded timeout, a feature-gate default, a retry ceiling — read it out of the source at the exact tag the system runs: `gh api 'repos/<o>/<r>/contents/<path>?ref=<tag>' -H 'Accept: application/vnd.github.raw'`. Never from recall.
- **To answer "what will this version bump actually change?", checksum the specific source files at both tags** — the same `contents?ref=<tag>` fetch for each version piped to `md5`. Byte-identical files prove the behaviour can't have changed, which turns an alarming-looking diff into a provable no-op and is far cheaper than reading a 300-file compare. The compare API also silently caps at 300 files, so an empty filename filter there is not evidence of "no changes". Pair it with the schema/read path: an added **Computed-only** attribute that the resource's read never populates yields a *perpetual* cosmetic diff, not one that settles after an apply.
- **Vendors whose canonical home isn't GitHub often mirror there — check for a mirror before giving up on reading the source.** GitLab itself is mirrored at `gitlabhq/gitlabhq`, so the `contents` recipe settles behaviour the docs omit: `lib/gitlab/ci/config.rb` `build_config` lists the config-processing order (input interpolation → `include` → `extends` → `!reference`), which decides whether one CI feature can be composed with another. Reach for this whenever docs describe *what* a feature does but not *when* it is evaluated relative to another.

## CI runs and job logs

- **Size a poll from the workflow's known baseline, and keep exactly one timer in flight.** Look the duration up *first* — `gh run list --workflow=<file> --limit 5 --json headBranch,conclusion,createdAt,updatedAt` on recent runs — then set a single background wait to match, instead of discovering the length by repeated polling. Two failure modes: (a) poll-sleeping in short increments on a long job, burning calls before ever checking the baseline; (b) **stacked overlapping background timers** — each fires its own notification when *it* expires, so you get a burst of stale wake-ups for sleeps started cycles earlier, which read as "the run finished" when nothing has. `gh run watch <id>` can exceed the Bash timeout ceiling, so background it too.
- When you need an intermediate signal, poll the *job* rather than the run and read step conclusions: `gh api repos/<o>/<r>/actions/jobs/<id> --jq '{status,conclusion,steps:[.steps[]|select(.conclusion!="success")]}'`. That pinpoints whether the step you care about (a WIF auth step, say) has passed without waiting for the whole suite.
- **Selecting a CI job by name substring silently grabs a sibling job, and the resulting empty grep reads as a clean result.** A filter like `.name|contains("tf_dir")` matches both `Find tf_dirs` and `tf_dir: <state>`; you then grep the wrong log, find nothing, and conclude the plan was clean. Always print `id` *and* `name` together (`--jq '.jobs[]|"\(.id) \(.name) \(.conclusion)"'`) and pick by eye.
- **Both log routes return empty in cases that look nothing like failure** — `gh api …/actions/jobs/<id>/logs` on a re-run (`run_attempt` > 1), and `gh run view --job <id> --log` on older runs whose logs expired, plus intermittently on fresh successful jobs. Never read empty log output as "the thing isn't there": pipe to `wc -l` (a 1-line result means no log, not no match) or grep a field you know is present, and only then conclude. When the log won't come back, get the fact another way — the PR-comment plan reporter where one exists, the sibling attempt, or a re-run — rather than reporting absence as evidence.

## Projects

- **Verify a `gh project item-add` from the add call, not `item-list`.** `item-add` prints nothing on success in some `gh` versions; confirm by adding `--format json` to the *item-add* itself, which returns the new item `id`. Do **not** verify with `gh project item-list` — it defaults to 30 items and silently truncates a large project (e.g. annotell PlatEng #23), giving a false "not added".
- **Never conclude "this issue isn't on the project" from the issue side — that check is broken across orgs.** For an issue in one org on a project owned by another (e.g. a `kognic-internal/devplat` issue on the `annotell` PlatEng project), both `gh issue view --json projectItems` and GraphQL `issue.projectItems` return an **empty list even when the item demonstrably exists** (status readable, item id known). Querying from the *project* side is authoritative: `organization.projectV2(number:).items`, paginated and filtered on `content.repository.nameWithOwner` plus `content.number` — or read back the item id that `item-add` returned. A false "not on the project" invites an unnecessary manual add and can make you distrust a correct memory.
