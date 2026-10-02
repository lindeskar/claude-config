---
name: grafana-datasources
description: Grafana datasource UIDs for all environments (o11y, EU and CN/Volcano, staging and prod)
type: reference
---

| Environment       | Metrics                  | Logs                   |
| ----------------- | ------------------------ | ---------------------- |
| Observability o11y| `mimir-o11y`             | `loki-o11y`            |
| Staging EU        | `mimir-staging`          | `loki-staging`         |
| Staging Volcano   | `mimir-staging-volcano`  | `loki-staging-volcano` |
| Production EU     | `mimir-prod`             | `loki-prod`            |
| Production Volcano| `mimir-prod-volcano`     | `loki-prod-volcano`    |

`mimir-prod` is the Grafana default datasource. The **o11y** pair is the central
observability cluster's own tenant — use it to self-monitor the platform stack
(e.g. Loki distributor `structured metadata too large` rejections live in
`{namespace="loki"}` on `loki-o11y`; org_id is in the log line, not a label).
Extra CN tenants also exist (`{mimir,loki}-common-volcano`, `-common-comp-volcano`,
`-demo-volcano`); run `list_datasources` to enumerate all.

Cluster names in metrics:
- EU staging: `staging-eu-west1-green`
- CN staging: `vke-staging-green`
