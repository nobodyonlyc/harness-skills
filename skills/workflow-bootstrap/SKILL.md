---
name: workflow-bootstrap
description: Create a new project from a prompt — drive a greenfield idea through the full 9-phase lifecycle (BA, design, UI, plan, code, review, test, fixbug, deploy), step-gated and persona-aware. Use when: starting a greenfield project, an empty repo and the user asked to build something, scaffolding a new app/service from a prompt, or workflow-intake routed case 1.
metadata:
  layer: workflow
  tier: entry
---

Greenfield request: $ARGUMENTS

## One-Liner
Setup runs once and per-US execution repeats: model project setup as F00 child-tasks (Stage A,
once) and every User Story as a workflow-feature run (Stage B, repeated), so any interrupt is
resumable from the active feature — never from chat.

Turn a prompt into a working, verified project. Reached from `workflow-intake` case 1, or directly
when the repo is empty and the user asked to build something.

```text
Stage A (ONCE):  F00-T1 BA → F00-T2 design → F00-T3 UI → F00-T4 plan+skeleton → close F00
Stage B (LOOP):  for each backlog US → workflow-feature (code→review→test→verify→ship)
```

## Pre-flight — seed the setup as a parent + child-tasks
- Ensure persona/autonomy/collab are set (else run [workflow-intake](../workflow-intake/SKILL.md) Phase 2–3).
- `./harness init` if `.harness/` is not yet seeded; `./harness session start --goal "bootstrap <name>"`.
- **Seed a bootstrap parent `F00` and one child-task per Stage-A phase**, so each setup phase is
  individually planned, reviewed, and verified — and any interrupt is resumable from the active child
  ([../../resources/task-state.md](../../resources/task-state.md), child-task convention):
  ```bash
  ./harness add F00 "Project bootstrap (BA → design → UI → plan)" --priority 0 --area infra \
    --behavior "requirements.md + design docs + UI + seeded US backlog + green skeleton exist" \
    --verifications "unit:test -f docs/requirements.md && test -d docs/design && bash ./init.sh"
  ./harness add F00-T1 "BA: requirements + US backlog"  --priority 1 --area task --behavior "parent: F00" --verifications "unit:test -f docs/requirements.md"
  ./harness add F00-T2 "System design"                  --priority 2 --area task --behavior "parent: F00" --verifications "unit:test -d docs/design"
  ./harness add F00-T3 "UI design"                       --priority 3 --area task --behavior "parent: F00" --verifications "unit:test -d docs/design/ui"
  ./harness add F00-T4 "Plan tasks + skeleton"           --priority 4 --area task --behavior "parent: F00" --verifications "unit:bash ./init.sh"
  ```
  Do **not** start `F00` yet — starting the parent would block the children under WIP=1.

**Gate:** persona/autonomy/collab are set, a session is active, and `F00` + `F00-T1…T4` exist
(parent still not-started).

## Stage A — project setup (F00 child-tasks, runs ONCE)
Run the children **one at a time** (WIP=1), each as a full mini-loop —
`harness plan F00-Tn` → `start` → produce artifact → review by a design-derived role
(`scripts/role-resolver.sh --phase design` → an Architect; `check-code-review` for code artifacts) →
`harness verify F00-Tn` —
with a **step-gate** ([../../resources/step-gate.md](../../resources/step-gate.md)) between them and the
task-state file updated per child. Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md))
sets depth/language.

| Child-task | Skill | Output artifact |
|---|---|---|
| **F00-T1** ① Business analysis | `plan-ba-analysis` → `plan-us-backlog` | `docs/requirements.md` + seeded US backlog (`harness add F01…`) |
| **F00-T2** ② System design | `design-architecture` (+ `design-stack-research`), `design-database`, `design-api`, `design-detailed` | `docs/design/*` incl. `stack-versions.md` |
| **F00-T3** ③ UI design | `design-ui`, `design-ux-flow` | `docs/design/ui/*` |
| **F00-T4** ④ Plan tasks | `plan-tasks`, `plan-skeleton` | child-tasks for the US + **frozen test-strategy** + green skeleton **under `source_dir/`** (named after the system, not the repo root) |

Splitting Stage A into child-tasks gives **design and UI their own `## Review` evidence** and finer
resume granularity — see [plan-tasks](../plan-tasks/SKILL.md) (it decomposes Stage A the same way it
decomposes a US).

**Close Stage A:** once **F00-T1…T4 are all `passing`** (nothing in_progress), `./harness start F00`
→ write `docs/design-docs/F00/evidence.md` (summary + links to the child evidence) → `./harness verify F00`
→ `passing`. Only then start Stage B (this keeps **WIP=1**: the parent is started last, after its children).

**Gate:** `F00` is `passing` (requirements + design + UI + seeded US backlog + green skeleton all
exist and verified), so Stage B has a working frame to build on.

## Stage B — per-US execution (repeated, via workflow-feature)
For each backlog US, run phases ⑤–⑨ through [workflow-feature](../workflow-feature/SKILL.md):
`harness plan <id>` → `start` → ⑤ code (`dev-*`) → ⑥ review ([check-review-loop](../check-review-loop/SKILL.md):
independent **role-based** review — `scripts/role-resolver.sh --phase review` + `harness review open/record` provenance — + fix loop, `check-refactor`) →
⑦ test (`check-test-strategy` → `test-*`) → ⑧ fix (`check-qa`) → `harness verify <id>` →
⑨ ship (`ship-commit-msg`/`ship-pr-create`; deploy = always-stop). In `solo` you may auto-chain USs
(Non-Technical default); in `team` each assignee holds one US — see
[workflow-team](../workflow-team/SKILL.md).

**Gate:** every targeted backlog US is `passing` (review + required tests in its evidence), or the
remaining ones are explicitly deferred with the user.

## Resumability (why the two stages matter)
After any interrupt, `./harness resume` reports the active feature + its task-state + next step:
- mid-Stage-A → the active **F00-Tn** child is `in_progress`, its task-state says what is next (the
  parent `F00` stays not-started until its children pass).
- mid-Stage-B → the current **US** is `in_progress` with its own task-state.
No bootstrap progress lives only in chat — it is always recoverable from `features.json` + `.harness/tasks/`.

## Persona behavior (per phase)
- **Non-Technical** — Stage A asks requirement-level questions in plain language and picks sensible
  technical defaults (logged); auto-advance; review/test still run fully but report in plain terms.
- **Developer** — Stage A is exhaustive (acceptance, schema, contracts, NFRs, test strategy); gated
  after every phase; trade-offs surfaced for approval.

## Cross-cutting
- **Step-gate** between every phase; **always-stop** before deploy and any irreversible action
  ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- **Caveman (on by default)** — apply [opt-caveman](../opt-caveman/SKILL.md) to every inter-agent
  prompt and subagent result across Stage A and Stage B, and write long artifacts to files
  ([../../resources/token-budget.md](../../resources/token-budget.md)).
- **Verify before done** — no US is `passing` without review + required tests recorded in evidence.
- **Task-state** — after `./harness start <id>` expand `.harness/tasks/<id>.md` to the full template;
  tick `[ ]→[/]→[x]` and update Next step at each phase boundary
  ([../../resources/task-state.md](../../resources/task-state.md)).
