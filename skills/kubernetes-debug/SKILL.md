---
name: kubernetes-debug
description: >-
  Inspect Kubernetes, ArgoCD and Helm state on Kognic clusters, including clusters absent from
  kubeconfig. Use when running kubectl, reading pod or deployment state, checking ArgoCD sync or
  health, rendering or comparing Helm charts, or debugging GKE auth failures. Covers the kubecolor
  JSON-parsing trap, GKE sandbox auth, ArgoCD inspection without the argocd CLI, and checking
  China/volcano clusters via metrics.
---

# Kubernetes / kubectl

- **`kubectl` is aliased to `kubecolor`**, which injects ANSI colour codes even into `-o json`/`-o yaml` — piping to `python`/`jq` fails with `Invalid control character`/`JSONDecodeError`. For machine-readable output prefix `NO_COLOR=1` (`NO_COLOR=1 kubectl … -o json` pipes cleanly), or call the real binary at `/opt/homebrew/bin/kubectl`.
- **GKE contexts fail under the sandbox when the token needs refreshing**: `gke-gcloud-auth-plugin` can't write its cache under `~/.config/gcloud` (sandbox-denied), so kubectl dies with `getting credentials: exec: … gke-gcloud-auth-plugin failed`. Early calls may work off a cached token, then break mid-session. Run kubectl against GKE with the sandbox **off**; read-only gets and describes are safe that way.
- Helm: read chart values with `helm show values`.

## Reading and testing config inside images

- **To read a file out of a distroless image**, use `crane export <image@digest> - | tar -xO <path>` — distroless has no shell or coreutils, so `kubectl exec … cat` fails with `executable file not found`.
- **To test a candidate config against that image, bake it in — don't bind-mount.** Mounting a single file (`docker run -v /abs/file:/etc/x/file`) errors on Docker Desktop/macOS with `not a directory: Are you trying to mount a directory onto a file`. Instead write a 2-line Dockerfile that `COPY`s the config over the real one, `docker build -q`, then `docker run --rm --entrypoint <tool> <img> -t`. Run it **as the image's default (non-root) user** so the check reflects runtime, and diff against the stock image to prove which warnings are yours. This turns "will this config work in the cluster?" into a local yes/no in two calls.

## ArgoCD

- No argocd CLI is installed — inspect state via the Application CR directly: `kubectl -n argocd get application <app> -o json` → `.status.resources[]` for per-resource sync status. The field-level diff needs the argocd API (admin creds, blocked by the auto-mode classifier); reproduce it locally instead by rendering the source chart with `helm template` and diffing against live. Case study: work wiki `argocd-crd-list-defaults-outofsync`.
- **When a cluster isn't in your kubeconfig at all (common for China `vke-prod`), check ArgoCD app health via metrics instead of kubectl.** `argocd_app_info{name="<app>"}` in that environment's mimir datasource (Grafana `query_prometheus`) carries `sync_status`, `health_status`, and `cluster` labels, so you can confirm Synced/Healthy without cluster access. China env → datasource: `mimir-{staging,demo,prod,common-comp}-volcano` plus `mimir-common-volcano`. ArgoCD Application `.status.conditions` (RepeatedResourceWarning and friends) are *not* exported as metrics — those need the CR, and therefore a reachable cluster.
