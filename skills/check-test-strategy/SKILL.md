---
name: check-test-strategy
description: Phase 7 test selector — decide which test types a task requires (unit always; integration, regression, e2e, performance, security conditionally) from its characteristics, and emit them as harness verifications.
---

Input: a child-task's plan + design context. Output: the **required test set** and the matching
`--verifications` commands, frozen at plan time (see [plan-tasks](../plan-tasks/SKILL.md)).

## Selection matrix
Answer each question for the task; include the test type when the condition holds:

| Test type | Required when | Skill |
|---|---|---|
| **Unit (UT)** | always | [test-unit](../test-unit/SKILL.md) |
| **Integration (IT)** | crosses components or calls an external dependency | [test-integration](../test-integration/SKILL.md) |
| **Regression** | the change touches existing behavior (edits/refactors live code, DB migrations) | `test-regression` (F18) |
| **E2E** | a user-facing end-to-end flow exists (from `design-ux-flow`) | `test-e2e` (F18) |
| **Performance** | a latency/throughput NFR is stated for the task | `test-performance` (F18) |
| **Security** | auth, secrets, sensitive data, or an external attack surface is involved | `test-security` + a [check-security-review](../check-security-review/SKILL.md) pass |

## Emit verifications
Map each selected type to a runnable command for the project's stack and write them at add time:
```bash
./harness add F<id>-T<n> "<task>" ... \
  --verifications "unit:<cmd>" "integration:<cmd>" "regression:<cmd>" ...
```
Because harness locks verifications at `start`, the selection **must** happen now (phase ④). Record
the rationale ("IT included because the task calls the payments API") in the task plan.

## Persona
- **Non-Technical** — do not surface the matrix; just run the selected tests and report pass/fail plainly.
- **Developer** — show the selected set + the reason per type for review.

## Rule
Under-selecting tests is a quality failure, not a token saving — when a condition is borderline,
**include** the test ([../../resources/token-budget.md](../../resources/token-budget.md)).
