---
name: dev-be
description: Phase 5 backend implementation — implement a child-task's server-side logic (services, persistence, endpoints) following the design docs and language conventions. Use when: implementing server-side logic for a child-task, building services/persistence/endpoints, coding against an API contract + schema, or the Phase 5 backend slice.
---

## One-Liner
Build the thinnest server-side slice that satisfies this task's acceptance criteria — honoring the
API contract and schema exactly, structured errors, no secrets — and stop at the task boundary.

Input: a child-task `plan.md` + the design docs (architecture/database/api). Scope: this task only (WIP=1).

**Delegate framework craft to the expert.** Match the project's backend stack to its expert via
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md) (FastAPI/Django →
`fastapi-expert`/`django-expert`, Spring Boot → `spring-boot-engineer`, NestJS → `nestjs-expert`,
Rails → `rails-expert`, Laravel → `laravel-specialist`, ASP.NET → `dotnet-core-expert`, Next.js
API → `nextjs-developer`) and follow it for framework idioms. This skill keeps owning the contract,
schema, error model, and gates.

## Implement
- Build the **thinnest slice** that satisfies the task's behavior and acceptance criteria.
- Follow the API contract (`docs/design/api.md`) and schema (`docs/design/database.md`) exactly.
- Apply the language guide in [../../resources/conventions/](../../resources/conventions/).
- Comments explain **why**, not what (harness rule); keep functions small and testable.
- Wire structured errors per the design's error model; no secrets in code.

## Examples (Bad vs Good)
```python
# BAD: contract drift + string-built query + secret in code
@app.post("/orders")
def create(o):
    db.exec(f"insert into orders values ('{o['id']}')")   # injection; ignores api.md shape
    return {"ok": 1}                                        # not the designed response envelope
# GOOD: validated input, parameterized, designed error model
@app.post("/orders", response_model=OrderOut)
def create(o: OrderIn):                                     # matches docs/design/api.md
    try: return svc.create_order(o)                         # parameterized in the repo layer
    except DuplicateOrder: raise HTTPError(409, code="duplicate")
```

## Self-check before handoff
- The task's **unit** behavior works locally; obvious edge cases handled.
- No scope creep beyond the child-task — surface larger issues as a new feature.
**Gate:** the task's behavior works locally against the contract/schema, with no scope creep.

## Handoff
Hand to `check-code-review` (F08), then the selected `test-*` skills (the strategy frozen in
plan-tasks), then `harness verify`. Compress inter-agent handoff notes per
[../../resources/token-budget.md](../../resources/token-budget.md).
