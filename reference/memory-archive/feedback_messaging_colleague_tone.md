---
name: Slack drafts — colleague-to-colleague tone, not consultant-to-client
description: User rewrites Claude drafts to sound like a casual Slack reply between colleagues — softer openers, situational "I"/"we", rhetorical questions, personal context, fewer packed qualifiers
type: feedback
---

Even when Claude's drafts follow the brevity / voice / casing rules, they still read as "structured reply from a professional" rather than "Slack message from a colleague". The user rewrites them to be looser and more human.

**Why:** Observed 2026-04-24 on a Cloudflare help request from finance. Claude's draft ("Yes — we can take a look at this _next week_. A couple of things we want to check first: …") landed as competent but formal. User's send ("Sure I think we can help. … The hard part, as always, is probably … And maybe the list can be managed as a Google Group? I will ping the team to check on this next week. Personally I'm off next week. :sunny:") sounded like a teammate, not a ticketing system.

**How to apply:**

- **Soften the opener.** "Sure I think we can help" > "Yes — we can take a look at this next week." Single-word openers ("Sure", "Yeah", "Happy to") + hedged verb ("I think", "probably") land as easy warmth. Avoid "Yes — we can …" which reads transactional.
- **"I" vs "we" is situational, not blanket.** Use "I" for personal action/ownership ("I will ping the team", "I'm off"). Use "we" for team capability or shared action ("we can help", "we would configure everything as code"). Don't globally replace one with the other — mix them the way a person would.
- **Conversational asides beat structured enumerations.** "The hard part, as always, is probably X" > "A couple of things we want to check first: (1) … (2) …". Name the hard part directly instead of listing concerns.
- **Rhetorical questions beat declarative explanation.** "And maybe the list can be managed as a Google Group?" > "whether we can back the allowlist with a Google Group so you manage investors in Google Admin rather than a CF dashboard." Shorter, more collaborative, invites a response.
- **Cut parenthetical qualifiers that restate the ask.** The recipient wrote the ask — don't re-specify their requirements in parens (e.g. drop "(self-serve allowlist + per-view audit)").
- **Personal context warms up timing.** "Personally I'm off next week. :sunny:" explains the deferred timeline humanely. A bare "we'll come back with what's feasible" is colder.
- **Don't mechanically mirror the recipient's emoji.** If they opened with `:pray:`, don't feel obligated to close with `:pray:`. Emoji reflects the sender's voice/context, not the recipient's.
- **Italic `_next week_` and `:claude:` prefix are optional.** User drops both when finalizing casual replies. Keep them in drafts (the global rules still stand) but don't lean on italic for every time qualifier — plain text often reads better.
- **"Should be simple enough", "probably", "as always"** — these filler phrases aren't padding in Slack; they're tone markers that signal colleague-to-colleague. Claude tends to strip them in the name of concision; user puts them back.
