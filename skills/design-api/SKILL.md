---
name: design-api
description: Phase 2 API design — define endpoints/operations, request/response contracts, status/error model, and versioning between components.
---

Input: `docs/design/architecture.md`, `docs/design/database.md`. Output: `docs/design/api.md`.

## Produce
- **Operations** — each endpoint/method: purpose, inputs, outputs, auth requirement.
- **Contracts** — request/response shapes (types), validation rules.
- **Error model** — status codes / error envelope, idempotency where relevant.
- **Versioning** and backward-compatibility stance.

## Persona
- **Developer** — review contracts and the error model; confirm idempotency/pagination/auth choices.
- **Non-Technical** — skip; the API is internal detail. Note only externally visible behavior.

## Gate
Step-gate; write to file. The contracts are the basis for **integration tests** (`test-integration`)
and any **e2e** flows in phase ⑦. Hands off to `design-detailed`.
