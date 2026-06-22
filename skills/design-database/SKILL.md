---
name: design-database
description: Phase 2 data design — model entities, relationships, keys, indexes, and migrations from the requirements and architecture. Use when: modeling a schema, designing entities/relationships/keys, planning indexes for query patterns, or defining a migration strategy from requirements + architecture.
---

## One-Liner
Turn requirements into a concrete schema — entities, keys, indexes for the real query patterns, and
a forward-only migration plan — with destructive migrations flagged always-stop.

Input: `docs/requirements.md`, `docs/design/architecture.md`. Output: `docs/design/database.md`.

## Output template (docs/design/database.md)
```markdown
## Entities
### <Entity>
| field | type | null? | notes |
## Relationships
<Entity> 1—* <Entity>  (FK: <field>)
## Indexes
- <table>(<cols>)  — serves: <query pattern>
## Migrations
- forward-only; destructive change = always-stop
```

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
