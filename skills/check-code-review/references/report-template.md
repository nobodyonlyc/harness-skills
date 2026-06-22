# Report Template — the `## Review` block

Write this into `docs/design-docs/<id>/evidence.md`. Findings are checkboxes so `review-fix-gate`
can enforce resolution.

```markdown
## Review
Reviewer: <independent subagent | fresh-context pass>   Dimensions: correctness, security, contract, scope, clarity

- [ ] <CRITICAL> <finding> (path:line) — <why it's wrong / impact>
- [ ] <MAJOR> <finding> (path:line)
- [x] <MINOR> <finding> (path:line) — fixed in <commit/diff>
- [x] <finding> — (accepted: <reason>, agreed with user)

Summary: <n> findings — <n> fixed, <n> accepted, 0 open.
```

Rules:
- Severity tag first (`CRITICAL`/`MAJOR`/`MINOR`) so the fix loop prioritizes.
- Every open item is `- [ ]`; the gate blocks `verify` until none remain.
- "No issues found" is valid only with a one-line note of what was actually checked.
