# Tooling

- Python: always use `uv run` to run scripts (e.g. `uv run main.py`)
- Helm: read chart values with `helm show values`
- Use built-in tools for all file operations — never fall back to shell equivalents:
  - **Read** not `cat`, `head`, `tail`, `sed -n` — use `offset`/`limit` params to read specific line ranges
  - **Glob** not `find`, `ls`
  - **Grep** not `grep`, `rg`, `awk`
  - **Edit** not `sed`, `awk`
  - **Write** not `echo >`, `cat <<EOF`
- Never chain `cd` with other commands using `&&` or `;` — run `cd` as a standalone Bash call to set the persistent working directory, then run subsequent commands separately
- Never use command substitution (`$(...)` or backticks) in Bash tool calls — these require explicit permission every time. Instead, capture the output in a prior step and use it directly, or use built-in tools (Glob, Grep, Read) to achieve the same result.
- Use LSP diagnostics and go-to-definition to understand and troubleshoot code — don't guess at types, imports, or call sites by grepping
- When investigating errors: check LSP/compiler output first, then read the relevant source — don't shotgun-grep the codebase
- Grafana: always use the Grafana MCP server tools for querying dashboards, logs, metrics, alerts, and incidents — never curl or WebFetch the Grafana web UI
