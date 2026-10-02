---
name: suppress-by-role-not-symptom-shape
description: When suppressing a tool's unwanted change, key the rule on the role of the thing being changed, not on a pattern matching the symptom's shape
metadata:
  type: feedback
---

When a bot or tool proposes a change you want to stop, ask whether that change is wrong **everywhere** or only **here**. If the same behaviour would be *correct* in another context, scope the suppression by the **role** of the thing being changed — which repo shape, which component, published-artifact vs consumer, prod vs staging — not by a matcher that recognizes the malformed value.

**Why:** a symptom-shaped matcher (a regex on the offending version string, path, or value) encodes the upstream bug rather than your policy. It stops covering cases the moment the bug shifts shape, it can't be reviewed against intent, and it reads as a workaround. A role-scoped rule states the invariant, so the next reader checks it against the policy instead of reverse-engineering the defect. It is usually also *broader in the right direction and narrower in the wrong one*: it catches variants of the same mistake while leaving the contexts where the behaviour is desirable untouched.

**How to apply:** before writing the matcher, name the attribute that makes *here* different from the places the change is fine, and match on that. Tell that you got it backwards: your rule contains a pattern mirroring the exact bad value, or you find yourself explaining the matcher by describing the bug. If the change really is wrong everywhere, it's an upstream defect — report it there and suppress broadly meanwhile. Related: [[confirm-cause-before-remediating]] — correct root-causing does not imply the remedy belongs at the root cause's fingerprint.
