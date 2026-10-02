---
name: macos-cfprefsd-symlinks
description: macOS plist files under ~/Library/Preferences/ cannot be symlinked — cfprefsd rewrites them atomically and breaks the link. Snapshot or use the app's "custom folder" feature instead.
metadata:
  type: reference
---

macOS plist files managed by `cfprefsd` (anything under
`~/Library/Preferences/com.*.plist`) cannot be symlinked into a dotfiles
repo for sync. The preference daemon rewrites the file atomically with a
new inode, which replaces the symlink with a regular file on the next
write.

**Workarounds:**

- **Snapshot only**: copy the plist into the repo periodically; manually
  copy back when restoring. Simple, but drifts silently.
- **App-level "custom folder" support**: some apps (iTerm2:
  *Preferences → General → Preferences → Load preferences from a custom
  folder*) read/write from a user-specified directory, bypassing the
  preferences sandbox. Best option when available.
- **defaults import / export**: `defaults export <domain> <path>` and
  `defaults import <domain> <path>` round-trip a plist as XML — scriptable
  for backups but doesn't give live sync.

Encountered while syncing `lindeskar/dotfiles` — iTerm2 plist had to stay
a snapshot while the four shell/git/ssh files became symlinks.
