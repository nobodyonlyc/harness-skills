---
name: plan-tasks
description: Phase 4 task planning — split a User Story into vertical child-tasks and freeze the per-task test-strategy into the harness verifications before start (they are immutable afterwards). Use when: splitting a US into child-tasks, decomposing bootstrap Stage A, freezing per-task test-strategy before start, or scaffolding task plans for the dev phase.
---

## One-Liner
Split the US into thin vertical child-tasks and **freeze each task's test-strategy as immutable
verifications before start** — because the harness locks them at `start`, the strategy must be
right now, not later.

Input: an approved US + its design docs. Output: child-tasks in the backlog + a filled `plan.md`.

## Split
Break the US into **vertical child-tasks** `F<id>-T<n>` — each a thin slice that can be coded,
reviewed, tested, and verified on its own. Avoid layer-by-layer tasks (they defeat per-task verify).

> The **same child-task mechanism** is used for **Stage A setup** in
> [workflow-bootstrap](../workflow-bootstrap/SKILL.md): the bootstrap parent `F00` is decomposed into
> `F00-T1` BA, `F00-T2` design, `F00-T3` UI, `F00-T4` plan+skeleton, so each setup phase gets its own
> plan/review/verify. Setup-phase children are doc/design deliverables, so their verifications are
> artifact-existence checks rather than the test matrix below.

## Freeze the test-strategy (the critical step)
For **each** child-task, run [check-test-strategy](../check-test-strategy/SKILL.md) to decide the
**required test types** from the task's characteristics:

| Test type | Required when |
|---|---|
| Unit (UT) | always |
| Integration (IT) | crosses components / external integration |
| Regression | touches existing behavior |
| E2E | a user-facing end-to-end flow |
| Performance | a latency/throughput NFR |
| Security | auth / secrets / sensitive data / external surface |

Write the chosen test commands as the task's verifications **at add/plan time** — they are
**immutable after `harness start`** (this is why the strategy is frozen now, not later):
```bash
./harness add F<id>-T<n> "<task>" --priority <p> --area <a> --behavior "<observable>" \
  --verifications "unit:<cmd>" "integration:<cmd>" "regression:<cmd>" ...
```

## Scaffold the plan
Run `./harness plan F<id>-T<n>` and fill `docs/design-docs/F<id>-T<n>/plan.md` (approach, files,
not-in-scope, risks). The `phase-guard` hook blocks `start` until the plan is real.

## Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md))
- **Non-Technical** — keep the task list coarse and hide the IDs/commands; just confirm the plan.
- **Developer** — review the full child-task split + the selected test types per task.

## Gate
Step-gate before starting the first child-task. Hands each task to `dev-*` (F16) →
`check-code-review` → the selected `test-*` skills → `harness verify`.
