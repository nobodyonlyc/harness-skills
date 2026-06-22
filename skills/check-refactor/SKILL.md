---
name: check-refactor
description: Phase 6 refactor pass — improve reuse, simplification, and clarity of the changed code without changing behavior. Quality only; does not hunt for bugs. Use when: cleaning up a change after review, reducing duplication/complexity in the current task's code, improving names/clarity, or a behavior-preserving tidy-up before verify.
---

## One-Liner
Behavior-preserving cleanup of the current change only: unify duplication, cut needless complexity,
fix misleading names — in small steps with tests green throughout. Never change behavior here.

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

## Examples (Bad vs Good)
```python
# BAD: refactor that silently changes behavior (now skips falsy-but-valid 0)
def total(items):
    return sum(i.price for i in items if i.price)   # was: for i in items
# GOOD: same behavior, clearer — extract intent without dropping any item
def total(items):
    return sum(item.price for item in items)
```

## Handoff
Re-run the task's tests after refactoring; note the cleanup in evidence `## Review`. This is the
quality complement to `check-code-review` (which finds bugs).
**Gate:** the task's tests are green again and behavior is unchanged; cleanup noted in `## Review`.
