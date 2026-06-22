---
name: design-architecture
description: Phase 2 system architecture — define components, boundaries, data flow, and the technology stack; surface trade-offs to developers, pick logged defaults for non-technical users.
---

Input: `docs/requirements.md`. Output: `docs/design/architecture.md`.

## Decide
- **Components** and their responsibilities; the boundaries between them.
- **Data flow** between components (a simple diagram or bullet flow).
- **Stack** — language(s), framework(s), datastore, runtime; justify against the requirements/NFRs.
- **Cross-cutting** — auth, logging, error handling, config.

## Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md))
- **Developer** — present 1–2 viable options with trade-offs (cost, complexity, fit) and get approval.
- **Non-Technical** — choose a conventional default stack, state it in plain language, and **log**
  the rationale in the doc; do not ask the user to choose a framework.

## Gate
Step-gate before handing to `design-database` / `design-api`
([../../resources/step-gate.md](../../resources/step-gate.md)). Write the doc to a file; pass the
path forward (token-budget). The chosen stack also informs `../../resources/conventions/`.
