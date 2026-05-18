# Tooling

- Python: always use `uv run` to run scripts (e.g. `uv run main.py`)
- Helm: read chart values with `helm show values`
- Use built-in tools for all file operations — never fall back to shell equivalents:
  - **Read** not `cat`, `head`, `tail`, `sed -n` — use `offset`/`limit` params to read specific line ranges
  - **Glob** not `find`, `ls`
  - **Grep** not `grep`, `rg`, `awk`
  - **Edit** not `sed`, `awk`
  - **Write** not `echo >`, `cat <<EOF`
- Never chain Bash commands with `&&`, `||`, or `;` — run each command as a separate Bash tool call. This includes `cd`, `git`, multi-step inspection (`git status` + `git diff` + `git log`), and any other composite. Reasons: the user can only approve/deny the chain as a whole, intermediate failures are hard to attribute, and an unintended state after a partial run (e.g., a worktree created from stale master) is harder to recover from. Parallel independent calls in one message are fine; chaining in one shell command is not.
- Never use command substitution (`$(...)` or backticks) in Bash tool calls — these require explicit permission every time. Instead, capture the output in a prior step and use it directly, or use built-in tools (Glob, Grep, Read) to achieve the same result.
- Use LSP diagnostics and go-to-definition to understand and troubleshoot code — don't guess at types, imports, or call sites by grepping
- When investigating errors: check LSP/compiler output first, then read the relevant source — don't shotgun-grep the codebase
- Grafana: always use the Grafana MCP server tools for querying dashboards, logs, metrics, alerts, and incidents — never curl or WebFetch the Grafana web UI
- When investigating alerts, crash loops, or performance issues: invoke `kognic-devops:investigate` first — it has LogQL/PromQL patterns and datasource UIDs that prevent wasted queries
