---
name: workflow-bootstrap
description: Create a new project from a prompt — drive a greenfield idea through the full 9-phase lifecycle (BA, design, UI, plan, code, review, test, fixbug, deploy), step-gated and persona-aware.
---

Greenfield request: $ARGUMENTS

Turn a prompt into a working, verified project. Reached from `workflow-intake` case 1, or directly
when the repo is empty and the user asked to build something.

## Pre-flight
- Ensure persona/autonomy/collab are set (else run [workflow-intake](../workflow-intake/SKILL.md) Phase 0.5–0.7).
- `./harness init` if `.harness/` is not yet seeded; `./harness session start --goal "bootstrap <name>"`.

## The 9-phase chain
Drive these in order. Each phase delegates to its leaf skill, ends by writing its artifact to a
file, then **step-gates** ([../../resources/step-gate.md](../../resources/step-gate.md)) before the
next. Persona ([../../resources/persona-mode.md](../../resources/persona-mode.md)) sets depth/language.

| Phase | Skill | Output artifact |
|---|---|---|
| ① Business analysis | `plan-ba-analysis` → `plan-us-backlog` | requirements + US backlog |
| ② System design | `design-architecture`, `design-database`, `design-api`, `design-detailed` | design docs |
| ③ UI design | `design-ui`, `design-ux-flow` | mockups + flows |
| ④ Plan tasks | `plan-tasks`, `plan-skeleton` | child-tasks + **frozen test-strategy** + skeleton |
| ⑤ Code | `dev-be` / `dev-fe` / `dev-cli` / `dev-db` / `dev-batch` | implementation |
| ⑥ Review | `check-code-review`, `check-refactor` | evidence `## Review` |
| ⑦ Test | `check-test-strategy` → `test-unit` … `test-security` | evidence `## Test` |
| ⑧ Fix bug | `check-qa` | loop to green |
| ⑨ Deploy | `ship-commit-msg` → `ship-pr-create` → `ship-release`/`ship-deploy` | shipped (deploy = always-stop) |

## Persona behavior (per phase)
- **Non-Technical** — phases ①–④ ask requirement-level questions in plain language and pick sensible
  technical defaults (logged); auto-advance through phases; ⑥⑦ still run fully but report in plain terms.
- **Developer** — phases ①–④ are exhaustive (acceptance, schema, contracts, NFRs, test strategy);
  gated after every phase; trade-offs surfaced for approval.

## Per-US execution
After phase ④ seeds the backlog, each User Story is executed via
[workflow-feature](../workflow-feature/SKILL.md): `harness plan <id>` → `start` → code → review →
test → verify → ship. In `solo` runs you may auto-chain USs (Non-Technical default); in `team`
each assignee holds one US — see [workflow-team](../workflow-team/SKILL.md).

## Cross-cutting
- **Step-gate** between every phase; **always-stop** before deploy and any irreversible action
  ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- **Token budget** — compress inter-agent prompts, write artifacts to files
  ([../../resources/token-budget.md](../../resources/token-budget.md)).
- **Verify before done** — no US is `passing` without review + required tests recorded in evidence.
- **Task-state** — after `./harness start <id>` expand `.harness/tasks/<id>.md` to the full template;
  tick `[ ]→[/]→[x]` and update Next step at each phase boundary
  ([../../resources/task-state.md](../../resources/task-state.md)).
