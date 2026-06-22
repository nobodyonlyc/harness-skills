---
name: test-unit
description: Phase 7 unit testing — write and run fast, isolated tests for a task's logic and edge cases. Always required.
---

Scope: a single unit (function/module/component) in isolation. Always part of the test set.

## Write
- Cover the **acceptance criteria** of the task + edge cases (null/empty, boundaries, error paths).
- One behavior per test; arrange-act-assert; deterministic (no clock/network/random unless injected).
- Mock external collaborators; keep tests fast (milliseconds).
- Follow the test tooling in [../../resources/conventions/](../../resources/conventions/).

## Run & record
Run the project's unit command (e.g. `npm test`, `pytest`, `go test ./...`); record the result in
evidence `## Test`. This command is the task's `unit:` verification, executed by `harness verify`.

## Gate
All unit tests green is a prerequisite for the broader test types and `harness verify`.
