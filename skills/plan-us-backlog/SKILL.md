---
name: plan-us-backlog
description: Phase 1 backlog generation — turn a requirements doc into prioritized User Stories with acceptance criteria and seed the harness backlog. Use when: turning requirements into a prioritized US backlog, writing User Stories with acceptance criteria, seeding the harness backlog, or after plan-ba-analysis produces requirements.
---

## One-Liner
Convert requirements into **vertical** User Stories with testable acceptance criteria and seed them
into the harness backlog — making the backlog, not chat, the source of truth for what to build.

Input: `docs/requirements.md` (from [plan-ba-analysis](../plan-ba-analysis/SKILL.md)).

## Produce User Stories
For each capability, write a User Story:
- **As a** &lt;actor&gt; **I want** &lt;capability&gt; **so that** &lt;value&gt;.
- **Acceptance criteria** — testable bullets (the basis for the later test-strategy).
- **Priority** (1=must, 2=should, 3=could) and **area**.

Keep stories **vertical** (a thin end-to-end slice), not layer-by-layer.

## Seed the harness backlog
For each US, add it so the backlog is the source of truth:
```bash
./harness add <id> "<title>" --priority <n> --area <area> --behavior "<observable behavior>"
```
Defer `--verifications` to `plan-tasks` (F15), which freezes the **test-strategy** at plan time
(verifications are immutable after start).

## Persona
- **Non-Technical** — present the backlog as a plain-language feature list and ask approve/revise
  (click-select); hide IDs unless asked.
- **Developer** — present full stories with acceptance criteria and priorities for review.

## Gate
Step-gate: approve / revise the backlog before any execution
([../../resources/step-gate.md](../../resources/step-gate.md)). On revise, edit and re-present.

## Handoff
Approved backlog → `workflow-bootstrap` per-US execution (or `workflow-feature` for a single US).
