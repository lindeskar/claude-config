---
name: grafana-promql-regex-interpolation
description: Use PromQL backticks (raw strings) around `${var:regex}` Grafana template interpolation — double quotes choke on `\.` escapes
metadata:
  type: feedback
---

When interpolating a Grafana template variable as a regex into a PromQL label
matcher, use **backticks** (raw strings) around the matcher value, not double
quotes:

```promql
# Correct
{host=~`${host:regex}(:[0-9]+)?`}

# Wrong — Prometheus rejects with: parse error: unknown escape sequence U+002E '.'
{host=~"${host:regex}(:[0-9]+)?"}
```

**Why:** Grafana's `${var:regex}` formatter emits regex-escaped values
(`engine\.app\.kognic\.com`). PromQL double-quoted strings follow Go-string
escape rules — `\.` is not a valid Go escape, so Prometheus rejects the query
at parse time. PromQL backtick-delimited strings are raw (no escape
interpretation), so `\.` survives unchanged to the regex engine.

**How to apply:** any time a Grafana dashboard injects a multi-value variable
into a `=~` or `!~` matcher, wrap the matcher value in backticks. Same applies
to other formatters that produce escaped output (`:raw` is fine in double
quotes since it doesn't escape; `:regex` and `:pipe` need backticks if any
value contains a regex metachar).
