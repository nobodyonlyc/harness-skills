---
name: opt-caveman
description: Token optimization — activate the vendored caveman skill to compress inter-agent prompts and subagent results, cutting output tokens without weakening any quality gate.
---

Wraps [`../../vendor/caveman`](../../vendor/caveman) (MIT) and applies the policy in
[../../resources/token-budget.md](../../resources/token-budget.md).

## When to activate
- **Inter-agent prompts** — orchestrator → subagent instructions and the data subagents return.
  This is the default target; it is where most wasted "politeness" tokens live.
- Trigger automatically when the `caveman-budget` hook warns that token usage is high, or proactively
  for large fan-out subagent work.

## When NOT to activate
- **User-facing output** — never compress what the user reads, unless they explicitly opt in
  (`/caveman` or "talk like caveman"). Especially never for **Non-Technical** users
  ([../../resources/persona-mode.md](../../resources/persona-mode.md)).
- **Reasoning/thinking** — caveman shrinks the mouth, not the brain; it does not touch analysis quality.

## Levels
- `lite` — drop filler, keep full sentences (safe default for inter-agent prose).
- `full` — terse telegraphic style; for bulk mechanical handoffs.
- `ultra` — maximum compression; only for high-volume low-ambiguity data passing.

## Hard rule
If compression would risk a weaker review, test, or design result, **don't** — use full prose and a
`strong` model tier ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)).
Quality outranks cost, always. Pair with artifact compaction (write long outputs to files, pass
summaries) for the biggest savings.
