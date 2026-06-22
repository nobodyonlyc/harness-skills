---
name: test-integration
description: Phase 7 integration testing — verify that components work together across real boundaries (DB, API, services) for tasks that cross components or call external dependencies.
---

Scope: multiple components together, or a component against a real(istic) external dependency.
Required when the task crosses a boundary (per [check-test-strategy](../check-test-strategy/SKILL.md)).

## Write
- Exercise the **API contract** (`docs/design/api.md`) and **schema** (`docs/design/database.md`) for real.
- Use ephemeral/test instances (test DB, sandboxed service, or a faithful test double) — not production.
- Cover the integration's failure modes (timeout, partial failure, bad input across the boundary).
- Keep them hermetic and repeatable; tear down state between runs.

## Run & record
Run the integration command; record results in evidence `## Test`. This is the task's
`integration:` verification.

## Gate
Integration green (where required) before `harness verify`. Slower than UT — run after units pass.
