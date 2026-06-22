---
name: design-ux-flow
description: Phase 3 UX flow — map screen-to-screen navigation, user journeys, and per-state transitions before UI mockups are finalized.
---

Input: requirements + US backlog. Output: `docs/design/ui/flows.md`.

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
