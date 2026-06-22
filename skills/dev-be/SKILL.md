---
name: dev-be
description: Phase 5 backend implementation — implement a child-task's server-side logic (services, persistence, endpoints) following the design docs and language conventions.
---

Input: a child-task `plan.md` + the design docs (architecture/database/api). Scope: this task only (WIP=1).

## Implement
- Build the **thinnest slice** that satisfies the task's behavior and acceptance criteria.
- Follow the API contract (`docs/design/api.md`) and schema (`docs/design/database.md`) exactly.
- Apply the language guide in [../../resources/conventions/](../../resources/conventions/).
- Comments explain **why**, not what (harness rule); keep functions small and testable.
- Wire structured errors per the design's error model; no secrets in code.

## Self-check before handoff
- The task's **unit** behavior works locally; obvious edge cases handled.
- No scope creep beyond the child-task — surface larger issues as a new feature.

## Handoff
Hand to `check-code-review` (F08), then the selected `test-*` skills (the strategy frozen in
plan-tasks), then `harness verify`. Compress inter-agent handoff notes per
[../../resources/token-budget.md](../../resources/token-budget.md).
