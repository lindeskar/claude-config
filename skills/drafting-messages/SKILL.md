---
name: drafting-messages
description: >-
  The user's own voice for anything another person will read: Slack messages and replies, emails,
  announcements, vendor escalations, and GitHub issue/PR comments, review replies and status updates
  (PR titles and bodies: kognic-pr-conventions).
  Use when drafting, shortening, rewriting or translating such a message, replying in a thread, asking
  a colleague questions, posting an update on a tracking issue, or broadening a 1:1 draft to a team.
  Covers length, opener, tone, emoji, structure and what to keep from the user's own wording.
---

# Drafting messages

The user consistently cuts drafts to between a third and a half of their length before sending. Write the first draft at the length they would type themselves.

## Length and shape

- Slack messages and GitHub comments: three short sentences or fewer unless asked for more. When there are several points, suggest separate short messages. Opinion or pitch messages with real substance may run longer.
- Lead with the ask or the finding. Skip context the reader already has, preamble, greetings and sign-offs.
- Name the exact setting, value or change, not the principle or a best practice.
- Include only the ask the user stated: no bonus asks, impact sentences, or parentheticals restating the recipient's requirements.
- Proper capitalization. English unless Swedish is requested or the conversation is already in Swedish.
- Prefix Slack messages with `:claude:` so recipients know Claude drafted it.

## Tone

- Colleague to colleague and tentative. Invite discussion, don't prescribe: "my first thought is…", "I'd suggest…". A rhetorical question softens a proposal ("maybe this could be a Google Group?").
- A soft opener ("Sure", "Yeah", "Happy to" plus "I think" or "probably") reads warmer than "Yes, we can…".
- Keep conversational asides ("as always", "should be simple enough"); they are the voice.
- Name the hard part in prose ("the hard part, as always, is probably X") instead of listing concerns.
- "I" for personal action ("I'm off next week"), "we" for team capability.
- Opinion messages keep their uncertainty ("I don't know", "just a feeling").
- Emoji suit opinion, pitch and celebratory messages (`:slightly_smiling_face:`, `:sunny:`), more than "sparingly". None in neutral information-gathering; don't mirror the recipient's.

## By message type

**Questions to a colleague.** One question per line, with no numbering, bullets or blank lines, because a numbered list reads as a form. Ask for "input", not answers. Offer a guess they can correct ("feels like this may outgrow plain HTML?") rather than an open question or your own list of candidate answers. Keep warmth in the opener and leave out any closer that hints at a verdict. Quote the person's own words; if they reached you through someone else's summary, ask for the original wording.

**Vendor or account-team escalation.** "I"-led with a warm opener that names the vendor ("Hi ByteDance team!"). Name the partner or entity directly, since the vendor knows the relationship. Frame it as a concrete request ("We have a request from X to enable Y"). The escalation itself shows urgency, so don't add a sentence about it. "Thanks", not "Thank you".

**Status update on a tracking issue.** The exception to prose: a short framing line, then one heading per workstream with two or three bullets. Report the finding, not the evidence; link the primary source instead of summarising it. Name the real disagreement plainly by describing the discussion ("it sounds like the question is 'should we' rather than 'how'"), and don't soften it for the user. Propose forward dates rather than assume them.

**Broad announcement.** The wider the audience, the less mechanism. Keep the one thing readers must act on and drop internals (file names, tokens, downstream tools). Open with a short title; close with an invitation for feedback, not a how-to.

**Durable docs.** Reasoning about rejected alternatives ("not Y, because…") goes in a PR comment, not in the doc. Docs and config `description` fields say what the thing does and which invariants an editor could break. PR titles, bodies and comment mechanics: `kognic-pr-conventions`.

## Editing the user's draft

- Keep their wording, including social openers, apologies and personal stakes. Change only what they asked about.
- When broadening a 1:1 message to a team, drop the 1:1 politics (named people, back-channel context) but keep the emotional framing. Prefer an inclusive "we" to naming a team, and frame the evidence broadly ("X isn't the only one who's asked").
