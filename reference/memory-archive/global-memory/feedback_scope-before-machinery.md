---
name: scope-before-machinery
description: Before designing bespoke machinery for a category, count the real instances; for one/few, propose vendoring/inlining first
metadata:
  type: feedback
---

When a task is framed as "build a general system for <category>" (a mirror, a rewrite rule, a pipeline, a CLI), **count how many real instances of the category actually exist today** before designing the machinery — and explicitly surface the build-vs-vendor / build-vs-inline tradeoff during brainstorming.

On 2026-06-10 I designed and built a whole third-party-module mirror+rewrite system for China (ADR, plan, a python-hcl2 rewrite rule in gitlab-ci-volcano#180, a `push-external` mirror in terraform-modules-volcano#141, multiple review cycles, plus CRLF/tfdocs debugging) — then the user pointed out there is exactly **one** third-party module in use (`hashicorp/subnets/cidr`) and it was far simpler to vendor it as a first-party module (rides the pipeline that already exists). The whole system was scrapped. The single-instance clue was visible from the start (the original analysis issue named one module).

**Why:** a general system carries design, review, test, edge-case, and maintenance cost that isn't justified for one or a few instances. Vendoring/inlining is usually smaller and reuses existing pipelines.

**How to apply:** in brainstorming, when the design generalizes over a category, ask "how many instances exist now, realistically?" If one or a few, present "vendor/inline it" as the first option with the bespoke system as the alternative — don't just execute the requested machinery because it was asked for. The user can still choose the system, but the tradeoff should be explicit and early. See also [[verify-current-pr-state]].
