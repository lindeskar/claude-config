---
name: github-api
description: >-
  Traps in the gh CLI and GitHub REST/GraphQL APIs that turn a broken query into a confident wrong
  answer. Use whenever running `gh api`, `gh run`, `gh pr checks`, `gh search` or `gh project`;
  when reading CI job logs or step results, waiting for checks or a workflow run to finish,
  fetching a file at a branch, SHA or tag, comparing two versions of upstream source, looking
  something up across many repos, checking branch protection or rulesets, posting a comment body
  from a file, or adding and verifying GitHub Projects items. Also covers jq/yq parsing of
  CI and log output and stating a PR's current state. Also use when writing or editing a GitHub
  Actions workflow that commits, versions or releases, or when designing a GitHub webhook or App
  handler.
---

# GitHub API

## Reading results you can trust

- **A `--jq` on a field the payload lacks returns `null`, not an error**, so a boolean check reads as false. REST and GraphQL name fields differently (`gh api repos/<o>/<r>` → `.archived`; `gh repo view --json isArchived`). When a negative would change your answer, print the whole object once and confirm the key exists.
- **Looped `gh api` hits the secondary rate limit after ~100 calls**, and error-swallowing loops turn that into a false "all missing". Prefer one batched GraphQL query with an alias per repo; if you must loop, keep stderr, pace it, and spot-check one item directly. `gh issue`/`gh pr` subcommands go through GraphQL; a GraphQL rate-limit error on a single call while `gh api rate_limit` shows REST quota left is a secondary limit — retry the same write via REST (`gh api repos/<o>/<r>/issues/<n>/comments -F body=@file`, `-X PATCH … -f state=closed`).
- **`-f key=@file` sends the literal string `@file`; only `-F` reads the file.** Write query/body files with the Write tool and pass `gh api graphql -F query=@/abs/path` or `… /comments -F body=@/abs/path`. Either flag switches the request to POST, so for a read put parameters in the quoted path (`'repos/<o>/<r>/contents/<p>?ref=<sha>'`) or use `-X GET`. When stubbing `gh` in tests, model `-f` as literal.
- **`branches/<b>/protection` 404s "Branch not protected" on branches protected by rulesets** (how org-level protection is applied). Read `repos/<o>/<r>/rulesets` instead. Active rulesets still don't make a check required: fetch `…/rulesets/<id>` and look for it in `required_status_checks`.
- **`gh api --paginate` joins array pages into one JSON array on raw output, but `--jq` runs once per page**, so `length`, `.[0]` or `first(…)` inside `--jq` print one line per page and read as a multi-line id or several counts. Aggregate in a piped `jq`, not in `--jq`.
- **Org-wide repo enumeration by custom property:** one paginated `GET /orgs/<org>/properties/values?repository_query=props.<name>:<value>` (the `props.` qualifier works only scoped to one org).
- **jq over output you don't control** (container logs, mixed CI output): a bare `jq` aborts at the first non-JSON line and hands back a truncated or empty result. Use `jq -rR 'fromjson? // empty | …'`.
- **Validate YAML/JSON with `yq`** (`/opt/homebrew/bin/yq`); the system `python3` has no `pyyaml`. `yq '.jobs.x.steps[]|select(.id=="auth")' f.yaml` proves the file parses and projects the field.
- **In `yq`/`jq`, `,` binds looser than `|`**: `.a[]|select(…)|.x, .y` evaluates `.y` against the root, returning a wrong value or a `null` that reads as "absent". Project the whole node (`yq -o=json '.a[]|select(…)'`) and read fields off it.

## PR state

- **Read the live state before analysing or reporting a PR** — `gh pr view <n> --json state,mergedAt,headRefOid` and `gh pr diff <n>`, not a remote-tracking ref or your memory of opening it. A "still open" or "CI still running" line in a report is a claim about now; re-read it after any gap.
- **Bot PRs get rebased mid-investigation**, invalidating captured diffs and job IDs. Capture `headRefOid` once, derive checks from it, and confirm a check belongs to that head before reporting pass/fail. A fresh run that is pending is "pending", not the previous run's failure.
- Contradictory signals (the diff says 8 files, a grep says more remain) mean stop and reconcile before acting.

## Fetching content

- Copy a file verbatim with `gh api 'repos/<o>/<r>/contents/<path>?ref=<ref>' -H 'Accept: application/vnd.github.raw'`. WebFetch returns a summarized rewrite, never byte-exact content.
- **Version-specific constants and defaults** (timeouts, feature-gate defaults, retry ceilings) come from the source at the exact tag the system runs, via the same fetch.
- **"What does this version bump change?"** Checksum the relevant source files at both tags (`contents?ref=<tag>` piped to `md5`); byte-identical files prove a no-op. The compare API caps at 300 files, so an empty filename filter there proves nothing. An added Computed-only attribute that the read path never populates yields a perpetual cosmetic diff.
- **Vendors not hosted on GitHub often mirror there** (GitLab: `gitlabhq/gitlabhq`; `lib/gitlab/ci/config.rb` `build_config` gives the CI config-processing order). Use the mirror when docs say *what* a feature does but not *when* it is evaluated.

## Waiting on CI

