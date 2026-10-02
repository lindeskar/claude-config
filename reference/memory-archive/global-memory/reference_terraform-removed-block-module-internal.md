---
name: reference_terraform-removed-block-module-internal
description: Root-module `removed` blocks CAN target a resource inside a child module (module.X.resource.name) — use when a pinned/remote module drops a resource and you want state to forget it, not destroy it
metadata:
  type: reference
---

When a remote/pinned Terraform module bumps to a version that **deletes a resource**, a plain version bump makes Terraform plan to **destroy** that resource on the real infra. To make state forget it without destroying, add a `removed` block — and it can live in the **root module** targeting the module-internal address, even though you can't edit the pinned child module:

```hcl
removed {
  from = module.<instance>.<resource_type>.<name>
  lifecycle {
    destroy = false   # forget from state, no API destroy
  }
}
```

Verified concretely (TF 1.15 / required_version `~> 1.11`) that `terraform validate` accepts a root-module `removed` block with a `module.X.resource.name` `from` address — the HashiCorp guidance to "declare the removed block in the child module" is not a hard requirement; you don't control a pinned remote module, and the root works.

Caveats:
- `removed` blocks have **no for_each** — one static block per (module instance × resource). N module instances of the same module = N×(resources dropped) blocks. Put them in a dedicated `removed.tf`.
- An address not in state is a safe no-op.
- Needs TF ≥ 1.7 for the `lifecycle { destroy = false }` form.

First used on `terraform-common-volcano#516` (terraform-modules-github v4 dropped the `protect-default-branch` / `require-pr-review` custom-property resources across 16 repo module instances). See [[feedback_commit-type-dependency-pointer-bump]] for how to type the commit.
