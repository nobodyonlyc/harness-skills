# Review Checklist

Walk every changed file against these. Tick mentally; record any miss as a `## Review` finding.

## Correctness
- [ ] Edge cases: empty, null, zero, negative, max, unicode, timezone.
- [ ] Error paths handled; no swallowed exceptions; errors surfaced with context.
- [ ] Off-by-one / boundary conditions in loops and slices.
- [ ] Concurrency: shared state guarded; no race; idempotent where retried.
- [ ] Resource cleanup (files, connections, locks) on all paths incl. error.

## Security (deep pass → check-security-review)
- [ ] All external input validated/escaped at the boundary.
- [ ] No injection (SQL/command/template/path); parameterized queries only.
- [ ] AuthZ checked on every protected path; deny by default.
- [ ] No secrets in code, logs, or responses.

## Contract & data
- [ ] Matches `docs/design/api.md` request/response + status/error model.
- [ ] Schema/migration matches `docs/design/database.md`; migration is forward-only.
- [ ] No silent behavior change to existing callers.

## Scope & clarity
- [ ] Change stays inside the child-task (WIP=1); unrelated edits flagged as a new feature.
- [ ] No obvious duplication / dead code (deep cleanup → check-refactor).
- [ ] Names say what they mean; comments explain *why*, not *what*.

## Tests
- [ ] The selected test types (check-test-strategy) exist and assert behavior, not implementation.
- [ ] New/changed behavior has a test; bug fixes have a reproduction test.
