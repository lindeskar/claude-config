---
name: kubernetes-debug
description: >-
  Inspect and debug Kubernetes, ArgoCD and Helm state on Kognic clusters (GKE and China/volcano
  VKE), including clusters absent from kubeconfig. Use when running kubectl, reading pod,
  deployment, HPA or event state, a pod is slow to start or stuck in ContainerCreating, selecting
  pods by label, checking ArgoCD sync or health, rendering or comparing Helm charts, reading config
  out of a distroless image, or when someone says a China cluster is unreachable. Covers the
  kubecolor JSON trap, Kognic pod labels, orphaned HPAs, fsGroup chown stalls, SSA/webhook
  interplay, and ArgoCD inspection without the argocd CLI.
---

# Kubernetes / kubectl

- **`kubectl` is aliased to `kubecolor`**, which injects ANSI codes even into `-o json`/`-o yaml`, so piping to `jq` fails with `Invalid control character`. Prefix `NO_COLOR=1`. Don't call `/opt/homebrew/bin/kubectl` by path: it matches neither the sandbox exclusion nor the ask rules for mutating verbs.
- GKE auth runs outside the sandbox. If kubectl ever dies in `gke-gcloud-auth-plugin` with `getting credentials`, kubectl has slipped back into the sandbox; re-run it sandbox-off.
- **Kognic pod labels are `app`, `team`, `language`, `helm.sh/chart=kognic-deployment`.** The kognic-deployment chart doesn't set the `app.kubernetes.io/*` labels, so `-l app.kubernetes.io/name=…` returns zero results on every cluster. Use `-l app=<name>` or `-l team=<team>`, and `.metadata.labels.app` in jsonpath.
- Helm: read chart values with `helm show values`.

## China / volcano clusters

Run `kubectl config get-contexts | grep -i vke` before assuming no access; some VKE clusters (e.g. `common`) are contexts, and this overrides `kognic-devplat:china-debug`. Use its commit-a-script route, or metrics (see ArgoCD below), only for clusters not in that list.

## Workload triage

- **Pod stalls for minutes on every restart with `VolumePermissionChangeInProgress` events** (`Setting volume ownership … is taking longer than expected`): `securityContext.fsGroup` with the default `fsGroupChangePolicy: Always` makes kubelet recursively chown every file on the volume. Add `fsGroupChangePolicy: OnRootMismatch` next to `fsGroup`. Kubelet then checks only the volume root and skips the walk once ownership matches. With a Helm chart, confirm it renders `podSecurityContext` whole via `toYaml` so the new field reaches the pod.
- **Orphaned HPAs** (target workload gone, `FailedGetScale … not found` forever). Ignore the `TARGETS` column: `<unknown>` there means the *metric* can't be read, which is routine for idle KEDA scalers and pods without requests. Take an exact set difference instead:
  ```
  kubectl get hpa -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}{"\n"}{end}' > /tmp/claude/hpa.txt
  kubectl get deploy,statefulset -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.kind}/{.metadata.name}{"\n"}{end}' > /tmp/claude/wl.txt
  grep -Fxv -f /tmp/claude/wl.txt /tmp/claude/hpa.txt
  ```
  Add a fake `ns/Kind/does-not-exist` line to prove it comes through, because a broken jsonpath also yields empty output. Corroborate with `kubectl get events -A --field-selector reason=FailedGetScale`. A live orphan re-emits about every 15s. After a fix the event's `LAST SEEN` freezes, and that is your confirmation. Before deleting, find the owner. A `keda-hpa-` prefix means a ScaledObject owns it, so fix that object. An `argocd.argoproj.io/tracking-id` annotation can outlive its Application, so resolve the `<appNamespace>_<appName>` part, which may be outside `argocd`, before concluding it's orphaned. If the app still exists, a manual delete just gets re-synced.

## Server-side apply, webhooks and controllers

- **A controller's SSA re-apply is invisible while a mutating webhook rewrites it back.** If Kyverno or another mutator rewrites a field on every admission, the stored object never differs, so `resourceVersion`, `generation` and the manager's `managedFields` time all stay frozen. The next apply after the mutation stops persists, so breakage shows up seconds after the *mutator* changes, not when the config changed.
- **`managedFields` `time` bumps only when that manager's owned field set changes.** An old timestamp means ownership hasn't changed. It doesn't mean nothing has applied since.
- **To find when a mutation stopped, read the mutator's log, not the object.** Kyverno logs `mutation rules from policy applied successfully` with `name=`, `operation=` and `username=` for each request. The gap between its last line and the first unmutated write pins the change to within seconds.

## Rendering a gitops wrapper chart locally

Rendering an `infra/<app>/<env>` wrapper chart is the cheapest way to prove a values change does what you think, and to prove your check discriminates.

- **`helm dependency update` aborts on a stale shared repo cache even when every dependency is OCI.** The error is `open …/helm/repository/<repo>-index.yaml: no such file or directory`, naming a repo the chart never uses. Point `HELM_REPOSITORY_CONFIG` at a file containing `repositories: null`. OCI refs don't read that file.
- **Check the render both ways.** Assert that what should be gone is gone, then re-render with the old value (`--set`) and confirm it comes back. A broken render is also empty, so the negative alone proves nothing.
- Re-read `Chart.yaml` after refreshing the clone, because a Renovate bump may have moved the dependency version. Clean up `charts/` and `Chart.lock` afterwards. They're gitignored, so `git status` won't show them.

## Reading and testing config inside images

- **Read a file from a distroless image** with `crane export <image@digest> - | tar -xO <path>`. Distroless has no shell, so `kubectl exec … cat` fails.
- **Test a candidate config by baking it into the image, not by bind-mounting it.** On Docker Desktop, mounting a single file fails with `not a directory`. Write a two-line Dockerfile that `COPY`s the config over the real one, `docker build -q`, then `docker run --rm --entrypoint <tool> <img> -t` as the image's default non-root user. Diff the output against the stock image to see which warnings your config causes.

## ArgoCD

- There's no argocd CLI. Read the Application CR instead: `kubectl -n argocd get application <app> -o json`, then `.status.resources[]` for per-resource sync status. The field-level diff needs the argocd API, so reproduce it with `helm template` of the source chart and diff that against live.
- **Many apps `Unknown` at once: read `.status.conditions[*].message` first.** `serverSideDiff error … dryrun … is forbidden` means an admission webhook is rejecting Argo's dry-run, so real writes are being rejected too. Measure the impact with `kubectl get events -A --field-selector reason=FailedCreate`. CronJobs that can't create Jobs are usually the first casualty. Which apps show `Unknown` changes with each refresh, so a clean-looking cluster can still be broken.
- **Cluster not in kubeconfig at all?** Query `argocd_app_info{name="<app>"}` in that environment's mimir datasource (see `kognic-observability`). Its `sync_status`, `health_status` and `cluster` labels show Synced/Healthy without cluster access. Application `.status.conditions` aren't exported as metrics, so reading those needs a reachable cluster.
