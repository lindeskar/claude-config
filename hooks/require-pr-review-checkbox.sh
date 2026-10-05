#!/usr/bin/env bash
# PreToolUse(Bash): block `gh pr create` unless the body carries the unchecked human-review checkbox. Exit 2 feeds stderr back to Claude.
checkbox='- [ ] I, a human, have reviewed these changes'
cmd=$(jq -r '.tool_input.command // empty')
[[ "$cmd" =~ gh[[:space:]]+pr[[:space:]]+create ]] || exit 0
[[ "$cmd" == *"$checkbox"* ]] && exit 0
if [[ "$cmd" =~ (--body-file|-F)[=[:space:]]+([^[:space:]]+) ]]; then
  file=${BASH_REMATCH[2]//[\"\']/}
  file=${file/#\~/$HOME}
  [[ -f "$file" ]] && grep -qF -- "$checkbox" "$file" && exit 0
fi
echo "PR bodies end with the unchecked line '$checkbox' (above the attribution line), for the user to tick once they have read the diff. Add it and re-run gh pr create." >&2
exit 2
