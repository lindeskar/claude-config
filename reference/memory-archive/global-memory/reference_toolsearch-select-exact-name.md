---
name: toolsearch-select-exact-name
description: ToolSearch select: needs the exact/fully-qualified deferred tool name; bare or guessed names return nothing
metadata:
  type: reference
---

`ToolSearch` with `select:<name>[,<name>...]` matches deferred tools by their **exact** registered name, which for MCP tools is the fully-qualified form `mcp__<server>__<tool>` (e.g. `mcp__claude_ai_Vanta__listTests`, not `listTests`). Passing a bare or guessed short name returns "No matching deferred tools found" — silently, so it looks like the tool doesn't exist.

**How to load MCP tools reliably:** use a keyword query first (e.g. `Vanta list tests vulnerabilities`) to surface the fully-qualified names, then `select:` those exact names for any siblings you still need. Don't burn calls guessing `select:shortName`.
