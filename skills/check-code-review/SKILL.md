---
name: check-code-review
description: Phase 6 code review — review a child-task diff for correctness, security, and scope, and record real findings to the feature's evidence ## Review section (a hard gate).
---

Input: the child-task diff. Output: findings written to `docs/design-docs/<id>/evidence.md` `## Review`.

## Review dimensions
- **Correctness** — logic, edge cases, error handling, off-by-one, null/empty, concurrency.
- **Security** — input validation, injection, authz checks, secrets in code/logs, unsafe deserialization.
- **Contract fidelity** — matches `docs/design/api.md` + schema; no silent behavior drift.
- **Scope** — change stays inside the child-task (WIP=1); flag creep as a separate feature.
- **Reuse/clarity** — obvious duplication or needless complexity (deep cleanup is `check-refactor`).

## Record (hard gate)
Write **real findings** to evidence `## Review` — each with file:line and severity. If genuinely
clean, write `No issues found` **with a one-line justification of what was checked**. The
`review-gate` hook rejects placeholder/empty/`N/A` review sections, and `quality-gate` blocks
`harness verify` without a `## Review` section.

## Persona
- **Non-Technical** — summarize findings in plain language ("found a case where X could fail"); fix before proceeding.
- **Developer** — full technical findings list.

## Gate
Confirmed findings must be addressed (or consciously accepted with rationale) before the
`test-*` phase and `harness verify`. Use **strong** model tier — never downgrade a review to save tokens.
