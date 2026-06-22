---
name: check-review-loop
description: Phase 6 review-fix loop — run an independent (adversarial) reviewer, track each finding as a checklist in evidence, then loop fix -> re-review until every finding is resolved. The review counterpart of check-qa. Use when: a child-task diff is coded and needs review before verify, driving review findings to closure, the Phase 6 review gate, or any change that must not self-review.
---

## One-Liner
Review is a converging loop, not a one-shot pass: an independent reviewer files findings as a
tracked checklist, and the gate stays shut until every `- [ ]` is fixed or consciously accepted.

Input: a coded child-task diff. Output: a `## Review` section in `docs/design-docs/<id>/evidence.md`
where **every finding is resolved** (`[x]`), and the code fixed accordingly.

This is to **review** what [check-qa](../check-qa/SKILL.md) is to **tests**: a tracked, capped,
converging loop — not a one-shot pass.

## 1. Independent review (no self-review)
Spawn an **independent reviewer** with the **spawn-subagent** capability
([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)) on the **strong**
tier — the author must not review their own code. The reviewer applies the
[check-code-review](../check-code-review/SKILL.md) dimensions (correctness, security, contract,
scope, clarity) and is prompted to **try to find problems**, not to approve.
- If the runtime has no subagent capability, fall back to a **fresh-context** review pass that only
  sees the diff + design docs (not the author's reasoning) — document the fallback in the evidence.

## 2. Record findings as a tracked checklist
Write each finding to evidence `## Review` as a checkbox so its resolution is durable and gate-checkable:
```
## Review
- [ ] <finding> (file:line, severity)        # open — must be resolved
- [x] <finding> (file:line) — fixed in <commit/diff>
- [x] <finding> — (accepted: <reason>)        # consciously accepted, with rationale
```
`- [ ]` = open · `- [x]` = fixed **or** consciously accepted (reason required). "No issues found"
(with a one-line justification of what was checked) is valid when the reviewer is genuinely clean.

## 3. Fix -> re-review loop
1. For each `- [ ]` finding: make the **minimal fix** (or mark `- [x] (accepted: reason)` with the
   user's agreement), updating the checkbox.
2. **Re-run the independent review** on the new diff — a fix can introduce a new issue.
3. Repeat until **no `- [ ]` remains**.

## 4. Cap & escalation
Cap at 3–5 iterations. If findings keep reopening after the cap, **stop and ask-user** with the
open list and a hypothesis — never mark a finding resolved without actually addressing it, and never
delete a finding to pass the gate.

## Gate
The `review-fix-gate` hook blocks `harness verify <id>` while any `- [ ]` remains in `## Review`.
Pairs with `check-qa` (tests) before verify. Persona: Non-Technical gets a plain-language
"found and fixed N issues"; Developer gets the full finding trail.
