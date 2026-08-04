---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tftest.hcl"
  - "**/.terraform.lock.hcl"
---

# Terraform / OpenTofu

> The `terraform` vs `tofu` split is also stated in `tooling.md`, which loads unconditionally — this rule only reaches you once you open a terraform file.

- **`terraform` (HashiCorp) vs `tofu` (OpenTofu) — pick by repo; default `terraform`.** Only the **volcano estate** (`terraform-*-volcano`, incl. `terraform-common-volcano`) runs `tofu`/OpenTofu today. **Every other Kognic terraform repo** — `terraform-identity`, `terraform-bootstrap`, the `terraform-*` domain repos — runs HashiCorp **`terraform`** (e.g. `required_version = "~> 1.11"` is Terraform, not OpenTofu). Running `tofu` in a terraform repo mostly works for `validate`/`init` but rewrites `.terraform.lock.hcl` from the `registry.terraform.io` namespace to `registry.opentofu.org` (local-env noise — `git checkout` it before committing) and can produce a lock CI rejects. If unsure which a repo uses: `grep -rE 'setup-opentofu|setup-terraform' .github/`. Full estate split + lock recipe: work wiki `reference_terraform-bootstrap-uses-hashicorp-terraform`.
- Never `tail`/`head` `validate`/`plan` output to check for errors — error blocks span ~10 lines and the *last* block is often the known-benign one. Enumerate all blocks: `… 2>&1 | grep -iE 'error|warning'` to count, `grep -A6 'Error:'` for context. Claim "clean" only after confirming every remaining error is environment-only and none reference your changed files.
- Regenerating `.terraform.lock.hcl` without backend access (use the repo's CLI — `terraform` for non-volcano, `tofu` for volcano): `<cli> init -backend=false` (add `-upgrade` when a pin changed, especially downgrades), then `<cli> providers lock -platform=linux_amd64 -platform=darwin_arm64 …`; verify the lock diff touches only the intended provider. Recipes: work wiki `reference_tofu-lockfile-regen` (volcano) and `reference_terraform-bootstrap-uses-hashicorp-terraform` (non-volcano).
- Generated files that CI verifies via "regenerate + `git diff --exit-code`" (terraform-docs READMEs, codegen output, lock files) must be produced by the generator, never hand-edited — phantom whole-file diffs are usually line endings (`make docs` runs via docker → CRLF; confirm with `file <path>`). If you can't run the generator, say so rather than guessing.
