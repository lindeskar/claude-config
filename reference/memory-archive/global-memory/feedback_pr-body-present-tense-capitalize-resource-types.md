---
name: feedback_pr-body-present-tense-capitalize-resource-types
description: PR descriptions in present tense (describe what happens now, not past); capitalize Kubernetes/CRD resource types
metadata:
  type: feedback
---

In PR descriptions, describe what the change does **now / in the present**, not what happened in the past. "both render", not "both rendered"; "the app sits OutOfSync", not "sat". The diff is the current state of the world — narrate it in present tense.

Also **capitalize Kubernetes (and CRD) resource type names**: `Namespace`, `Secret`, `ExternalSecret`, `Application`, `Deployment`, etc. — even when used as a plain noun ("share the `customer-exports` Namespace", "two ArgoCD Applications").

**Why:** the user corrected a kognic-cd PR body twice on exactly these two points (past-tense "both rendered" → "both render"; lowercase "namespace" → "Namespace").

**How to apply:** when writing any PR/issue body, sweep for past-tense verbs describing the change's mechanics and flip them to present; capitalize resource-type nouns. Applies alongside the existing PR-body brevity rules in `git.md`. Related: [[feedback_no_explanatory_code_comments]].
