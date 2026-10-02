---
name: reference_global_gitignore_lib_dir
description: Global ~/.gitignore ignores any dir named lib/ — projects with src/lib/ need a repo-level negation
metadata:
  type: reference
---

The user's global `~/.gitignore` contains a `lib/` pattern, which ignores **any** directory named `lib` at any depth — including `src/lib/`. This silently drops source files in frameworks that use that layout (SvelteKit's `src/lib/`, and others), and `git add` appears to succeed while the files never get tracked (the symptom is a teammate/agent needing `git add -f`).

Fix at the repo level by re-including the path in the project's `.gitignore`:

```
# Global ~/.gitignore ignores any directory named `lib/`.
!src/lib/
!src/lib/**
```

Verify with `git check-ignore src/lib/<somefile>` — exit code 1 (no output) means it is no longer ignored.

Check this proactively when scaffolding any JS/TS project that puts source under `src/lib/` (SvelteKit especially). Discovered building the `bud-get` SvelteKit app, where the second task's files were only committed via `git add -f` before the negation was added.

**It also breaks committing *tracked* files under a repo's top-level `lib/`** (e.g. the Renovate fork). `git add lib/...` refuses with `The following paths are ignored ... lib`, and a lint-staged pre-commit hook fails at "Failed to stage changes from tasks!" (`lint-staged failed due to a git error`), leaving an automatic-backup stash entry behind. Don't add a negation to someone else's repo or skip the hook: stage with `git add -u`, and commit with the global excludes file switched off for that one command, in a way child `git` processes inherit — `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0=/dev/null git commit …`. Then drop the hook's backup stash by its SHA. Diagnose with `git check-ignore -v --no-index lib`.
