---
name: dev-fe
description: Phase 5 frontend implementation — build the UI for a child-task from the approved mockups and UX flows, following component and language conventions.
---

Input: the child-task `plan.md`, approved mockups (`docs/design/ui/`), and `flows.md`.

## Implement
- Build the screens/components per the **approved mockup** and **UX flow**; cover all states
  (empty/loading/error/populated).
- Follow the framework guide in [../../resources/conventions/](../../resources/conventions/)
  (e.g. typescript-react).
- Keep components small; lift state per the detailed design; no business logic in views.
- Accessibility + responsive rules from the UI design.

## Self-check
- Renders all states; matches the mockup; wired to the real API contract.
- No console errors; basic keyboard/focus works.

## Handoff
To `check-code-review` then the selected `test-*` (UT for components, **e2e** for the user flow if
the strategy requires it). User-facing flows are the e2e basis from `design-ux-flow`.
