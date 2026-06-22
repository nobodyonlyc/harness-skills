---
name: design-ui
description: Phase 3 UI design — produce a visual mockup per screen using the generate-image capability, falling back to static HTML/CSS when image generation is unavailable.
---

Input: requirements + UX flows. Output: mockups under `docs/design/ui/` + notes.

## Produce per screen
- A **mockup** using the **generate-image** capability
  ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)). If the runtime
  has no image tool, build a **static HTML/CSS mockup** instead — never block on a missing tool.
- **States** — empty, loading, error, populated.
- **Components** used and their key props/behavior.
- **Responsive** rules (breakpoints) where relevant.

## Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md))
- **Non-Technical** — show the mockup and ask "does this match what you want?" (click-select
  approve/revise). Iterate on the visual, not the markup.
- **Developer** — confirm component breakdown, states, and responsive behavior for `dev-fe`.

## Gate
Step-gate: approve / revise each screen before implementation
([../../resources/step-gate.md](../../resources/step-gate.md)). Hands the approved mockups + the
flow from `design-ux-flow` to `dev-fe` (F16).
