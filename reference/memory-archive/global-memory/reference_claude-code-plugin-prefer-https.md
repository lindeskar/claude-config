---
name: reference_claude-code-plugin-prefer-https
description: CLAUDE_CODE_PLUGIN_PREFER_HTTPS makes Claude Code clone/update plugin marketplaces over HTTPS instead of the default SSH
metadata:
  type: reference
---

Claude Code clones and updates plugin **marketplaces** (git repos under
`~/.claude/plugins/marketplaces/`) over **SSH by default** (`git@github.com:owner/repo.git`),
which on this machine routes through the 1Password SSH agent and prompts an unlock
on every auto-update. Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` (accepted truthy
values: `1`, `true`, `yes`, `on`) to make it use HTTPS (`https://github.com/owner/repo.git`)
instead — auth then goes through the `gh`/osxkeychain token, no SSH key / 1Password unlock.
The broader `CLAUDE_CODE_REMOTE` flag flips the same switch.

Publicly **undocumented** — tracked in anthropics/claude-code#60419. Verified by
reverse-engineering the CLI binary (v2.1.201): the URL is derived by a ternary
`preferHTTPS ? https : ssh`, and the only `git remote set-url` calls are guarded by
that same check. So with the var **unset**, an update just does `git pull` on the
existing clone and never rewrites the remote — a manual `git remote set-url` to HTTPS
sticks across updates, but a re-add / re-clone reverts to SSH. With the var **set**,
CC clones AND repoints to HTTPS on update (survives re-add).

Set in `~/.zprofile` (`~/Code/_private/dotfiles/.zprofile`). Documented for the team
in the [kognic-internal/claude-plugins README](https://github.com/kognic-internal/claude-plugins/blob/master/README.md).