- Block on a result with `gh pr checks <n> --watch --fail-fast` or `gh run watch <id>`, run with `run_in_background: true` so the exit notification wakes you. These can outlive the foreground Bash timeout; sleep-polling in the foreground burns calls and dies at the timeout.
- **A non-zero exit from `gh run watch` or `gh pr checks --watch` isn't a failed run.** It also exits 1 when the API blips (last line `failed to get jobs: HTTP 502`). Read `gh run view <id> --json status,conclusion` before reporting a failure, and for long waits use a poll loop that retries on API errors.
- Keep exactly one wait in flight. Stacked background timers each fire a stale wake-up that reads as "the run finished".
- To size a wait, read the baseline first: `gh run list --workflow=<file> --limit 5 --json conclusion,createdAt,updatedAt`.
- For an event that is not imminent (the next cron run, a bot's next sweep, a review), suggest `/loop` or `/schedule` rather than holding the session.
- For an intermediate signal, poll the job's steps: `gh api repos/<o>/<r>/actions/jobs/<id> --jq '{status,conclusion,steps:[.steps[]|select(.conclusion!="success")]}'`.
- **In `statusCheckRollup` an in-progress check has `conclusion: ""`, not null**, so `.conclusion // "PENDING"` renders it as finished and a "nothing left running" count comes out wrong. Count what is unfinished with `select((.status//"COMPLETED") != "COMPLETED")`.

## CI runs and job logs

- **Selecting a job by name substring grabs a sibling job**, and the empty grep of the wrong log reads as clean. Print `id` and `name` together (`--jq '.jobs[]|"\(.id) \(.name) \(.conclusion)"'`) and pick by eye.
- **Both log routes return empty without failing**: `gh api …/actions/jobs/<id>/logs` on a re-run (`run_attempt` > 1), `gh run view --job <id> --log` on expired logs, and intermittently on fresh jobs. Check `wc -l` or grep a field you know is present before concluding absence; otherwise get the fact from a PR-comment reporter, the sibling attempt, or a re-run.
- **Job logs carry ANSI colour codes, and `gh api` refuses to print them without `--allow-escape-sequences`.** With `2>&1 > file` the refusal ("the response contains terminal escape sequences…") becomes a one-line "log" that greps as clean. Use `gh api --allow-escape-sequences repos/<o>/<r>/actions/jobs/<id>/logs | sed 's/\x1b\[[0-9;]*m//g'` and check the line count before reading it.
- **`gh run view --log-failed` can return post-job cleanup instead of the failure.** The teardown lines (`git config --unset`, "Cleaning up orphan processes") are the tail of the job, so the real error scrolls out of view and the output reads as a job that did nothing wrong. Get the error from the check-run annotations (`gh api repos/<o>/<r>/check-runs/<id>/annotations --jq '.[]|[.annotation_level,.message]|@tsv'`), or pull the whole job log and grep for the failing step by name.
- **Run records expire too**: `actions/runs?head_sha=<sha>` returns `[]` for an old commit, indistinguishable from "never ran". `gh run list --workflow=<file>` also returns `[]` for a disabled workflow (`gh workflow list` shows `disabled_manually`). For old history read the merged PR's status comments.
- **Before pushing a change meant to trigger CI, read the trigger rules** (`on.*.paths`/`branches`, GitLab `rules: changes:`) and touch a file inside them. A change outside the filters gives a green PR that ran nothing. In `annotell/gitlab-ci-volcano`'s terraform template every plan/apply/status job is gated on `$TF_PATH/**/*`, so the change must sit inside a declared `TF_PATHS` directory.
- **Green CI on a dependency or toolchain bump**: report which of these hold rather than "CI is green": the workflow's `paths:` matched the change; the bumped component ships in the runtime artifact (read the Dockerfile's final stage; a build-only toolchain is verified by a successful build); some job exercises the production build (Playwright `webServer: npm run dev` does not). Name the residual gap.

## Authoring workflows and automation

- **Auto-commit steps stage with `git add -u`**, never `-A`. `-A` sweeps in untracked workspace files such as the `gha-creds-*.json` that `google-github-actions/auth` drops, and a sibling `git diff --quiet` check cannot see untracked files.
- **`ietf-tools/semver-action` on a schedule needs both `noVersionBumpBehavior: silent` and `noNewCommitBehavior: silent`** to skip quiet weeks; gate downstream steps on `steps.<id>.outputs.nextStrict != ''`. Bots commit `fix(deps):`, which counts as a patch.
- **GitHub never redelivers a failed webhook** (non-2xx or no answer within 10s); redelivery is manual via the App's Advanced tab or `POST /app/hook/deliveries/<id>/attempts`. A handler gives latency, not correctness: anything with durable consequences needs a scheduled reconcile sweep, and a "GitHub will retry" premise in a design is a lost-state bug.

## Projects

- **Verify `gh project item-add` with `--format json` on the add itself**, which returns the item `id`. `gh project item-list` defaults to 30 items and silently truncates large projects.
- **"Not on the project" can't be concluded from the issue side across orgs**: `gh issue view --json projectItems` and GraphQL `issue.projectItems` return empty for an issue in one org on another org's project. Query from the project side (`organization.projectV2(number:).items`, paginated, filtered on `content.repository.nameWithOwner` and `content.number`).
