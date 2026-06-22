---
name: workflow-bugfix
description: Fix a bug on an existing harness project — reproduce first with a failing test, make the minimal fix, then prove it with regression tests, review, and verify.
---

Bug report: $ARGUMENTS

Reproduce-first, regression-focused. Smaller design footprint than `workflow-feature` but the same
review/test/verify gates.

## Loop
1. **Reproduce** — write a **failing test first** that captures the bug (UT or IT per
   `check-test-strategy`). Do not fix anything until red is reproduced.
2. **Locate** — use `core-explore` / `core-explain` to find the root cause; record it in the plan.
3. **Minimal fix** (`dev-*`) — smallest change that turns the failing test green; resist scope creep.
4. **Regression** (`test-regression`) — run the broader suite for the touched area to prove nothing
   else broke; this is **mandatory** for bugfix since it edits existing behavior.
5. **Review** (`check-code-review`) — record findings to evidence `## Review`.
6. **Verify** — `./harness verify <id>`; the reproduction test + regression are part of the recorded `## Test`.

## Rules
- **Failing test before fix** — a fix without a reproducing test is not accepted.
- **Regression is required** — bugfix touches existing behavior, so `check-test-strategy` always
  includes regression here (see [../../resources/persona-mode.md](../../resources/persona-mode.md)
  for how results are reported per role).
- **Minimal footprint** — if the fix reveals a larger design problem, surface it as a separate
  feature (WIP=1), do not expand this one.
- **Step-gate + token budget** apply as in [workflow-feature](../workflow-feature/SKILL.md).
