---
name: reference_revert-mutation-in-dirty-tree
description: Reverting a mutation test with `git checkout <path>` destroys every unstaged change to that file, not just the mutation
metadata:
  type: reference
---

`git checkout <path>` restores the file from the **index**, so in a tree whose
changes are unstaged it discards all of them — not only the mutation you just
applied. The tell is a `git diff --stat` whose line counts drop for that file
after the "revert".

Mutation-check in a tree you intend to keep by one of:

- `git stash push -u -m "<unique-tag>"` is **not** the escape hatch — the stash
  stack is shared across worktrees and other sessions.
- `cp <file> <file>.bak`, mutate, test, `mv <file>.bak <file>` — no git involved.
- `git add` the real work first, then `git checkout <path>` reverts only to the
  staged state.
- Best: copy the artifact **and its test** to a scratch dir outside the repo and
  mutate the copy, so nothing in the tree was ever broken.

Afterwards prove the restoration with `git diff --stat` against the counts you
recorded before mutating, not by eye.

Related: [[feedback_verify-claims-against-source-not-docs]]
