# Skill & Agent Routing

Several installed skills overlap. Use these defaults instead of deliberating per session:

- **Review someone else's PR** → `anthropic-review-pr:review-pr`. **Review my own working diff** → built-in `/code-review`. **Quality/simplification pass on changed code** → built-in `/simplify`.
- **Worktrees** → the `wt` workflow in `worktrees.md` (details on demand: `worktrunk:worktrunk` skill). Ignore `superpowers:using-git-worktrees`; built-in `EnterWorktree`/`claude --worktree` only where `worktrees.md` says so.
- **Alerts, incidents, crash loops, perf** → `kognic-devops:investigate` first; `kognic-devplat:*` reference skills (o11y-architecture, gitops-deployment, alert-channels, china-debug) as follow-up context.
- **Feature-work process** → the superpowers flow (brainstorming → writing-plans → executing) with the output overrides in `superpowers.md`.
- **Commit/PR mechanics** → `git.md` wins over `kognic-git:*` and `superpowers:finishing-a-development-branch` where they conflict; `kognic-git:conventional-commits` is the semver-mapping reference.
- **Deep multi-source research** → `deep-research` skill; quick factual lookups → WebSearch/WebFetch directly; prefer both over `kognic-devplat:gemini-researcher`.
- **Wiki reads/writes** → `kognic-claude-wiki:knowledge-wiki` + the registry and routing rules in the global CLAUDE.md.
- **Kognic domain questions** (who owns X, platform concepts, business context) → `kognic-company-info:*` before searching Notion/Slack.
