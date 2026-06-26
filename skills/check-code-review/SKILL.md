---
name: check-code-review
description: Phase 6 code review — inspect a child-task diff across correctness, security, contract, scope, and clarity, and record tracked findings to evidence ## Review. Use when: reviewing a diff before verify, auditing a change, checking a PR, hunting bugs/security issues in changed code.
metadata:
  layer: review
  tier: judgment
  delegates:
    - {trigger: "review depth", to: code-reviewer}
---

## One-Liner
Find the real defects in *this diff* and record each as a tracked finding — presence of a review is
not the goal, a resolved finding list is.

**Delegate craft depth to the expert.** For broad-scope analysis (security classes, N+1, smells)
load the vendored [`code-reviewer`](../code-reviewer/SKILL.md) (see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)); this skill keeps the
dimensions, the tracked `## Review` checklist, and the gate.

**Run as a design-derived role.** When invoked as the Phase 6 reviewer (via
[check-review-loop](../check-review-loop/SKILL.md)), the reviewing agent carries the role resolved by
`scripts/role-resolver.sh --phase review` (e.g. a *Go Backend Tech Lead*, loading its `expertise`
chain) and its verdict is recorded with `harness review open/record` so the `review-provenance-gate`
proves an independent review ran on this diff. See
[../../resources/phase-roles.md](../../resources/phase-roles.md).

## Core Philosophy
A review that produces prose but no tracked findings is theatre: nothing forces resolution. Record
findings as checkboxes so the `review-fix-gate` can hold `verify` until each is fixed or consciously
accepted. Review the **diff**, not the whole repo — scope creep dilutes attention.

## Review dimensions (apply each; details in references/)
- **Correctness** — logic, edge cases, error handling, off-by-one, null/empty, concurrency.
- **Security** — input validation, injection, authz, secrets in code/logs, unsafe deserialization
  (deep pass: [check-security-review](../check-security-review/SKILL.md) when auth/data/external).
- **Contract fidelity** — matches `docs/design/api.md` + schema; no silent behavior drift.
- **Scope** — change stays inside the child-task (WIP=1); flag creep as a separate feature.
- **Reuse/clarity** — duplication, needless complexity (deep cleanup → `check-refactor`).

## Workflow
### Phase 1 — Context
State the diff's intent in one sentence. **Gate:** if you cannot, ask the author before reviewing.
### Phase 2 — Inspect
Walk the diff against each dimension above + `references/review-checklist.md`. Note critical issues
immediately, don't wait. **Gate:** every changed file has been read.
### Phase 3 — Record (tracked checklist)
Write findings to evidence `## Review` as checkboxes — resolution is durable and gate-checkable:
```
- [ ] <finding> (file:line, severity)        # open
- [x] <finding> (file:line) — fixed
- [x] <finding> — (accepted: <reason>)
```
If genuinely clean, write `No issues found` with a one-line justification of what was checked.
**Gate:** every finding has a file:line + severity; nothing vague.

## Examples (Bad vs Good)
```python
# BAD: query inside loop → N+1
for u in users: orders = Order.objects.filter(user=u)
# GOOD: prefetch in bulk
users = User.objects.prefetch_related("orders").all()
```
More patterns: `references/common-issues.md`.

## Reference Guide (load on demand)
| Topic | Reference | Load when |
|---|---|---|
| Review checklist | `references/review-checklist.md` | starting a review |
| Common issues (Bad/Good) | `references/common-issues.md` | spotting recurring defects |
| Report template | `references/report-template.md` | writing the `## Review` block |

## Gates & loop
`quality-gate` needs a `## Review` section; `review-gate` rejects placeholders; **`review-fix-gate`
blocks `verify` while any `- [ ]` is open**. This skill is one pass — run it inside
[check-review-loop](../check-review-loop/SKILL.md) (independent reviewer + capped fix→re-review).
Use the **strong** tier; never downgrade a review to save tokens
([../../resources/token-budget.md](../../resources/token-budget.md)). Persona: Non-Technical gets
plain-language findings, Developer gets the full list ([../../resources/persona-mode.md](../../resources/persona-mode.md)).
