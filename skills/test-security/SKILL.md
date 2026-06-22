---
name: test-security
description: Phase 7 security testing — check authentication/authorization, input handling, secrets, and known-vulnerability surface. Required when the task touches auth, secrets, sensitive data, or an external surface. Use when: a task touches auth/authz, handles secrets or sensitive/PII data, exposes an external attack surface, or the test-strategy selected security.
---

## One-Liner
Verify the security surface on the **strong** tier — authn/authz, injection/XSS/SSRF, secret
hygiene, vulnerable deps, data exposure — and never downgrade the check to save tokens.

**Activation:** required when the task involves **auth, secrets, sensitive data, or an external
attack surface** (per [check-test-strategy](../check-test-strategy/SKILL.md)).

## Check
- **AuthN/AuthZ** — every protected path enforces identity + permission; no missing checks; deny by default.
- **Input handling** — injection (SQL/command/template), XSS, SSRF, path traversal, unsafe deserialization.
- **Secrets** — none in code/logs/responses; correct storage; least privilege.
- **Dependencies** — scan for known-vulnerable packages; pin/patch.
- **Data exposure** — sensitive fields not over-returned; PII handled per policy.

## Record
Record findings + their resolution in evidence `## Test` and cross-link evidence `## Review`; this
is the `security:` verification. Use **strong** tier — never downgrade a security check to save tokens.
Real exploitation testing stays within authorized scope only.
```
## Test
- security: PASS — authn/authz, input handling, secrets, deps, data-exposure checked
  findings: <none | id → resolution>   (cross-link ## Review)
```

**Gate:** every security finding is resolved or consciously accepted before `harness verify`.
