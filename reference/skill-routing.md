# Skill & Agent Routing

Case studies backing the routing defaults in `rules/skill-routing.md`. Not auto-loaded.

## A partial paste made a reviewer subagent invent a gap

The `anthropic-review-pr` reviewer subagents have no Bash/`gh` in their tool list, so on a private repo they cannot fetch the PR diff and silently fall back to whatever tree they can Read — usually stale `master`, not the PR head.

Working around that by pasting context, the tests were pasted to the test-coverage agent only. The code-quality agent — which received everything *except* the tests — reported a false "no tests visible" Warning, while the agents that happened to locate the real worktree on disk reasoned correctly off actual files.

The lesson is that an omission reads to a subagent as an absence in the code, not an absence in its own prompt. Either give every agent the identical complete context, or (better, when the repo is cloned locally) materialize PR head into a worktree and hand every agent that absolute path.

Verifying each finding against the real code before relaying it caught two false positives in that same review — which is the general rule, not a one-off.
