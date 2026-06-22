---
name: dev-db
description: Phase 5 database implementation — write migrations, schema objects, and data-access code for a child-task per the data design.
---

Input: `docs/design/database.md` + the child-task `plan.md`.

## Implement
- Write **forward-only migrations**; never edit a shipped migration. Destructive changes
  (drop/alter that loses data) are **always-stop** ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- Implement schema objects, constraints, and indexes as designed.
- Data-access code: parameterized queries only (no string-built SQL); handle nulls and tx boundaries.

## Self-check
- Migration applies cleanly **and** rolls forward on a fresh DB; indexes match query patterns.

## Handoff
To `check-code-review` then **regression** + **integration** tests (data changes touch existing
behavior, so the strategy includes regression — see `check-test-strategy`).
