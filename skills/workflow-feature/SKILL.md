---
name: workflow-feature
description: Execute one backlog User Story end-to-end on an existing harness project through the gated phase chain (BA delta, design, plan, code, review, test, verify, ship).
---

Target US: $ARGUMENTS

Execute a single backlog User Story to `passing`. Reached from `workflow-intake` case 2/3 or
`workflow-bootstrap` per-US execution.

## Loop
1. **Claim & plan** — `./harness plan <id>`, fill `docs/design-docs/<id>/plan.md`. In `team`,
   `./harness start <id> --assignee <name> --branch` (see [workflow-team](../workflow-team/SKILL.md)); else `./harness start <id>`.
2. **BA delta** (`plan-ba-analysis`) — only what this US changes; persona sets depth.
3. **Design delta** (`design-*`) — touch only affected architecture/schema/API/UI.
4. **Plan tasks** (`plan-tasks`) — split into `F<id>-T<n>`, and **freeze the test-strategy**
   (`check-test-strategy`) into each task's immutable `--verifications` before start.
5. **Code** (`dev-*`) — implement per `../../resources/conventions/`.
6. **Review** — drive [check-review-loop](../check-review-loop/SKILL.md): an **independent** reviewer
   (`check-code-review` dimensions) records findings as a tracked checklist in evidence `## Review`,
   then a capped fix → re-review loop runs until no `- [ ]` is open; `check-refactor` for cleanup.
7. **Test** — run the selected types (`test-unit` … `test-security` as the strategy requires);
   record to evidence `## Test`.
8. **Verify** — `./harness verify <id>` (gated by quality + review hooks).
9. **Ship** (`ship-commit-msg` → `ship-pr-create`) — deploy only via `workflow` deploy step (always-stop).

## Cross-cutting
- **Step-gate** between phases ([../../resources/step-gate.md](../../resources/step-gate.md)); in
  `auto`, log the decision.
- **Persona** ([../../resources/persona-mode.md](../../resources/persona-mode.md)) — non-tech gets
  plain-language progress + auto-advance; dev gets exhaustive questions + per-phase gate.
- **Scope discipline (WIP=1)** — stay inside this US; cross-cutting fixes become a separate feature.
- **Token budget** — compress inter-agent prompts, artifacts to files
  ([../../resources/token-budget.md](../../resources/token-budget.md)).
- **No silent completion** — `passing` requires review + required tests in `evidence.md`.
- **Task-state** — expand `.harness/tasks/<id>.md` after start; tick boxes + update Next step at each
  phase boundary and commit ([../../resources/task-state.md](../../resources/task-state.md)).
