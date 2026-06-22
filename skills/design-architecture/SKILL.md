---
name: design-architecture
description: Phase 2 system architecture — define components, boundaries, data flow, and stack, recording the choice as an ADR with a trade-off matrix. Use when: designing a new system, choosing a stack/framework, defining component boundaries, recording an architecture decision.
---

Input: `docs/requirements.md`. Output: `docs/design/architecture.md`.

**Delegate craft depth to the expert.** For component/boundary design, scalability patterns, and ADR
authoring, load the vendored [`architecture-designer`](../architecture-designer/SKILL.md) (also feeds
[design-detailed](../design-detailed/SKILL.md)); see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md). This skill keeps the
trade-off-matrix + ADR gate.

## One-Liner
Pick the architecture by comparing options against the requirements in a trade-off matrix, then
record the decision as an ADR — so the *why* survives, not just the *what*.

## Core Philosophy
An unrecorded architecture decision gets re-litigated every time someone new reads the code. Compare
real options against the actual NFRs; don't default to the trendiest stack. Persona sets how much is
surfaced ([../../resources/persona-mode.md](../../resources/persona-mode.md)).

## Workflow
### Phase 1 — Components & flow
Define components + responsibilities, the boundaries between them, and the data flow.
**Gate:** every requirement maps to a component that owns it.
### Phase 2 — Choose the stack (trade-off matrix)
List 1–2 viable options; score against the requirements/NFRs.
**Gate (Developer):** user approved the choice. **Non-Technical:** a conventional default is chosen
and logged (not asked).
### Phase 3 — Record the ADR
Write the decision + rationale + rejected alternatives to `docs/design/architecture.md`.
**Gate:** the ADR names what was chosen, why, and what was rejected.

## Output contract
```markdown
## Trade-off matrix
| Option | Fit to NFRs | Complexity | Cost | Team familiarity | Verdict |
|---|---|---|---|---|---|
| A: <stack> | … | … | … | … | chosen |
| B: <stack> | … | … | … | … | rejected: <reason> |

## ADR-001: <decision title>
- Status: accepted
- Context: <forces from requirements/NFRs>
- Decision: <what we chose>
- Consequences: <trade-offs accepted, follow-ups>
- Rejected: <option B> because <reason>
```

## Handoff
Feeds `design-database` / `design-api` / `design-detailed`; the chosen stack selects the
`../../resources/conventions/<lang>.md` guide.
