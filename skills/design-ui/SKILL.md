---
name: design-ui
description: Phase 3 UI design — produce a visual mockup per screen using the generate-image capability, falling back to static HTML/CSS when image generation is unavailable. Use when: mocking up screens before frontend code, visualizing a UI per the UX flow, defining screen states/components for dev-fe, or iterating a visual with the user.
---

## One-Liner
One approved mockup per screen — covering empty/loading/error/populated states — before any
frontend code; use generate-image, fall back to static HTML/CSS, never block on a missing tool.

Input: requirements + UX flows. Output: mockups under `docs/design/ui/` + notes.

## Output template (per screen, in docs/design/ui/)
```markdown
## Screen: <name>
Mockup: <image file | static HTML/CSS file>
States: empty | loading | error | populated
Components: <component> (props/behavior)
Responsive: <breakpoint rules>
Status: [ ] awaiting approval / [x] approved
```

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
