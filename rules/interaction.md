# Interaction

- **Never use the `AskUserQuestion` tool to ask me questions.** It abandons the question after ~60s if I don't answer immediately — a hardcoded timeout with no setting to disable it (confirmed against the Claude Code docs). Coming back to find my question was dropped and I proceeded on an assumption is worse than waiting.
- **Ask clarifying questions as plain text at the end of a normal turn, then stop.** A plain-text question has no timeout and waits for my reply indefinitely. When offering choices, write them as a short numbered/bulleted list in prose and ask me to pick — don't invoke the structured question picker.
- This applies in plan mode too: surface open questions as plain text before finalizing a plan rather than via the question tool.
- **Exception — genuinely blocking, must-decide-now choices only:** the `AskUserQuestion` tool is acceptable when the harness *requires* a structured answer to continue and there's no plain-text path. Default to plain text; reach for the tool only when there's no alternative.
