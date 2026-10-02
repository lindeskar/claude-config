---
name: investigate-skill-for-staging
description: Use the kognic-devops:investigate skill for staging investigations too, not just production — it has critical LogQL guidance
type: feedback
---

Use `kognic-devops:investigate` skill even when investigating staging alerts — the LogQL indexed vs extracted label guidance prevents wasted queries (e.g., `{pod="..."}` returns nothing, must use `| pod = "..."`).

**Why:** Wasted several query cycles during a staging investigation by putting `pod` in the stream selector instead of using a pipeline filter. The investigate skill documents this exact pattern but wasn't loaded because the issue was in staging.

**How to apply:** Any time you're querying Grafana Loki — staging or prod — load the investigate skill first for the query pattern reference. The skill's datasource table only covers prod, but staging equivalents follow the naming pattern: `mimir-staging`, `loki-staging`, `mimir-staging-volcano`, `loki-staging-volcano`.
