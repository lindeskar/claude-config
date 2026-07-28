# Durable Writing

Applies to everything read back later: these rules, memory entries, wiki pages, ADRs, CLAUDE.md files. Write the invariant, not the moment.

- **No point-in-time observations.** No commit counts, branch-divergence numbers, current versions of moving targets, "verified <date>", or "as of now" snapshots. They silently rot into false statements. State the mechanism or the durable fact instead.
- **No session anecdotes.** "(this session: …)", "(I once …)", "(burned N cycles …)" — give the instruction, not the incident that produced it. If the story has lasting diagnostic value, put it in `reference/<topic>.md` (not auto-loaded) and link it.
- **No enumerated inventories.** Lists of which repos/services currently have X go stale invisibly. Name the specific known case, then say how to determine the rest.
- **Point at the authority, don't teach inference.** Say where the answer is documented — the repo's own instructions, the vendor's docs, the tool's `--help` — rather than a heuristic for guessing it from indirect signals.
- **Keep it short.** A rule earns its place by changing behaviour. Length and history cost attention on every future load.
