---
name: core-explain
description: Explain code, architecture, or a change to the user at the right level of detail for their role (plain for non-technical, precise for developers).
---

Subject: $ARGUMENTS

## Do
- Explain **what it does, why, and how it fits** the rest of the system.
- Adjust depth/language to the persona
  ([../../resources/persona-mode.md](../../resources/persona-mode.md)):
  - **Non-Technical** — plain language, analogies, outcomes; avoid jargon.
  - **Developer** — precise: data flow, contracts, edge cases, trade-offs.
- Reference `file:line` so the user can jump to the source.

## Rules
- Read-only; explanation, not modification.
- Be honest about uncertainty — if behavior is unclear, say so and point at what to check.
- Keep it scoped to the question; long deep-dives go to a file, not the chat.
