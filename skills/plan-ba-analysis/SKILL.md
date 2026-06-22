---
name: plan-ba-analysis
description: Phase 1 business analysis — elicit goals, users, and scope and produce a PRD-style requirements doc, with depth branched by user_role. Use when: starting a new project, scoping a new capability, turning a vague prompt into requirements, a BA/PRD pass before design.
---

Subject: $ARGUMENTS

## One-Liner
Turn a vague ask into a written PRD with **testable acceptance criteria** — the criteria become the
later test-strategy, so vagueness here becomes weak tests downstream.

## Core Philosophy
Skipping BA doesn't save time; it moves the ambiguity into code where it is expensive. Persona sets
**how much you ask** ([../../resources/persona-mode.md](../../resources/persona-mode.md)), never
whether you write the PRD.

## Workflow
### Phase 1 — Elicit (persona-branched)
- **Non-Technical** — plain-language, **batched** click-select questions: who uses it, what must it
  do, must-haves, out-of-scope. Pick sensible technical defaults and **log** them; don't ask stack/schema.
- **Developer** — **exhaustive**: actors/roles, acceptance criteria per capability, edge cases, data
  ownership, NFRs (perf/security/availability), integrations, constraints.
**Gate:** you can state the problem + primary users + must-haves in one paragraph.
### Phase 2 — Write the PRD (output contract below)
Write to `docs/requirements.md` (not chat — [../../resources/token-budget.md](../../resources/token-budget.md)).
**Gate:** every capability has at least one **testable** acceptance criterion.
### Phase 3 — Confirm
Step-gate: present a plain-language summary; approve/revise before `plan-us-backlog`.
**Gate:** user approved (or `auto` logged the decision).

## Output contract — `docs/requirements.md`
```markdown
# Requirements: <project>
## Problem & goal        — one paragraph
## Users / actors        — who, and what they need
## Capabilities
  - <capability> — acceptance: <testable bullet>, <testable bullet>   (dev: + edge cases, NFRs)
## Out of scope          — explicit exclusions
## Assumptions & defaults — incl. persona-logged technical defaults
## Open questions
```

## Handoff
Pass `docs/requirements.md` to [plan-us-backlog](../plan-us-backlog/SKILL.md). Acceptance criteria are
the seed for [check-test-strategy](../check-test-strategy/SKILL.md).

(PRD output-contract approach adapted from to-prd, theNeoAI, MIT.)
