---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/uv.lock"
  - "**/requirements*.txt"
---

# Python / uv

- Python: always use `uv run` to run scripts (e.g. `uv run main.py`)
- `uv sync`/`uv run` rewrites `uv.lock` source registries to the locally-configured index (`pypi.org` → `pypi.kognic.io`). That's local-env noise, not a dependency change — `git checkout uv.lock` before committing unless you intentionally changed deps. Check `git diff uv.lock` after any `uv` invocation in a repo you'll commit to.
- `uv sync` failing with `failed to install: <pkg>.whl` / missing `METADATA` for a normal package = corrupted shared-cache entry. Fix: `uv cache clean <pkg>`, re-run — no full cache wipe needed.
- **Reproduce a CI job's bare/minimal Python env locally with `uv run --no-project --with '<exact pip deps>' --python <ver> python <script>`** — no project install, only the deps CI installs, on CI's interpreter. Decisive for "does this import resolve in the CI env?" bugs: a workflow that runs `python src/…` as a *bare script* has neither `src/` on `sys.path` (→ `ModuleNotFoundError: No module named '<toplevel>'`) nor the package installed, and even with `PYTHONPATH=src` importing a submodule still executes its package `__init__`, which may pull app-only deps absent in CI. Fix = `PYTHONPATH=src` on the step **and** keep the package `__init__` on that import path dependency-light (import heavy deps lazily). Worked example: work wiki `fleet-api-sbom-grype-pipeline`.
