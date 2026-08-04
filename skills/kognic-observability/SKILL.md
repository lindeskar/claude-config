---
name: kognic-observability
description: >-
  Query Kognic's Grafana, Loki, Mimir and Prometheus correctly, and avoid the silent-zero traps
  that make a broken query look like a clean result. Use when writing or debugging PromQL or LogQL,
  querying logs or metrics, reading dashboards, investigating alerts or incidents, or whenever the
  Grafana MCP tools are in play. Covers structured-metadata vs stream labels, absolute time windows,
  aggregation query types, multi-metric selection, and reading panel queries before guessing metric names.
---

# Kognic observability

Always use the Grafana MCP server tools for dashboards, logs, metrics, alerts, and incidents — never curl or WebFetch the Grafana web UI.

For alerts, crash loops, or performance issues, invoke `kognic-devops:investigate` first — it carries the LogQL/PromQL patterns and datasource UIDs.

## Silent-zero traps

These all return an empty or partial result with no error, which reads as a finding when it is actually a broken query.

- **Structured metadata is not matched by `|=` line filters.** In Kognic's Loki only a few fields are stream labels (`app`, `cluster`, `deployment`, `namespace`, `job`, `service_*`, `team`). `container`, `pod`, `node`, `level`, `container_image_tag` and any app-emitted context (a bot's `repository`, `depName`, `branch`, `versions`) are structured metadata. Two consequences: putting one in the stream selector (`{namespace="x", container="y"}`) matches no stream and scans **0 lines**; and `|= "<value that lives only in metadata>"` returns nothing while the data sits right there. Filter with `| field="value"` *after* the selector, and sample one raw line (bare selector, `limit` 1-3) to see which fields exist and where before building the real query.
- **Time windows must be absolute RFC3339** — the Grafana MCP Loki/Prometheus tools reject `now-1h`. Get `date -u` **first** and build the window from it. A window ahead of the cluster's clock (usually a local-time-as-UTC slip) returns 0 results, which during an incident check reads as "errors cleared" when nothing was queried. When a range or instant query comes back empty, sanity-check the window against `date -u` before concluding the signal is gone.
- **Don't chain related metrics with `or`** — it silently returns only the first. `or` is a set operator whose matching ignores `__name__`, so sibling metrics sharing an identical label set (the norm for kube-state-metrics: `kube_horizontalpodautoscaler_spec_max_replicas` / `_spec_min_replicas` / `_status_current_replicas` / `_status_desired_replicas` on one object) are treated as already present on the left and dropped. Use a name regex instead: `{__name__=~"metric_a|metric_b", label="x"}`.
- **In `line_format`, the raw log line is `__line__`, not `.line`** — and an unknown field renders empty rather than erroring, so `| line_format "{{.line}}"` returns entries whose content is silently blank while labels still come back. Only use `line_format` to *project* labels; to read the line itself, omit it.

## Query construction

- Validate PromQL/LogQL via `query_prometheus`/`query_loki_logs` with concrete values substituted for `${var}` before it lands in a dashboard or alert — catches regex escaping, `label_replace` duplicate labelsets, and rate-vs-counter mismatches.
- **Read the app's dashboard panel queries before writing PromQL** — `search_dashboards` for the uid, then `get_dashboard_panel_queries`. Apps expose custom metrics you will not guess (queue depth, process start time, per-job wait quantiles), and the panels hand you exact names plus the team's chosen aggregation. A panel's own filters encode operational context: a label value deliberately excluded usually marks a known-bad or known-noisy signal, which is a finding in itself.
- **`query_loki_logs` defaults to returning log lines, not metric vectors.** A LogQL aggregation (`topk`, `sum by (…) (count_over_time(…))`) left in that default mode returns the underlying lines and blows the token cap. Pass `queryType: "range"` with `stepSeconds`, or `queryType: "instant"`, to get one compact series per labelset regardless of how many lines it scans server-side — the cheap way to ask "was this already firing yesterday, and at what rate?". Use `query_loki_stats` for volume.
- Apps that log huge structured-JSON DEBUG lines (token-cap blowouts, `|~` matching inside embedded blobs) need the patterns in the work wiki `reference_loki-noisy-json-queries`: `!=` pre-filters on tell-tale keys, structured-metadata equality over line substrings, distinctive event-marker anchors, minutes-tight windows.
