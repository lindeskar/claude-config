---
name: Slack drafts — preserve voice when translating or broadening
description: When translating Swedish drafts or widening audience from 1:1 to team, Claude strips social framing and personal stakes that the user wants kept
type: feedback
---

When adapting a user's existing message (translation, audience change), Claude's drafts consistently over-polish: removing social openers, cutting personal stakes, and flattening epistemic humility into confident assertion.

**Why:** Observed on 2026-04-17 when rewriting a Swedish Slack draft for a wider team audience. User's sent version preserved an apology opener (`Sorry if I caused bad vibes at standup today! :big-frog:`), added "I don't know" / "just a feeling" humility, grounded the cloud/devops analogy in personal experience ("I was on both sides of that"), and used `_soon_` / `_today!_` italics for tentative time framing. Claude's draft cut all of these. The user's voice is more vulnerable and less prescriptive than the clean draft style.

**How to apply:**
- If the original has a social opener (apology, acknowledgment of tension), keep it when broadening the audience — odds are the new audience overlaps with the original context
- Strip 1:1 political specifics (named internal people being difficult, back-channel conversations) when widening to a team — but keep the emotional framing
- Don't name-drop specific teams in proposals ("PlatEng should X"); use inclusive framing ("how we enable X")
- Broaden evidence beyond one requester — look for "X is not the only one" framing
- Preserve epistemic humility for opinion messages — "I don't know", "nothing here is clear", "just a feeling" are load-bearing, not padding
- Ground arguments in personal stakes where the original has them — "I was on both sides of that" > abstract analogy
- Use italic `_word_` for tentative emphasis on scope/time qualifiers
- Emoji opener (`:big-frog:`) and closer (`:slightly_smiling_face:`) are part of voice in opinion/pitch messages, not "sparingly"-decoration
