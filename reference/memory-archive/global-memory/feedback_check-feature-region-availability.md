---
name: check-feature-region-availability
description: When a cloud feature works in one region/cloud but not another, read the feature's own doc for a "supported regions" note before debugging config/IAM
metadata:
  type: feedback
---

When a managed-cloud feature works in one region/cloud but silently fails in another, check the
**feature's own documentation for a region/availability note first** — before hypothesizing about
config, IAM, or terraform differences.

**Why:** Debugging why TOS "Log Storage" didn't deliver in the compliance cloud (`cn-beijing-selfdrive`),
I spent effort on a "fresh terraform role vs console-imported role" hypothesis and a full demo A/B
reproduction. The actual answer was one line in the TOS logging doc: *"Log storage is only supported
in China (Beijing) and China (Shanghai)."* The feature isn't available in selfdrive at all. Reading
that section early would have short-circuited the whole investigation.

**How to apply:**
- Feature X works in region/cloud A but not B → open X's doc and look for "supported regions" /
  "availability" / "limitations" before debugging config or permissions.
- **Silent accept ≠ available:** an API accepting the config with no error (e.g. `PutBucketLogging`
  returns OK, `GetBucketLogging` echoes it) does NOT mean the feature works — verify the actual effect
  (delivery), not just that the config was stored.
- The console is a fast oracle: a feature tab present in one region's console but missing in another
  is strong evidence of a region/availability gap.

Relates to [[verify-claims-against-source-not-docs]] and [[check-deploy-target-constraints]].
