---
name: dev-db
description: Phase 5 database implementation — write migrations, schema objects, and data-access code for a child-task per the data design. Use when: writing a migration, implementing schema objects/indexes/constraints, building data-access code, or the Phase 5 database slice. Destructive migrations are always-stop.
---

## One-Liner
Forward-only migrations (never edit a shipped one), parameterized queries only, and destructive
data changes are always-stop — the schema is durable, so mistakes here are expensive.

Input: `docs/design/database.md` + the child-task `plan.md`.

## Implement
- Write **forward-only migrations**; never edit a shipped migration. Destructive changes
  (drop/alter that loses data) are **always-stop** ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- Implement schema objects, constraints, and indexes as designed.
- Data-access code: parameterized queries only (no string-built SQL); handle nulls and tx boundaries.

## Examples (Bad vs Good)
```sql
-- BAD: edits a shipped migration + drops data silently (must be always-stop)
ALTER TABLE orders DROP COLUMN legacy_total;        -- in an already-released migration file
-- GOOD: new forward-only migration; data-preserving; index matches a query pattern
-- 0042_add_orders_status_idx.sql
ALTER TABLE orders ADD COLUMN status text NOT NULL DEFAULT 'open';
CREATE INDEX idx_orders_status ON orders(status);    -- serves the "open orders" query
```

## Self-check
- Migration applies cleanly **and** rolls forward on a fresh DB; indexes match query patterns.
**Gate:** migration applies + rolls forward on a fresh DB; no destructive change without always-stop approval.

## Handoff
To `check-code-review` then **regression** + **integration** tests (data changes touch existing
behavior, so the strategy includes regression — see `check-test-strategy`).
