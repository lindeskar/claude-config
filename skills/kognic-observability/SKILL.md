---
name: kognic-observability
description: >-
  Query Kognic's Grafana, Loki, Mimir and Prometheus correctly, including datasource UIDs per
  environment and the silent-zero traps that make a broken query look like a clean result. Use when
  an alert fires or is pasted, when writing or debugging PromQL or LogQL, when using any Grafana MCP
  tool (query_prometheus, query_loki_logs, dashboards, alert rules), when building or editing a
  dashboard panel or alert, or when asked "is X happening", "was this firing yesterday", "how often
  does Y log", in staging or prod, EU or China.
---

# Kognic observability

Use the Grafana MCP tools for dashboards, logs, metrics and alerts. The Grafana web UI is JS-rendered, so curl or WebFetch return nothing useful.

For alerts, crash loops or performance issues, in staging as well as prod, start with `kognic-devops:investigate`.

## Datasources

| Environment | Metrics | Logs |
| --- | --- | --- |
| o11y (central stack's own tenant) | `mimir-o11y` | `loki-o11y` |
| Staging EU | `mimir-staging` | `loki-staging` |
| Prod EU (Grafana default) | `mimir-prod` | `loki-prod` |
| Staging / prod China | `mimir-{staging,prod}-volcano` | `loki-{staging,prod}-volcano` |
| Other China tenants | `mimir-{demo,common,common-comp}-volcano` | `loki-…` same suffixes |

`list_datasources` enumerates everything. Use the o11y pair to monitor the observability stack itself. For example, Loki rejections such as `structured metadata too large` show up under `{namespace="loki"}` on `loki-o11y`, with the tenant `org_id` in the log line rather than in a label. Example `cluster` label values: `staging-eu-west1-green`, `vke-staging-green`.

## Silent-zero traps

Each of these returns an empty or partial result with no error. That looks like a finding, but the query is broken.

- **Structured metadata isn't a stream label, and `|=` doesn't match it.** Only a few fields are stream labels: `app`, `cluster`, `deployment`, `namespace`, `job`, `service_*`, `team`. `container`, `pod`, `node`, `level`, `container_image_tag` and any app-emitted context are structured metadata. Putting one of them in the selector (`{namespace="x", pod="y"}`) scans 0 lines, and `|= "<value only in metadata>"` also finds nothing. Filter with `| pod="y"` after the selector. Before writing the real query, sample 1-3 raw lines with a bare selector to see which fields exist and where they live.
- **Time windows must be absolute RFC3339.** Run `date -u` first and build the window from its output. A window ahead of the cluster clock, often local time written as UTC, returns 0 results, which reads as "the errors cleared". When a query comes back empty, check the window against `date -u` before concluding the signal is gone.
- **Chaining related metrics with `or` silently drops all but the first.** `or` matching ignores `__name__`, so siblings that share a label set disappear. That covers kube-state-metrics `kube_horizontalpodautoscaler_spec_max_replicas`/`_status_current_replicas` on one object. It also covers `sum by (pod) (A) or sum by (pod) (B)`. Select siblings with `{__name__=~"a|b", …}`, or run separate queries.
- **A range `count_over_time(…[W])` with step W stamps each window at its end.** The point at T covers (T−W, T]. A run later than `endTime − W` falls out of the result entirely and looks like it never happened. To count per run, make an instant query at `run_start + W`.
- **In `line_format` the raw line is `__line__`, not `.line`.** An unknown field renders empty rather than erroring, so lines come back blank while their labels look fine.
- **Counting an echoed string in a CI job log double-counts**, because the runner prints both the command and its output. Use `|= "<msg>" != "$ echo"`, and check any derived count against a known total.

## Query construction

- **Read the app's dashboard panel queries before writing PromQL.** Get the uid from `search_dashboards`, then call `get_dashboard_panel_queries`. That gives you custom metric names you wouldn't guess and the team's chosen aggregation. If a panel deliberately excludes a label value, that value usually marks a known-bad or noisy signal, which is worth noting.
- **Before a query goes into a dashboard or alert, validate it** with `query_prometheus`/`query_loki_logs`, substituting concrete values for `${var}`. That catches regex escaping, `label_replace` duplicate labelsets and rate-vs-counter mistakes.
- **Wrap `${var:regex}` (and `:pipe`) in backticks inside `=~`/`!~` matchers:** ``{host=~`${host:regex}(:[0-9]+)?`}``. The formatter emits `engine\.app\.kognic\.com`. In a double-quoted PromQL string `\.` is an invalid Go escape, and the parse fails with `unknown escape sequence U+002E '.'`. `:raw` is fine in double quotes.
- **`query_loki_logs` returns log lines by default, even for an aggregation.** A `topk` or `sum by (…) (count_over_time(…))` in default mode returns the underlying lines and blows the token cap. Pass `queryType: "range"` with `stepSeconds`, or `queryType: "instant"`, to get one series per labelset. That's the cheap way to answer "was this already firing yesterday, and at what rate?". Use `query_loki_stats` for volume.
- **When reading raw lines, `| keep` only the fields you need.** The MCP prints every stream label and metadata field on every entry, so a read hits the token cap far below its `limit`. Use `keep`, not `line_format`, because `line_format` doesn't drop labels.
- For apps that log huge structured-JSON DEBUG lines, the work wiki `reference_loki-noisy-json-queries` has the query patterns.
- **Memory at the limit doesn't show the pod needs more.** `container_memory_working_set_bytes` includes page cache, and page cache grows to fill whatever limit the pod has. Size from `container_memory_rss` plus I/O. A cache-bound job whose limit is too small shows `container_fs_reads_bytes_total` exploding while CPU falls and runtime climbs. It doesn't get OOMKilled.
