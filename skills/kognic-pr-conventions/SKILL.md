---
name: kognic-pr-conventions
description: Kognic GitHub conventions for commit types, PR titles, PR bodies, labels and PR comments in the annotell and kognic-internal orgs. Use when writing a commit message, PR title or PR body; when opening, editing, closing or labelling a PR; when working in a release-please repo or a repo that publishes a reusable workflow, action or Renovate preset; when a "Validate PR title" check fails; when posting a code review as a PR comment; or when fixing an alert with a PR.
---

# Kognic PR conventions

## Commit and PR type

- **Type by consumer impact of the released artifact, not by which paths changed.** A repo that publishes something others consume (`on: workflow_call` reusable workflows, composite actions, `annotell/renovate-config` presets) ships a behaviour change as `fix:`/`feat:`, even when the diff is under `.github/workflows/` or a `*.json`. `ci:`/`chore:` is only for this repo's own plumbing.
- **Release-please hidden types ship nothing.** `ci`, `chore`, `docs`, `refactor` and friends render no changelog section, so no version is cut. Squash-merge uses the PR title as the commit, so a consumer-facing fix titled `ci:` lands on master and reaches nobody. Mechanics: work-wiki memory `reference_release-please-commit-type-visibility`.
- **`!` means the released artifact breaks for its consumers** (removed input, changed API). Rollout sequencing, CI-template flips and config changes are not breaking; put ordering in the PR body.
- **Pointer bumps are not the break.** Moving a pinned version or image-tag default to a release that contains a breaking change is `chore`/`fix(deps)`. The `!` belongs to the one commit that changed the component's own interface; repeating it double-counts the major bump. Ask: does this commit change this component's inputs, outputs or contract?

## PR title validation

The `annotell` "Validate PR title" check is served by the `kognic-github-app` over webhooks and re-evaluates on a title edit. Fix a failure in place with `gh pr edit <n> --title "..."` — no close/reopen, no empty commit. Allowed types: `feat`, `feature`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. A repo's history may use types the check rejects, so don't infer the set from `git log`. For a title containing `!`, Write it to a file (no trailing newline) and `gh api -X PATCH repos/<o>/<r>/pulls/<n> -F title=@<file>`.

## Labels

Add `autoreview` (`gh pr create --label autoreview` or `gh pr edit <n> --add-label autoreview`) to PRs that touch only staging environments in `kognic-cd`, `k8s-platform-gitops` or `k8s-platform-gitops-volcano`; the bot skips unlabelled PRs. Never on a PR that touches a prod path.

## Before branching

- **Scope a consumer PR to the behaviour change; let Renovate own version bumps.** A shared-artifact release makes Renovate open a bump PR in every consumer, and a hand-bump on the same line conflicts even at the identical SHA (positional, not textual).
- **Check for in-flight work on the same lines:** `gh pr list --repo <o>/<r>` and `wt list`.
- **Fixing a firing alert:** search by the alert and metric name, not the file you plan to edit — `gh pr list --repo <o>/<r> --state all --search "<AlertName>"`. A teammate may already have pulled a different lever.

## PR body

- Lead with intent: one sentence of why/what it achieves, plus any tracking link. Add a second sentence only for context the diff can't show. `## Summary` bullets only for genuinely multi-concern changes.
- Cut what no reviewer will act on: file lists, counts, before/after strings, mechanism walk-throughs, sequencing notes, hedges, versions or sibling PRs you checked against. Describe what changed, not what you left out.
- Short plain sentences, concrete cause first, plain words; blank lines between cause, fix and cross-reference.
- Present tense ("both render", not "both rendered"); capitalize Kubernetes/CRD resource types (`Namespace`, `ExternalSecret`, `Application`).
- Keep the body in sync when a later commit changes something it names; body/title edits don't dismiss approval.

## Links

Verify which repo a reference lives in first (most plateng tracking issues are in `kognic-internal/devplat`, not all). In GitHub bodies and comments paste the plain full URL (blob URL for a file) and let GitHub render it — no `[text](url)`. In chat replies use `[owner/repo#NNN](url)`.

## Comments, closing, CI triggers

Voice and length of conversational comments and review replies: `drafting-messages`.

- **Posting a code review:** keep any `` `/anthropic-review-pr:review-pr` output: `` marker line above, then wrap the body in `<details><summary>Code review results</summary>` … `</details>`, with a blank line after `<summary>` and before `</details>` so markdown renders. Write the body to a file and `gh pr comment <n> --repo <o>/<r> --body-file <path>`.
- **Closing with a comment:** `gh pr comment <n> --body-file <path>`, then `gh pr close <n>` as a separate call (`close --comment` takes only an inline string).
- **A throwaway change added only to trigger CI is reverted as soon as CI is green.** Squash-merge folds every commit in, so a "remove before merge" marker doesn't stop it landing.
