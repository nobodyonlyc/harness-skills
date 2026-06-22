---
name: check-refactor
description: Phase 6 refactor pass — improve reuse, simplification, and clarity of the changed code without changing behavior. Quality only; does not hunt for bugs.
---

Input: the changed code for the current task. Behavior must stay identical.

## Look for
- **Duplication** that can be unified; dead code to remove.
- **Needless complexity** — over-abstraction, deep nesting, long functions to split.
- **Naming/clarity** — names that mislead; comments that restate code instead of explaining why.
- **Altitude** — leaking low-level detail through a high-level interface.

## Rules
- **Behavior-preserving only.** If a change alters behavior, it belongs in `workflow-bugfix` or a feature.
- Tests must stay green throughout; refactor in small steps.
- Do not expand scope — this is cleanup of the current change, not the whole codebase.

## Handoff
Re-run the task's tests after refactoring; note the cleanup in evidence `## Review`. This is the
quality complement to `check-code-review` (which finds bugs).
