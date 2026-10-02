#!/usr/bin/env bash
# PostToolUse(Bash): after a `git commit`, warn Claude if HEAD carries no signature header.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[[ "$cmd" =~ (^|[\;\&\|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$) ]] || exit 0

cwd=$(jq -r '.cwd // empty' <<<"$input")
dir="$cwd"
if [[ "$cmd" =~ git[[:space:]]+-C[[:space:]]+([^[:space:]]+) ]]; then
  dir="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:]\&\;]+) ]]; then
  dir="${BASH_REMATCH[1]}"
fi
dir="${dir/#\~/$HOME}"
[[ "$dir" = /* ]] || dir="$cwd/$dir"
[[ -d "$dir" ]] || exit 0

if ! git -C "$dir" cat-file -p HEAD 2>/dev/null | grep -q '^gpgsig'; then
  jq -n --arg d "$dir" '{hookSpecificOutput: {hookEventName: "PostToolUse",
    additionalContext: ("HEAD in " + $d + " has no gpgsig header: the commit is unsigned. For history-bound branches retry once in the foreground, otherwise ask the user to run the commit.")}}'
fi
exit 0
