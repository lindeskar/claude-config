# Skill & Agent Routing

> Case studies behind these rules: `reference/skill-routing.md` (not auto-loaded).

## My own skills — knowledge that used to be always-loaded

These live in `~/.claude/skills/`. They were moved out of `rules/` to save context, so **the knowledge is no longer in front of you by default — invoke the skill when its topic comes up**, don't reconstruct it.

- **`kognic-observability`** — PromQL/LogQL, Grafana MCP tools, Loki structured-metadata vs stream labels, silent-zero query traps. Any metrics/logs/dashboard/alert work.
- **`kubernetes-debug`** — kubectl/kubecolor, GKE sandbox auth, ArgoCD without the CLI, checking clusters absent from kubeconfig, reading and testing config inside distroless images.
- **`github-api`** — `gh` CLI and REST/GraphQL traps: null `--jq` reads, rate limits, empty job logs, CI-run polling, Projects verification, reading source at an exact tag.
- **`drafting-messages`** — voice and tone for any Slack/email message written on the user's behalf.
- **`company-issues`** — creating issues in `annotell`/`kognic-internal`, the PlatEng project auto-add, issue structure.
- **`personal-issues`** — the `lindeskar/work` todo list, sub-issues, cross-linking rules.

Path-scoped rules load automatically when you open a matching file: `rules/python.md`, `rules/terraform.md`.

## Choosing between overlapping installed skills

- **Review someone else's PR** → `anthropic-review-pr:review-pr`. **Review my own working diff** → built-in `/code-review`. **Quality/simplification pass** → built-in `/simplify`.
  - The `anthropic-review-pr` reviewer subagents have **no Bash/`gh`** — on a private repo they can't fetch the diff and silently fall back to whatever tree they can Read, usually stale `master`, not the PR head. **Best default when the repo is cloned locally: materialize PR head into a worktree and give every subagent that absolute path.** If you must paste, give every agent the **same complete context** — a *partial* paste makes an agent report the omitted pieces as real gaps. Verify every finding against the code before relaying, and re-check the PR head OID on any re-invocation.
- **Worktrees** → the `wt` workflow in `worktrees.md` (details: `worktrunk:worktrunk`). Ignore `superpowers:using-git-worktrees`; built-in `EnterWorktree`/`claude --worktree` only where `worktrees.md` says so.
- **Alerts, incidents, crash loops, perf** → `kognic-devops:investigate` first; `kognic-devplat:*` reference skills as follow-up context.
- **Feature-work process** → the superpowers flow (brainstorming → writing-plans → executing) with the output overrides in `superpowers.md`.
- **Commit/PR mechanics** → `git.md` wins over `kognic-git:*` and `superpowers:finishing-a-development-branch` where they conflict; `kognic-git:conventional-commits` is the semver-mapping reference.
- **Deep multi-source research** → `deep-research`; quick lookups → WebSearch/WebFetch directly. Prefer both over `kognic-devplat:gemini-researcher`.
- **Wiki reads/writes** → `kognic-claude-wiki:knowledge-wiki` plus the registry and routing rules in the global CLAUDE.md.
- **Kognic domain questions** (who owns X, platform concepts, business context) → `kognic-company-info:*` before searching Notion/Slack.
