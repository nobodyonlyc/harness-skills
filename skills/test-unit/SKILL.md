---
name: test-unit
description: Phase 7 unit testing via test-driven tracer bullets — write one behavior test through the public interface, make it pass, repeat. Always required. Use when: writing new logic, adding a unit-level behavior, the test-strategy selects unit (always), red-green-refactor.
---

## One-Liner
Drive each unit with a test that describes **behavior through the public interface** — one tracer
bullet at a time, never write all tests bulk-first.

**Delegate craft depth to the experts.** For test architecture/mocking/coverage load
[`test-master`](../test-master/SKILL.md); for strict red-green cadence load
[`tdd-workflow`](../tdd-workflow/SKILL.md) (see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)).

## Core Philosophy
Tests verify **behavior**, not implementation: code can be rewritten and good tests survive.
**Anti-pattern — horizontal slicing:** writing all tests first, then all implementation, produces
tests against *imagined* behavior that fail on contact with reality. Use **vertical slices**: one
test → minimal implementation → repeat, each cycle using real learning from the last.

## Workflow
### Phase 1 — Plan
List the behaviors to cover (acceptance criteria + edge cases: null/empty, boundary, error paths),
prioritized. Confirm the public interface (signatures/props/endpoint).
**Gate:** behavior list agreed; no test written yet.
### Phase 2 — Tracer bullet
Write **one** test that (a) calls a public interface, (b) asserts observable output, (c) reads like a
spec ("given X, when Y, then Z"). Run it → confirm it **fails for the right reason** → write the
minimal code → run → green.
**Gate:** test green; it would survive a full rewrite of the implementation.
### Phase 3 — Incremental loop
Repeat Phase 2 per behavior in priority order. Keep tests deterministic (inject clock/network/random);
mock external collaborators; fast (ms).
**Gate:** all selected unit behaviors are green.

## Examples (Bad vs Good)
```python
# BAD: implementation-coupled — breaks on any refactor, tests internals
assert svc._cache._store["k"] == 1
# GOOD: behavior through the public interface — survives a rewrite
assert svc.get("k") == 1
```

## Coverage
Cover every acceptance criterion plus the edge cases listed in Phase 1 (null/empty, boundary, error
paths). Branches with logic must be exercised — an untested error path is a coverage hole. Where the
project sets a coverage threshold, meet it; never lower the threshold to go green.

## Run & record (REQUIRED format — the `test-type-coverage-gate` enforces a green verdict)
Run the project's unit command (`npm test` / `pytest` / `go test ./...`); record the verdict in
evidence `## Test` as a verdict line with a count:

```
## Test
- unit: PASS — 42 tests, 0 failing (covers happy + null/empty/boundary/error paths)
```

A `unit:` line is mandatory (unit is always selected). The gate blocks `harness verify` if the
`unit:` verdict is `FAIL` / `PENDING` / `TODO` / `SKIP` rather than `PASS`. This command is the
task's `unit:` verification, executed by `harness verify`.
**Gate:** unit green is a prerequisite for the broader test types and verify.

(Methodology adapted from tdd-workflow, theNeoAI, MIT. Test types are selected by
[check-test-strategy](../check-test-strategy/SKILL.md).)
