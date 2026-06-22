---
name: test-integration
description: Phase 7 integration testing — verify that components work together across real boundaries (DB, API, services) for tasks that cross components or call external dependencies. Every integration test must be a written test case with explicit steps, concrete input, and a concrete expected output. Use when: a task crosses component boundaries, calls a DB/API/external service, exercising a real API contract + schema, or the test-strategy selected integration.
---

## One-Liner
Exercise the real boundaries — API contract, schema, external deps — against ephemeral/test
instances, including the failure modes, so "the pieces fit" is proven, not assumed. **Every IT is a
documented test case: explicit steps, a concrete input, and a concrete expected output** — never a
vague "it works".

Scope: multiple components together, or a component against a real(istic) external dependency.
Required when the task crosses a boundary (per [check-test-strategy](../check-test-strategy/SKILL.md)).
**Delegate craft depth** (Supertest/Testcontainers/fixtures) to
[`test-master`](../test-master/SKILL.md) → `references/integration-testing.md`.

## Mandatory: write test cases first
Before writing assertions, enumerate the cases as a table. Each row is **executable in your head**:
a reader must be able to predict the result from `Steps + Input → Expected Output`. Cover, at
minimum:
- the **happy path** across the boundary,
- **bad input** rejected at the boundary (validation / 4xx),
- a **failure mode** of the dependency (timeout / partial failure / unavailable),
- **idempotency / state** (no double-write, correct rollback, teardown clean).

Every test case needs all of: **ID · Scenario · Preconditions · Steps · Input · Expected Output ·
Result**. "Expected Output" must be concrete — exact status code, body fields, row count, error
code, side-effect — not "succeeds".

## Evidence format (REQUIRED — the `it-testcase-gate` enforces this)
Record both the one-line verdict **and** the test-case table under `## Test`:

```
## Test
- integration: PASS — order API contract (docs/design/api.md) + schema (ephemeral test DB)

### Integration Test Cases
| ID    | Scenario              | Preconditions            | Steps                              | Input            | Expected Output                                              | Result |
|-------|-----------------------|--------------------------|------------------------------------|------------------|-------------------------------------------------------------|--------|
| IT-01 | create order (happy)  | seeded user, empty cart  | POST /orders → GET /orders/{id}    | {item:A, qty:2}  | 201; body.status="confirmed"; GET returns same id, total=20 | PASS   |
| IT-02 | reject bad quantity   | seeded user              | POST /orders                       | {item:A, qty:-1} | 400; error.code="INVALID_QTY"; 0 rows written to orders     | PASS   |
| IT-03 | payments timeout      | payments stub delays 5s  | POST /orders                       | valid order      | 504; order row status="pending_payment"; no duplicate charge| PASS   |
| IT-04 | idempotent retry      | IT-01 order exists       | POST /orders w/ same Idempotency-Key| same as IT-01   | 200; returns existing order id; still exactly 1 row          | PASS   |
```

The gate requires: an `integration:` verdict line **plus** an `### Integration Test Cases` table
whose header contains `Steps` and `Expected Output`, with **at least one data row**. A table of
only placeholders (`TBD`/`TODO`/`—`) fails the gate.

## Write
- Exercise the **API contract** (`docs/design/api.md`) and **schema** (`docs/design/database.md`) for real.
- Use ephemeral/test instances (test DB, sandboxed service, or a faithful test double) — not production.
- One assertion block per test-case row; the assertion must check the row's **Expected Output** exactly.
- Cover the integration's failure modes (timeout, partial failure, bad input across the boundary).
- Keep them hermetic and repeatable; tear down state between runs (the teardown is itself a case).

## Run & record
Run the integration command; record the verdict **and** the test-case table in evidence `## Test`.
This is the task's `integration:` verification.

## Gate
Integration green (where required) before `harness verify`, **and** every selected case present in
the table with a concrete Expected Output and `Result: PASS`. Slower than UT — run after units pass.
Do not weaken an Expected Output to force a pass; that is a quality failure
([../../resources/token-budget.md](../../resources/token-budget.md)).
