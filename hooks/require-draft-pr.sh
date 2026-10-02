#!/usr/bin/env bash
# PreToolUse(Bash): block `gh pr create` unless it asks for a draft. Exit 2 feeds stderr back to Claude.
cmd=$(jq -r '.tool_input.command // empty')
[[ "$cmd" =~ gh[[:space:]]+pr[[:space:]]+create ]] || exit 0
if [[ "$cmd" =~ --draft=false ]] || ! [[ "$cmd" =~ (^|[[:space:]])(--draft(=true)?|-d)([[:space:]]|$) ]]; then
  echo "PRs are opened as drafts: re-run gh pr create with --draft. Un-drafting is the user's call." >&2
  exit 2
fi
exit 0
