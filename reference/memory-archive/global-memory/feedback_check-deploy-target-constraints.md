---
name: check-deploy-target-constraints
description: Before building/shipping an image or sidecar into an existing pod/cluster, inventory the runtime constraints (node arch, occupied ports, base-image layout) up front
metadata:
  type: feedback
---

When building a container image or adding a sidecar to an **existing pod/cluster**, inventory the runtime's constraints *before* building — don't discover them via prod crash-loops.

**Why:** in the renovate nginx-sidecar work, three separate prod crash-loops (each costing a fix→release→redeploy cycle and renovate downtime) were all discoverable up front from `values.yaml` / `Chart.yaml` / the base image:
- **Node arch** — pod ran on `c4a` (Axion/**arm64**) nodes; an amd64-only image → `exec format error`. (`Chart.yaml` even flagged ARM scheduling.) Build multi-arch.
- **Occupied ports** — native sidecars share the pod **network namespace**; the main container already bound `:8080` (`values.yaml`), so a second listener on 8080 → `EADDRINUSE`. Check existing `ports:`/server config and pick a free port.
- **Base-image config layout** — the base image (Chainguard nginx) shipped its own default server in `conf.d/nginx.default.conf`; overriding a *differently-named* file just added a second server. Inspect the base image's config files before assuming what your COPY replaces.

**How to apply:** before `docker build`/adding a sidecar, check (1) target **node arch** → build `linux/amd64,linux/arm64` when unsure; (2) **ports already in use** in the pod (shared netns) → grep the values/manifests; (3) the **base image's filesystem/config conventions** (user/UID, listen port, config include paths, read-only-fs writable dirs) → extract and read them. See [[worktrees]] only tangentially; the renovate specifics live in the work wiki `renovate-config` page.
