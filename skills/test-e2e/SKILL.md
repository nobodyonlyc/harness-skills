---
name: test-e2e
description: Phase 7 end-to-end testing — drive a complete user-facing flow through the real system to confirm it works as the user experiences it. Required when a user flow exists. Use when: a task delivers a user-facing end-to-end flow, validating a journey through the real UI/API, or the test-strategy selected e2e from a design-ux-flow.
---

## One-Liner
Drive the whole flow through the real system as a user would — happy path plus a key failure path —
on seeded data, not mocks, to confirm it works as experienced, not just as unit-tested.

**Activation:** required when the task delivers a **user-facing end-to-end flow** (sourced from
[design-ux-flow](../design-ux-flow/SKILL.md)).

## Run
- Drive the flow through the real UI/API as a user would (e.g. browser automation or full-stack HTTP).
- Cover the **happy path** + the key failure path (invalid input, auth required, empty state).
- Use a realistic environment (seeded test data), not mocks of the system under test.
- Keep flows independent and idempotent; clean up created state.

## Record
Record results (and screenshots/artifacts where useful, written to files) in evidence `## Test`;
this is the `e2e:` verification. E2E is the slowest tier — run after unit + integration are green.
```
## Test
- e2e: PASS — <journey> via real UI/API (seeded data)
  happy path + failure path (invalid input / auth / empty) covered
```

**Gate:** the user-facing flow passes happy + key failure path end-to-end (after UT + IT green).
