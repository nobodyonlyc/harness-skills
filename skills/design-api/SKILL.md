---
name: design-api
description: Phase 2 API design — define endpoints/operations, request/response contracts, status/error model, and versioning between components. Use when: defining endpoints/operations, specifying request/response contracts, designing an error/status model, or setting a versioning stance between components.
metadata:
  layer: design
  tier: judgment
  delegates:
    - {trigger: "endpoint/contract design", to: api-designer}
---

## One-Liner
Pin down the contract before code: every operation's inputs/outputs/auth, the error model, and the
versioning stance — these become the integration and e2e test oracle in phase ⑦.

Input: `docs/design/architecture.md`, `docs/design/database.md`. Output: `docs/design/api.md`.

**Delegate craft depth to the expert.** For REST/GraphQL modeling, versioning, pagination, and
OpenAPI specifics, load the vendored [`api-designer`](../api-designer/SKILL.md) (see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)). This skill keeps the
harness wiring (output doc, gates, handoff to tests).

## Output template (docs/design/api.md)
```markdown
### <METHOD> /path        (auth: <required?>)
Request:  { field: type, ... }   validation: <rules>
Response: 200 { ... } | 4xx { error envelope }
Idempotent: yes/no    Paginated: yes/no
Versioning: <stance / backward-compat>
```

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
