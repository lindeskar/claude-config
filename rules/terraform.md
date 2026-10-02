---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tftest.hcl"
  - "**/.terraform.lock.hcl"
---

# Terraform / OpenTofu

- **`terraform` vs `tofu` — pick by repo, default `terraform`.** Only the volcano estate (`terraform-*-volcano`) runs `tofu`. Running the wrong CLI rewrites `.terraform.lock.hcl` into the other registry's namespace (`git checkout` it before committing) and can produce a lock CI rejects. When unsure: `grep -rE 'setup-opentofu|setup-terraform' .github/`.
- An applied `import` block left in config is a silent no-op (plan shows 0 changes) — it proves nothing about management; remove it as dead config.
- To drop a resource a pinned child module no longer has: a root-module `removed { from = module.X.type.name  lifecycle { destroy = false } }`, one block per instance (no `for_each`).
- Commands that launch a provider (`plan`, `apply`, `test`, `providers schema`) fail sandboxed with `Unrecognized remote plugin message`; `init`/`fmt`/`validate` work. Run the former sandbox-off.
- Never `tail`/`head` `validate`/`plan` output to check for errors — error blocks span ~10 lines and the *last* block is often the known-benign one. Enumerate all blocks: `… 2>&1 | grep -iE 'error|warning'` to count, `grep -A6 'Error:'` for context. Claim "clean" only after confirming every remaining error is environment-only and none reference your changed files.
- Regenerating `.terraform.lock.hcl` without backend access (use the repo's CLI — `terraform` for non-volcano, `tofu` for volcano): `<cli> init -backend=false` (add `-upgrade` when a pin changed, especially downgrades), then `<cli> providers lock -platform=linux_amd64 -platform=darwin_arm64 …`; verify the lock diff touches only the intended provider. Recipes: work wiki `reference_tofu-lockfile-regen` (volcano) and `reference_terraform-bootstrap-uses-hashicorp-terraform` (non-volcano).
- Generated files that CI verifies via "regenerate + `git diff --exit-code`" (terraform-docs READMEs, codegen output, lock files) must be produced by the generator, never hand-edited — phantom whole-file diffs are usually line endings (`make docs` runs via docker → CRLF; confirm with `file <path>`). If you can't run the generator, say so rather than guessing.
