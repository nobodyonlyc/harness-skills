---
name: design-ux-flow
description: Phase 3 UX flow — map screen-to-screen navigation, user journeys, and per-state transitions before UI mockups are finalized. Use when: mapping screen-to-screen navigation, defining user journeys per US, specifying per-screen state transitions, or identifying which flows need e2e coverage.
---

## One-Liner
Map the journeys and screen-to-screen transitions before any mockup — the flow defines what each
screen must show and which user-facing paths require e2e coverage.

Input: requirements + US backlog. Output: `docs/design/ui/flows.md`.

## Output template (docs/design/ui/flows.md)
```markdown
## Journey: <US / goal>
Screens: <A> → <B> → <C>
Transitions @<screen>: empty → loading → success | error  (trigger: <event>)
Entry/exit: <deep link / auth redirect / completion>
e2e candidate: yes/no
```

## Produce
- **User journeys** — the primary path through the app per key User Story.
- **Screen map** — which screens exist and how the user moves between them.
- **State transitions** per screen (empty → loading → success/error) and what triggers each.
- **Entry/exit points** — deep links, auth redirects, completion states.

## Persona
- **Non-Technical** — describe journeys as plain steps ("after they add an item, they see the list").
- **Developer** — formalize transitions; these become the basis for **e2e** tests in phase ⑦.

## Gate
Step-gate; write to file. The flows feed `design-ui` (what each screen must show) and inform which
user-facing flows require **e2e** coverage (`check-test-strategy`).
