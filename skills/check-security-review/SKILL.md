---
name: check-security-review
description: Phase 6/7 deep security review — audit a change for auth, injection, secrets, data exposure, and dependency risk, recording tracked findings. Use when: the change touches authentication/authorization, secrets, sensitive/PII data, file uploads, an external/network surface, or deserialization.
---

## One-Liner
Assume the input is hostile and the caller is unauthorized until proven otherwise — then check every
trust boundary the change crosses.

## Core Philosophy
Security defects are *missing* checks, not wrong ones — they hide in the path you didn't think about.
Work from **trust boundaries** (where untrusted data/identity enters) and apply **deny-by-default**.
This is the deep pass that `check-code-review`'s security dimension escalates to, and the proof for
the `security:` test type selected by [check-test-strategy](../check-test-strategy/SKILL.md).

**Run as a Security Reviewer role.** Spawn this pass as an independent subagent whose role is
resolved by `scripts/role-resolver.sh --phase security` (archetype `security-reviewer`, expertise
from the Stack block), and bracket it with `harness review open <id> --phase security` /
`harness review record` so review provenance is recorded for the security phase too. See
[../../resources/phase-roles.md](../../resources/phase-roles.md).

## Workflow
### Phase 1 — Map the surface
List what the change exposes: new inputs, endpoints, queries, file/network/process calls, auth checks,
data fields returned. **Gate:** every trust boundary the diff touches is listed.
### Phase 2 — Per-category audit
Walk `references/threat-checklist.md` for each boundary (authN/authZ, injection, secrets, data
exposure, deserialization, SSRF/path traversal, dependencies). **Gate:** each category is marked
checked or N/A with a reason.
### Phase 3 — Record (tracked checklist)
Findings into evidence `## Review` (same format as code review, so `review-fix-gate` enforces them):
```
- [ ] <CRITICAL> missing authz on DELETE /orders/{id} (orders.py:88) — any user deletes any order
- [x] <MAJOR> SQL built by f-string (repo.py:12) — fixed: parameterized
```
**Gate:** every finding has severity + file:line + impact.

## Examples (Bad vs Good)
```python
# BAD: trusts the client's user id → horizontal privilege escalation
order = get_order(request.json["order_id"])
# GOOD: scope to the authenticated principal
order = get_order(request.json["order_id"], owner=current_user.id)
```

## Reference Guide
| Topic | Reference | Load when |
|---|---|---|
| Threat checklist | `references/threat-checklist.md` | every security review |

## Notes
Use the **strong** tier; never downgrade a security review to save tokens. Real exploitation testing
stays within authorized scope only. Findings feed `test-security` (phase 7) for proof.
