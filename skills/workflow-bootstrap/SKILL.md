---
name: workflow-bootstrap
description: Create a new project from a prompt — drive a greenfield idea through the full 9-phase lifecycle (BA, design, UI, plan, code, review, test, fixbug, deploy), step-gated and persona-aware.
---

Greenfield request: $ARGUMENTS

Turn a prompt into a working, verified project. Reached from `workflow-intake` case 1, or directly
when the repo is empty and the user asked to build something.

## Pre-flight — make the setup itself resumable
- Ensure persona/autonomy/collab are set (else run [workflow-intake](../workflow-intake/SKILL.md) Phase 0.5–0.7).
- `./harness init` if `.harness/` is not yet seeded; `./harness session start --goal "bootstrap <name>"`.
- **Create + start a bootstrap tracking feature so Stage A survives an interrupt.** Without this, BA/design/UI
  produce only file artifacts and `harness resume` has no in-progress feature to continue from:
  ```bash
  ./harness add F00 "Project bootstrap (BA → design → UI → backlog)" --priority 0 --area infra \
    --behavior "requirements.md + design docs + UI + seeded US backlog + green skeleton exist" \
    --verifications "unit:test -f docs/requirements.md && test -d docs/design && bash ./init.sh"
  ./harness start F00      # creates .harness/tasks/F00.md
  ```
  Expand `.harness/tasks/F00.md` to the full template ([../../resources/task-state.md](../../resources/task-state.md))
  with one box per Stage-A phase; tick + commit at every phase boundary.

## Stage A — project setup (tracked under F00, runs ONCE)
Drive these in order. Each delegates to its leaf skill, **writes its artifact to a file**, **ticks
its F00 task-state box + commits**, then **step-gates** ([../../resources/step-gate.md](../../resources/step-gate.md)).
Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md)) sets depth/language.

| Phase | Skill | Output artifact | F00 box |
|---|---|---|---|
| ① Business analysis | `plan-ba-analysis` → `plan-us-backlog` | `docs/requirements.md` + seeded US backlog (`harness add F01…`) | BA |
| ② System design | `design-architecture`, `design-database`, `design-api`, `design-detailed` | `docs/design/*` | design |
| ③ UI design | `design-ui`, `design-ux-flow` | `docs/design/ui/*` | UI |
| ④ Plan tasks | `plan-tasks`, `plan-skeleton` | child-tasks + **frozen test-strategy** + green skeleton | backlog + skeleton |

**Close Stage A:** when ①–④ are done, `./harness verify F00` → `passing`. Only then start Stage B
(this keeps **WIP=1**: F00 passes before any US starts).

## Stage B — per-US execution (repeated, via workflow-feature)
For each backlog US, run phases ⑤–⑨ through [workflow-feature](../workflow-feature/SKILL.md):
`harness plan <id>` → `start` → ⑤ code (`dev-*`) → ⑥ review (`check-code-review`, `check-refactor`) →
⑦ test (`check-test-strategy` → `test-*`) → ⑧ fix (`check-qa`) → `harness verify <id>` →
⑨ ship (`ship-commit-msg`/`ship-pr-create`; deploy = always-stop). In `solo` you may auto-chain USs
(Non-Technical default); in `team` each assignee holds one US — see
[workflow-team](../workflow-team/SKILL.md).

## Resumability (why the two stages matter)
After any interrupt, `./harness resume` reports the active feature + its task-state + next step:
- mid-Stage-A → **F00** is `in_progress`, its task-state says which phase finished and which is next.
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
- **Token budget** — compress inter-agent prompts, write artifacts to files
  ([../../resources/token-budget.md](../../resources/token-budget.md)).
- **Verify before done** — no US is `passing` without review + required tests recorded in evidence.
- **Task-state** — after `./harness start <id>` expand `.harness/tasks/<id>.md` to the full template;
  tick `[ ]→[/]→[x]` and update Next step at each phase boundary
  ([../../resources/task-state.md](../../resources/task-state.md)).
