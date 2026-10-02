---
name: reference_github-webhook-no-redelivery
description: GitHub never auto-redelivers failed webhook deliveries — webhook-driven automation needs a scheduled sweep for correctness
metadata:
  type: reference
---

GitHub **does not automatically redeliver failed webhook deliveries**. A delivery
that answers non-2XX, or that fails to answer within 10 seconds, is recorded as
failed and dropped. Redelivery is manual only: the App's *Advanced* tab, or
`GET /app/hook/deliveries` + `POST /app/hook/deliveries/{delivery_id}/attempts`
(JWT auth).

Docs: https://docs.github.com/en/webhooks/using-webhooks/handling-failed-webhook-deliveries

**Why it matters:** a restart, deploy, or brief downtime loses events outright, so
a webhook handler alone cannot be the correctness boundary for anything with
durable consequences (cutting a tag, granting access, closing a loop). Treat the
webhook as *latency* and a scheduled reconcile as *correctness* — the shape
`kognic-github-app` uses (`sweep <subcommand>` kong leaf run by a Kubernetes
CronJob, converging on the same in-process policy code as the webhook handler).

Corollary for design review: any "GitHub will retry it" premise is false and
usually hides a lost-state bug — the second half of a two-phase flow (the event
that *finalises* something) is the dangerous one to drop.

Enumerating opt-in repos for such a sweep: one paginated
`GET /orgs/{org}/properties/values` with `repository_query=props.<name>:<value>`
(`props.` qualifiers only work scoped to a single org).

Related: [[reference_github-api]]
