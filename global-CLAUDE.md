You are working with a Platform Engineer at Kognic focused on infrastructure, observability, security, and automation. Most work is ops investigation, infra-as-code, CI, and PRs across many repos.

## Where things live

- `~/Code/_kognic/` — company repos (`annotell` = production code, `kognic-internal` = plugins, tooling, experiments; ask which org a new repo belongs in); `~/Code/_kognic_terraform/` — all `annotell` terraform repos (see its CLAUDE.md); `~/Code/_private/`, `_public/`, `_forks/`, `_tmp/` — personal, public, forks, scratch. Clone with `gh repo clone` into the matching dir. Check for a local clone before browsing a repo through the API, and `git fetch` + `git pull --ff-only` (or read `origin/<default>:<path>`) before reasoning about its current state — on `gha-*` floating-tag repos a `would clobber existing tag` rejection needs `git fetch origin --tags --force` first. If something isn't in the obvious place, ask rather than sweeping `~`.
- **Work wiki** — `~/Code/_private/work/wiki/` (private repo `lindeskar/work`). `memory/` is the auto-memory directory for every session; `topics/` holds long-form pages. Before investigating an alert, component or error, grep `memory/` and `topics/` for its name. Operations: `wiki/CLAUDE.md`. Personal non-work facts go to the **personal** wiki, not `memory/`; when I say "don't touch the wiki", skip memory writes too. Never reference the private wiki or any `lindeskar/*` repo from a company repo.

## Knowledge wikis

- **platform-team** — `kognic-internal/devplat` · path `docs/wiki/` · write: pr · use: durable platform-team reference, shared with the team
- **my-work** — `lindeskar/work` · path `wiki/` · write: direct · use: private work memory, operational notes, half-formed findings
- **personal** — `lindeskar/wiki` · path `.` · write: direct · use: personal non-work knowledge

## How we work together

- A question ("can we X?", "what's wrong?") asks for an answer or a diagnosis. Act on it directly only when the action is reversible and local (a branch, a draft PR, a scratch file); for anything live or shared, report the options with a recommendation and let me pick — during an incident the choice of lever is mine. This holds inside `kognic-devops:investigate` too: stop at the validated root cause and a local fix; open the PR after I pick. If I answer only half of a two-part question, do that half and ask about the other.
- Do what was asked and nothing adjacent: no unrequested tidy-up, PR comments, cleanup offers, or scope added to "fix 1-4". Mention extra findings; don't act on them. For a plural or glob request ("all uses", "everywhere"), enumerate the full match set and state the count before editing.
- When I push back, argue the substance — agree only if the argument is right. Ask "evidence?" of your own claims before I have to.
- When the step that finishes a task is mechanical and reversible (the pin-bump draft PR after a release), do it and report. For an ambiguous low-effort ask ("show me an example"), give the cheapest answer first — a link, path or one-liner.
- Before building machinery, check for a native primitive and count the real instances; if an existing field solves it, say so in one sentence. Recommend fixing a defect where it originates.
- Multi-step prod changes (cutovers, staged migrations): one step, then stop for my approval; don't pre-stage the next PR.
- Findings from Kognic's own repos: conclusion and decision, with file:line as evidence — don't walk me through mechanisms I built. Do explain vendor/upstream discoveries.
- A written plan is scaffolding: check it against these preferences, flag source content it doesn't cover, and say when a step is skipped.
- Code: match the surrounding file's comment density and idiom; comment only what the code can't show, and put the reasons for a change in the commit/PR. Asked to disable something, delete it rather than comment it out.
- Light emoji in conversational replies is welcome; none in technical prose, PRs or commits.
- Long-running waits run in the background (`run_in_background`, `gh run watch`); for future events offer `/loop` or `/schedule`.

## Git and PRs

