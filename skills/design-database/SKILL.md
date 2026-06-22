---
name: design-database
description: Phase 2 data design — model entities, relationships, keys, indexes, and migrations from the requirements and architecture.
---

Input: `docs/requirements.md`, `docs/design/architecture.md`. Output: `docs/design/database.md`.

## Produce
- **Entities & attributes** with types and nullability.
- **Relationships** (ER) and cardinality; primary/foreign keys.
- **Indexes** for the expected query patterns; uniqueness constraints.
- **Migrations** strategy (forward-only; destructive changes are always-stop —
  [../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).

## Persona
- **Developer** — review schema, normalization choices, and index trade-offs.
- **Non-Technical** — describe data the system remembers in plain terms; pick a normalized default and log it.

## Gate
Step-gate; write to file. Destructive schema/data migrations are **always-stop** regardless of mode.
Hands off to `design-api` and informs the test-strategy (data-touching changes → regression/IT).
