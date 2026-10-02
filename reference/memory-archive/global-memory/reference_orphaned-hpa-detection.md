---
name: orphaned-hpa-detection
description: Find HPAs whose scaleTargetRef workload no longer exists by set-differencing scaleTargetRef against live Deployments/StatefulSets — `<unknown>` in the TARGETS column is an unreadable *metric*, not a missing target
metadata:
  type: reference
---

An HPA outlives the workload it scaled (app removed, Gateway deleted, ArgoCD app
deleted without pruning) and then emits `FailedGetScale … "<name>" not found`
forever. Two ways to find them, one of which is a trap:

**Don't use the `TARGETS` column.** `kubectl get hpa -A` showing `<unknown>/80%`
means the HPA can't read its *metric* — routine for an idle KEDA scaler or a pod
with no resource requests — and has nothing to do with whether the scale target
exists. Grepping for `unknown` produces a long list of healthy HPAs.

**Do an exact set difference.** Dump both sides in `ns/Kind/name` form and subtract
(include StatefulSets — `scaleTargetRef` isn't Deployment-only):

```
kubectl get hpa -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}{"\n"}{end}' > /tmp/claude/hpa.txt
kubectl get deploy,statefulset -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.kind}/{.metadata.name}{"\n"}{end}' > /tmp/claude/wl.txt
grep -Fxv -f /tmp/claude/wl.txt /tmp/claude/hpa.txt
```

Empty output is only meaningful after a **positive control** — pipe in one fake
`ns/Kind/does-not-exist` line and confirm it comes through, since a malformed
jsonpath on either side yields a silent clean bill of health. Corroborate with
`kubectl get events -A --field-selector reason=FailedGetScale`: the HPA controller
re-emits it every ~15s, so a live orphan always shows, and after a fix the event
*freezes* at its last timestamp instead of disappearing (event TTL ~1h) — a stale
`LAST SEEN` is the confirmation, not a failure.

**Before deleting, check who owns it** — the fix differs. No `ownerReferences` and no
live owner ⇒ a hand delete sticks. A `keda-hpa-` prefix ⇒ owned by a ScaledObject;
delete/fix that, not the HPA. An `argocd.argoproj.io/tracking-id` annotation is
**not** proof of a live owner: it survives its Application's deletion. Resolve it
first — its `<appNamespace>_<appName>:...` form points at an Application that may
live outside the `argocd` namespace (ArgoCD "apps in any namespace"), so check that
namespace before concluding the app is gone. If the Application does still exist,
the HPA is rendered from git and a manual delete just gets re-synced.
