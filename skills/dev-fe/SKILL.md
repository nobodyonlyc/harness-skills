---
name: dev-fe
description: Phase 5 frontend implementation — build the UI for a child-task from the approved mockups and UX flows, following component and language conventions. Use when: building UI for a child-task, implementing screens/components from approved mockups, wiring a frontend to the API contract, or the Phase 5 frontend slice.
---

## One-Liner
Build the approved mockup faithfully — **all** states (empty/loading/error/populated), small
components, no business logic in views — wired to the real API contract.

Input: the child-task `plan.md`, approved mockups (`docs/design/ui/`), and `flows.md`.

## Implement
- Build the screens/components per the **approved mockup** and **UX flow**; cover all states
  (empty/loading/error/populated).
- Follow the framework guide in [../../resources/conventions/](../../resources/conventions/)
  (e.g. typescript-react).
- Keep components small; lift state per the detailed design; no business logic in views.
- Accessibility + responsive rules from the UI design.

## Examples (Bad vs Good)
```jsx
// BAD: only the happy state; business logic + fetch inside the view
function List() {
  const [d, setD] = useState([])
  useEffect(() => { fetch('/api/items').then(r => r.json()).then(setD) }, [])
  return <ul>{d.map(i => <li>{i.name}</li>)}</ul>   // no loading/error/empty
}
// GOOD: states covered; data via a hook; view stays presentational
function List() {
  const { data, status } = useItems()              // loading/error handled in the hook
  if (status === 'loading') return <Spinner/>
  if (status === 'error')   return <ErrorState/>
  if (!data.length)         return <EmptyState/>
  return <ul>{data.map(i => <li key={i.id}>{i.name}</li>)}</ul>
}
```

## Self-check
- Renders all states; matches the mockup; wired to the real API contract.
- No console errors; basic keyboard/focus works.
**Gate:** all mockup states render, wired to the real contract, no console errors.

## Handoff
To `check-code-review` then the selected `test-*` (UT for components, **e2e** for the user flow if
the strategy requires it). User-facing flows are the e2e basis from `design-ux-flow`.
