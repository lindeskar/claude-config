---
name: go-yaml-successor
description: gopkg.in/yaml.v3 is archived; go.yaml.in/yaml is the successor, and sigs.k8s.io/yaml is a wrapper on it rather than an alternative
metadata:
  type: reference
---

`gopkg.in/yaml.v3` (github.com/go-yaml/yaml) is archived and its README declares the project unmaintained. The successor is **github.com/yaml/go-yaml**, maintained by the YAML organization, imported as `go.yaml.in/yaml/v3` (drop-in: same API, same `yaml:` tags) or `go.yaml.in/yaml/v4`. Upstream freezes v1–v3 as legacy on security fixes only and directs new work to v4, so check whether v4 has left release-candidate before choosing it.

`sigs.k8s.io/yaml` is **not** an alternative maintainership — it is a YAML→JSON wrapper that itself depends on `go.yaml.in/yaml` and uses `json:` struct tags. Only pick it when the types already carry `json:` tags.

Migrate by rewriting the import plus the `go.mod` requirement. A `replace` directive fails once anything in the graph still requires the old path (`used for two different module paths`). A golangci-lint `depguard` rule denying the old path keeps it from returning.

Renovate cannot do this migration: the module path changes, and dependency updates don't rewrite Go import statements.
