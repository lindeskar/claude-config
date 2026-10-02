---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
  - "**/.golangci.y*ml"
---

# Go

- `golangci-lint` can report a false clean when its cache write is blocked. Tells: `persist facts`/`pkgcache` `operation not permitted` warnings, or a nonzero exit alongside `0 issues.`. `GOLANGCI_LINT_CACHE` is preset in settings; if the warning still appears, re-run sandbox-off.
- Tests using `t.TempDir()` fail sandboxed with `TempDir: mkdir /tmp/…: operation not permitted`, and a `TMPDIR=` prefix doesn't help. That's the sandbox, not the change: re-run just those packages sandbox-off.
- The compiler and `go build`/`go vet` are authoritative; gopls diagnostics are a hint and can be stale after module changes.
