---
name: check-qa
description: Phase 8 QA loop — run the task's selected test set and drive a reproduce-fix-re-verify loop until everything is green, with a cap and escalation when it cannot converge. Use when: a coded+reviewed task needs its tests driven to green, the Phase 8 QA gate, a failing test set that must converge, or reproduce-fix-re-verify on the selected suite.
---

## One-Liner
QA is a capped converging loop: run the frozen test set, reproduce each failure with a test, fix
minimally, re-run — until green or escalate. Never weaken a test to force green.

Input: a coded + reviewed child-task with its frozen test set
([check-test-strategy](../check-test-strategy/SKILL.md)).

## The loop
1. Run the **full selected test set** (UT + whichever of IT/regression/e2e/perf/security applies).
2. On **green** → record results in evidence `## Test`, exit to `harness verify`.
3. On **failure** → for each failure:
   - If not already captured, add a **failing test that reproduces it** (per
     [workflow-bugfix](../workflow-bugfix/SKILL.md)).
   - Make the **minimal fix**; re-run the affected tests, then the full set (regression).
4. Repeat from step 1.

**Gate:** the full selected test set is green and recorded in evidence `## Test` (or escalated).

## Cap & escalation
- Cap the loop (e.g. 3–5 iterations). If still red after the cap, **stop and ask-user** with the
  failing output and a hypothesis — do not loop forever or weaken the tests to force green.
- Never delete/relax a test to pass the gate; that is a quality failure.

## Persona
- **Non-Technical** — report "found and fixed N issues; all checks pass" (or escalate in plain language).
- **Developer** — show the failure → fix → re-verify trail.

## Output
A green test set recorded in evidence `## Test`, ready for `harness verify`. The loop is capped for
runaway protection ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
```
## Test
- unit: PASS (42 tests)
- integration: PASS (db + api)
- regression: PASS
Iterations: 2 (1 failure reproduced, fixed in <sha>)
```
