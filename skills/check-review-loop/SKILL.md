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

## 1. Independent review — role-based, no self-review
The reviewer is not a faceless agent: resolve its **role from the design**, spawn it on the
**strong** tier, and bracket the review with CLI-recorded provenance. The author must never review
their own code.

1. **Resolve the role from the design.** Run the role-resolver against the Stack block:
   `bash .harness/skills-src/scripts/role-resolver.sh --phase review --stack docs/design/architecture.md`
   → a spec like `{title:"Go Backend Tech Lead", expertise:["dev-be","dev-go","golang-pro"],
   mandate:…}` (see [../../resources/phase-roles.md](../../resources/phase-roles.md)). The reviewer
   is a tech lead in the project's actual language/component, not a generic agent.
2. **Open provenance.** `harness review open <id> --phase review --role '<spec>'` mints a one-time
   nonce, binds the **current diff-hash**, and prints the role brief to inject.
3. **Spawn the reviewer** with the **spawn-subagents** capability
   ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)), injecting the
   role title + mandate + the `expertise` SKILL.md chain to load. It applies the
   [check-code-review](../check-code-review/SKILL.md) dimensions (correctness, security, contract,
   scope, clarity) and is prompted to **try to find problems**, not to approve.
4. **Record the verdict.** `harness review record <id> --nonce <n> --verdict clean|findings
   --findings <N>` stamps provenance bound to the reviewed diff — this is what the
   `review-provenance-gate` checks at verify.
- **Fallback:** no subagent capability → a **fresh-context** pass that sees only the diff + design
  docs (not the author's reasoning); still `open`/`record` provenance and note the fallback in the
  evidence.

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
Two complementary gates guard `harness verify <id>`:
- `review-fix-gate` blocks while any `- [ ]` remains in `## Review` (the tracked checklist proves
  *what* was found and that it was resolved).
- `review-provenance-gate` blocks unless an independent review provenance is recorded and **CURRENT**
  — its diff-hash still matches the working tree. A fix made after the review makes it **STALE** and
  re-opens the gate (re-run step 1 on the new diff). This proves an independent role reviewer
  *actually ran on this exact diff*, not just that text was written into evidence.

Pairs with `check-qa` (tests) before verify. Persona: Non-Technical gets a plain-language
"found and fixed N issues"; Developer gets the full finding trail.