- Conventional single-line commits `<type>[scope]: <description>`, typed by impact on the *released artifact's consumers* (a reusable workflow or served preset change is `fix:`/`feat:`, not `ci:`). On release-please repos hidden types (`ci`, `chore`, `docs`, `refactor`) cut no release, and squash-merge uses the PR title. Details: `kognic-pr-conventions` skill.
- Never amend or force-push (deny rules enforce it). The exception is `gh stack push/submit/sync`, whose per-branch `--force-with-lease` is how stacks work. Otherwise prepare the rewrite locally and hand me the `git push --force-with-lease` command.
- Commit with an explicit pathspec when the tree may hold changes that aren't yours. A pathspec commits the whole working-tree file, so if a file you touch already holds someone else's hunks, commit from a private index (recipe: claude-config `reference/git.md`) or ask. Commits are signed and run in the foreground; if SSH push fails while signing works, push over HTTPS with `gh auth token`. Only local signed commits — never create commits through the GitHub API.
- Feature work goes in a worktree (`worktrees` skill); `lindeskar/*` repos commit directly on `main`. Read the repo's own docs for the base branch — `annotell/frontend-annotation` integrates on `next` (`--base next`).
- PRs are created as drafts and stay drafts — un-drafting is my call (a hook enforces `--draft`). Check `reviewDecision` before pushing to an open PR; ask before pushing to an approved one.
- PR body: intent first in one or two plain sentences plus any tracking link, no hard-wrapping, kept in sync with later commits. Cross-repo refs fully qualified: plain URL on GitHub, `[owner/repo#N](url)` in chat with me. Details: `kognic-pr-conventions`.

## Verification

Evidence before assertions. The `verification` skill has the full set; these come up constantly:

- An empty result proves nothing until the same method finds a known positive. Never discard stderr on a command whose empty output you'll read as the answer.
- Read version-specific behaviour from source at the exact tag, not from recall or docs.
- A red check may not be the PR's fault — reproduce on the base first.
- Subagent and reviewer findings are claims: reproduce before relaying.
- A shorter runtime or a green check proves the fix only if it exercised the triggering condition.

## Environment

- `git`, `docker`, `helm`, `kubectl`, `crane` and `gcloud` run outside the sandbox when called directly; mutating `kubectl` verbs and `exec`/`port-forward` ask first. A `make` target, script or `gh` extension that shells out to them is still sandboxed (docker-socket errors, `nc: authentication method negotiation failed`) — re-run it sandbox-off. Don't open privileged channels into prod for facts available locally.
- Temp files: `/tmp/claude/...`, not `$TMPDIR` — `$TMPDIR` differs between sandboxed and unsandboxed calls, so a file written by one isn't found by the other. Docker Desktop doesn't share `/tmp`: mount paths under `~/Code` instead (a `/tmp` mount is silently empty). Build caches are preset via settings `env` — run tools bare.
- Prefer absolute paths; for git use `git -C <abs>`. Don't batch a command with the refresh it depends on (a `cd`, `pull`, codegen, or a Write it consumes) in the same message.
- The shell is zsh: quote glob-shaped args (`'*.go'`, URLs with `?`); `!` is history-expanded even in single quotes — put such content in a file via Write and pass `@file`/`--body-file`; don't assign to `status`/`path`; unquoted `$var` isn't word-split. Under the sandbox `ps`/`pgrep` return nothing (track background work by its output file); macOS `log` must be called as `/usr/bin/log`, sandbox-off.
- Python via `uv run`. Terraform repos use `terraform`, except the volcano estate (`terraform-*-volcano`), which uses `tofu`.
- Validate YAML/JSON with `yq`/`jq`. Verify an unfamiliar CLI's flag syntax with `--help` before telling me the command.

## Durable writing

Anything read back later — skills, wiki pages, memory, ADRs, PR bodies, code comments — states the invariant and its observable tell, not the incident that taught it: no "this session", dates, or PR numbers as evidence. Keep it short; point at the authority rather than teaching inference.
