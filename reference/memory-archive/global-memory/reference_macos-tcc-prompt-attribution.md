---
name: reference_macos-tcc-prompt-attribution
description: Attribute a macOS privacy/permission notification (TCC) to the exact process, service and target via the unified log; why native-installer Claude Code re-prompts after every update
metadata:
  type: reference
---

To find out what triggered a macOS "permission denied"/privacy notification, read the TCC log rather than guessing from the app name. Narrow to the minute of the notification:

`/usr/bin/log show --start '<ts>' --end '<ts+1m>' --style compact --predicate 'subsystem == "com.apple.TCC" OR process == "sandboxd"'`

- `AUTHREQ_ATTRIBUTION` names the responsible and accessing processes (pid + binary path).
- `sandboxd … checking <service> for "<bundle id>"` names the protected target (e.g. `kTCCServiceSystemPolicyAppDataDetailed` for `com.google.Chrome` = reads under `~/Library/Application Support/Google/Chrome/`).
- `identifier_type=Path` means the grant is keyed by binary path. Claude Code's native installer runs from `~/.local/share/claude/versions/<version>`, so every update is a new TCC client and any earlier decision is lost.
- `does not allow prompting for unentitled binaries; returning denied` means no dialog is possible — it auto-denies and posts a notification only.

Claude Code's Chrome-extension detection (listing Chrome profiles' `Extensions` dirs) is the known App Data trigger. `claudeInChromeDefaultEnabled: false` doesn't gate every caller; `CLAUDE_CODE_ENABLE_CFC=0` gates more but not all of them.
