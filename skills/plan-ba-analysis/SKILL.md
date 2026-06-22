---
name: plan-ba-analysis
description: Phase 1 business analysis — elicit goals, users, and scope from a prompt, with question depth and language branched by user_role (Non-Technical vs Developer).
---

Subject: $ARGUMENTS

Produce a requirements document. **Persona drives how you ask**
([../../resources/persona-mode.md](../../resources/persona-mode.md)).

## Elicit (persona-branched)
- **Non-Technical** — ask requirement-level questions in plain language, **batched** into a few
  click-select asks: who uses it, what must it do, what are the must-haves, what is out of scope.
  Propose sensible defaults for anything technical and **log** them; do not ask about stack/schema.
- **Developer** — be **exhaustive**: actors & roles, acceptance criteria per capability, edge cases,
  data ownership, non-functional requirements (performance, security, availability), integrations,
  constraints. Surface ambiguities as explicit questions.

## Output: `docs/requirements.md`
Write (do not dump to chat — [../../resources/token-budget.md](../../resources/token-budget.md)):
- Problem & goal (one paragraph)
- Users / actors
- Capabilities (each with acceptance criteria; dev runs add edge cases + NFRs)
- Out of scope
- Open questions / assumptions (with the persona-logged defaults)

## Gate
Step-gate before handing to `plan-us-backlog`: show a short summary + the file path and confirm
([../../resources/step-gate.md](../../resources/step-gate.md)). In `auto`, log the decision.

## Handoff
Pass `docs/requirements.md` to [plan-us-backlog](../plan-us-backlog/SKILL.md).
