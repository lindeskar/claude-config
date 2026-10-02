---
name: fsgroup-recursive-chown-slow-startup
description: Pods with fsGroup + a large/many-file persistent volume stall for minutes on startup (VolumePermissionChangeInProgress) — kubelet recursively chowns every file; fix with fsGroupChangePolicy OnRootMismatch
metadata:
  type: reference
---

A pod that sets `securityContext.fsGroup` makes kubelet take ownership of every mounted volume on start. The default `fsGroupChangePolicy: Always` does this as a **recursive `chown` of every file**, so a volume with hundreds of thousands of files stalls pod startup for **minutes on every restart**.

**Diagnostic signature:** pod stuck in init/`ContainerCreating`, events show `VolumePermissionChangeInProgress` (`Setting volume ownership for … is taking longer than expected … processed N files`). The event itself names the fix.

**Fix:** add `fsGroupChangePolicy: OnRootMismatch` alongside `fsGroup` in the pod-level `securityContext`. Kubelet then only checks the volume's top-level dir; if its owner already matches `fsGroup` (true on every restart after the first chown), it skips the recursive walk entirely. Subsequent starts are fast; only a volume whose root doesn't match pays the one-time recursive cost.

Applies to any pod with `fsGroup` + a big/many-file volume (caches, repo clones, node_modules). Helm-chart caveat: confirm the chart renders the whole `podSecurityContext` map via `toYaml` (most do) so the extra field passes through — not all charts cherry-pick keys.

First hit: renovate-ce shards in `annotell/k8s-platform-gitops` (`infra/renovate/values.yaml`) — 34Gi persistent cache PVC with ~430k files, fixed in PR #2784. See [[kognic-pod-labels]] context for that deployment; the renovate-specific rationale is inline in the values.yaml.
