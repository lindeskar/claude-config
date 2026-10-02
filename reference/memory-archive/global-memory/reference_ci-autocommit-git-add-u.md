---
name: reference_ci-autocommit-git-add-u
description: In CI auto-commit steps use `git add -u` (tracked files only), never `git add -A`, so stray untracked workspace files (auth creds, caches) can't be swept into the commit
metadata:
  type: reference
---

A CI step that regenerates derived files and commits them back (e.g. a renovate-render / auto-format loop) should stage with **`git add -u`**, not `git add -A`.

`-u` stages only modifications/deletions to **already-tracked** files. All the derived outputs a generator refreshes are already committed, so `-u` captures every real change — including ones outside a single subdir (schemas, docs), so a naive `git add examples/`-style narrowing would *miss* those and leave a verify job red.

`git add -A` additionally stages **new untracked** files, which is how stray workspace artifacts get committed. Concrete case: `google-github-actions/auth` drops a `gha-creds-*.json` WIF file into the workspace; `application-helm`'s `renovate-render.yaml` `git add -A` committed it to master (issue #294, fixed in annotell/application-helm#295 by switching to `git add -u`).

Note a sibling verify job's `git diff --quiet` dirty-tree check does **not** catch this — it only sees tracked-file changes, so the untracked creds file passes verification and only surfaces once the auto-commit step stages it. See [[feedback_verify-ci-trigger-rules]].
