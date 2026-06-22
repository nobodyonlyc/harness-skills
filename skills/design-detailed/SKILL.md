---
name: design-detailed
description: Phase 2 detailed design — component-level structure, key algorithms, and applicable design patterns before code is written.
---

Input: the architecture/database/api docs. Output: `docs/design/detailed.md` (or per-component).

## Produce
- **Module/class breakdown** per component: responsibilities and interfaces.
- **Key algorithms / state** that are non-obvious.
- **Design patterns** applied (and why) — keep them justified by the problem, not cargo-culted.
- **Failure handling** at the component level.

## Persona
- **Developer** — full detail; this is the dev-facing blueprint reviewed before `dev-*` implements.
- **Non-Technical** — skipped/auto; record only decisions that affect observable behavior.

## Gate
Step-gate; write to file. This blueprint feeds `plan-tasks` (F15), which splits it into child-tasks
and freezes the per-task test-strategy. Patterns reference `dev-design-patterns` where present.
