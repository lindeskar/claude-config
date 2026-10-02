---
name: verify-claims-against-source-not-docs
description: Verify factual/impact claims about a system against its source (Dockerfile/config/code), not the repo's narrative docs — docs drift
metadata:
  type: feedback
---

When making a factual or impact claim about how a system works — especially as
the basis for a decision or an impact assessment — verify it against the source
of truth (the Dockerfile, config, code), **not** the repo's narrative docs
(`README.md`, `CLAUDE.md`). Those drift and lag the implementation.

**Why:** In one session I twice asserted the gitlab-ci-volcano runner image
"pre-mirrors providers" and that consumers had missed template-level changes —
both lifted from a stale `CLAUDE.md`. The actual Dockerfile only installs the
`tofu` binary (a prior PR had removed provider bundling), and the template logic
ships via the component version, not the image. The user corrected me twice; the
docs were simply out of date.

**How to apply:** before stating "X does Y" as fact, open the implementation file
and confirm. Treat `README`/`CLAUDE.md` as hints to where to look, not ground
truth. If a decision hinges on the claim, cite the file/line you verified it
against. When you do find drifted docs, fix them as part of the work.
