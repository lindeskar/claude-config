---
name: no-worktree-cleanup-offers
description: Don't repeatedly offer/ask about worktree (or branch) cleanup at the end of responses
metadata:
  type: feedback
---

Don't keep offering to clean up worktrees or branches at the end of responses. The user finds the repeated "want me to clean up the merged worktrees?" prompts annoying.

**Why:** worktree/branch cleanup is routine housekeeping the user manages themselves; surfacing it every turn is noise.

**How to apply:** just do the substantive work and stop. If a worktree/branch genuinely needs cleanup, do it silently when appropriate (e.g. `wt remove` after a confirmed merge per [[worktrees]] rules) or mention it once, briefly, in passing — never as a recurring closing question. Don't end responses asking about cleanup.
