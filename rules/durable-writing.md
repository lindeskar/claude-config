# Durable Writing

**Check this at the moment you Write or Edit prose into anything read back later** — `rules/*.md`, `CLAUDE.md`, wiki pages, memory entries, ADRs, code comments, PR/issue bodies, alert descriptions — not only at session start. The reader is you in six months with none of today's context: write the invariant, not the moment.

## Rewrite, don't just delete

The insight is worth keeping; the incident that produced it is not. Restate it:

| Instead of | Write |
|---|---|
| "(this session: 12 `gh` calls failed …)" | the tell — "every iteration errors with the fields glued together" |
| "burned ~3 cycles on the wrong helm version" | the instruction — "reproduce with the version CI pins" |
| "helm 3.21.2 rejects nulls" | the range — "rejects present-but-null values in 3.21+" |
| "the repos using X are A, B, C" | how to find them — "`gh search code …`" |
| "verified <date>" / "as of now" | nothing, or the mechanism that keeps it true |
| "measured 40% faster" | why it's faster, or a link to the run |

Two that don't fit the table:

- **Point at the authority, don't teach inference.** Name where the answer is documented — the repo's own instructions, the vendor's docs, `--help` — rather than a heuristic for guessing it from indirect signals.
- **Keep it short.** A rule earns its place by changing behaviour. Length costs attention on every future load.

Where the story goes instead: `reference/<topic>.md` in `claude-config` (not auto-loaded) for tooling/git/worktree war stories, the work wiki for Kognic-specific ones, the tracking issue for work-log detail. Link it; never inline it.

## Self-check before saving

Grep the draft for `this session`, `I once`, `burned`, `today`, `currently`, `as of`, `verified` — and for bare version numbers, dates, percentages, hostnames, IPs, and PR numbers used as *evidence* rather than as a pointer. For each hit: **still true, and still worth the attention, in six months?** If not, apply a rewrite above.

## Why this rule keeps losing

It is a small fraction of always-loaded context and the sibling rules are the rest, so when *they* carry session anecdotes the demonstration beats the instruction. A violation left in `rules/` is not a stray — it is what teaches the next session to violate. When you spot one, fix it in place rather than writing alongside it.
