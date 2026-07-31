# Durable Writing

Applies to everything read back later: these rules, memory entries, wiki pages, ADRs, CLAUDE.md files — and equally to **code comments and PR/issue bodies**, which are read long after the measurements that motivated them are stale. Write the invariant, not the moment.

The tell in a diff or PR body: concrete percentages, dates, hostnames/IPs, and "measured X today" evidence. That belongs in the tracking issue (a work log), not in the artifact. A code comment earns its place only by explaining something the code cannot say itself — why this aggregation, why this guard. Rationale for a *threshold* or a *design choice* goes in the thing the reader already sees (an alert's own description, the commit message), not in a comment block above it.

- **No point-in-time observations.** No commit counts, branch-divergence numbers, current versions of moving targets, "verified <date>", or "as of now" snapshots. They silently rot into false statements. State the mechanism or the durable fact instead.
- **No session anecdotes.** "(this session: …)", "(I once …)", "(burned N cycles …)" — give the instruction, not the incident that produced it. If the story has lasting diagnostic value, put it in `reference/<topic>.md` (not auto-loaded) and link it.
- **No enumerated inventories.** Lists of which repos/services currently have X go stale invisibly. Name the specific known case, then say how to determine the rest.
- **Point at the authority, don't teach inference.** Say where the answer is documented — the repo's own instructions, the vendor's docs, the tool's `--help` — rather than a heuristic for guessing it from indirect signals.
- **Keep it short.** A rule earns its place by changing behaviour. Length and history cost attention on every future load.
