---
name: test-e2e
description: Phase 7 end-to-end testing — drive a complete user-facing flow through the real system to confirm it works as the user experiences it. Required when a user flow exists.
---

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
