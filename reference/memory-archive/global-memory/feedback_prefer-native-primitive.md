---
name: prefer-native-primitive
description: Before hardening/debugging hand-rolled extraction of a platform-provided value, check whether the platform exposes it as a first-class primitive
metadata:
  type: feedback
---

When hand-rolled logic extracts a value the platform already provides (a GitHub Actions context, cloud instance metadata, a CLI's own field), check for the native primitive *before* investing in hardening/parsing the hand-rolled version — otherwise you entrench the fragile approach.

On 2026-07-09, asked to harden a `gha-k8s-gitops` step that fetched the GitHub OIDC token via `curl`, base64url-decoded the JWT, and `jq`-parsed the `job_workflow_ref` claim, I improved *that* pipeline (retry, base64url→base64 fix, fail-closed). A reviewer then pointed out GitHub exposes the exact value as the first-class `${{ job.workflow_ref }}` context — no curl/jq at all, and more robust (no dependency on the flaky OIDC token endpoint). The hardening was scrapped for the native context.

**Why:** hand-rolled extraction re-implements — usually more fragilely — something the platform guarantees; hardening it locks in the wrong layer and carries the fragility forward.

**How to apply:** before improving parsing/derivation of a platform value, grep that platform's context/env/metadata docs for a first-class field. GitHub Actions specifics worth remembering: `job.workflow_ref` = the *reusable* workflow's own `owner/repo/path@ref` (available in step `env`/`run`); `github.workflow_ref` = the *caller's* entry workflow (wrong one for a reusable workflow). See also [[scope-before-machinery]].

**Corollary — when the primitive already solves it, say so plainly; don't wrap it in a brainstorm.** Same trap when the user proposes *building* machinery (a new Helm chart knob, a script, a wrapper) to reach a goal an existing config field already reaches. On 2026-07-21, asked for a "clever chart change (optional prefix/suffix)" to stop two ArgoCD apps colliding on one `ExternalSecret`, the fix was simply setting a distinct existing `target:` in the consumer's values — no chart change. I identified that but buried it inside an A/B/C option tree and kept running the brainstorming skill, so the user pushed back twice ("why are you asking? feels like i'm missing something"). Lesson: if the goal is already achievable with an existing primitive, lead with that one plain sentence and skip the design exploration — a solved question isn't a design question. Don't invoke brainstorming for it.
