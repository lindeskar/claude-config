---
name: kognic-pod-labels
description: Kognic workloads (kognic-deployment Helm chart) use simple labels — `app`, `team`, `language`, `helm.sh/chart` — NOT the `app.kubernetes.io/*` set. Use these for kubectl label selectors.
metadata:
  type: reference
---

The kognic-deployment Helm chart labels pods/deployments with:

- `app=<application-name>` — primary selector (e.g. `app=reports-api`)
- `team=<team-name>` — owning team (e.g. `team=orchestrate`)
- `language=<lang>` — language (e.g. `language=scala`, `language=python`)
- `helm.sh/chart=kognic-deployment`
- `pod-template-hash=<hash>` — added by the ReplicaSet

The standard `app.kubernetes.io/name`, `app.kubernetes.io/component`, `app.kubernetes.io/managed-by` labels are NOT set. Selectors like `-l app.kubernetes.io/component=service` return zero results.

**How to apply:**

- `kubectl get pods -n <ns> -l app=<name>` — list pods for one app
- `kubectl get pods -A -l team=<team>` — list all pods owned by a team
- When filtering pods via jsonpath, use `.metadata.labels.app` (not `.metadata.labels.app\.kubernetes\.io/name`)
- Same chart deploys across all Kognic clusters (gke-prod-blue, gke-staging-blue, demo-cn, etc.), so this applies cluster-wide
