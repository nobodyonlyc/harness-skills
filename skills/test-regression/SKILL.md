---
name: test-regression
description: Phase 7 regression testing — re-run the broader test suite for the touched area to prove a change did not break existing behavior. Required whenever a task edits live code or data. Use when: a change edits/refactors live code, alters a DB schema or shared component, every bugfix, or the test-strategy selected regression.
---

## One-Liner
Re-run the broader suite for the touched area — never just the new tests — and compare against the
pre-change baseline; any newly-failing test is a regression to fix before verify.

**Activation:** required when the task **touches existing behavior** — edits/refactors live code,
changes a DB schema, or alters a shared component (per [check-test-strategy](../check-test-strategy/SKILL.md)).
This is **mandatory for every bugfix** ([workflow-bugfix](../workflow-bugfix/SKILL.md)).

## Run
- Execute the existing suite for the affected module(s), not just the new tests.
- For bugfixes, ensure the **reproduction test** is part of the suite and now passes.
- Compare against the pre-change baseline; any newly-failing test is a regression to fix before verify.

## Record
Record pass/fail (and any fixed regressions) in evidence `## Test`; this is the `regression:`
verification. Do not narrow the suite to make it pass — that hides regressions.
```
## Test
- regression: PASS — full suite for <module> (baseline: <ref>)
  reproduction test for <bug> included and now green
```

**Gate:** the affected module's full suite is green against baseline (no narrowing) before `harness verify`.
