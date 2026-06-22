---
name: design-detailed
description: Phase 2 detailed design — component-level structure, key algorithms, and applicable design patterns before code is written. Use when: producing the dev-facing blueprint before code, breaking a component into modules/classes, specifying a non-obvious algorithm, or justifying a design pattern.
---

## One-Liner
The dev-facing blueprint: module/class breakdown, the non-obvious algorithms and failure handling,
and any pattern justified by the problem it solves — enough that `dev-*` writes code, not guesses.

Input: the architecture/database/api docs. Output: `docs/design/detailed.md` (or per-component).

## Output template (docs/design/detailed.md)
```markdown
## <Component>
- Modules/classes: <name> — responsibility, interface
- Key algorithm/state: <non-obvious logic>
- Pattern: <pattern> — justified by <problem>
- Failure handling: <what fails, how it degrades>
```

## Produce
- **Module/class breakdown** per component: responsibilities and interfaces.
- **Key algorithms / state** that are non-obvious.
- **Design patterns** applied (and why) — keep them justified by the problem, not cargo-culted.
- **Failure handling** at the component level.

## Persona
- **Developer** — full detail; this is the dev-facing blueprint reviewed before `dev-*` implements.
- **Non-Technical** — skipped/auto; record only decisions that affect observable behavior.

## Gate
Step-gate; write to file. This blueprint feeds [plan-tasks](../plan-tasks/SKILL.md), which splits it into child-tasks
and freezes the per-task test-strategy. Justify any design pattern by the problem it solves.
