---
name: opt-caveman
description: Token optimization — activate the vendored caveman skill to compress inter-agent prompts and subagent results, cutting output tokens without weakening any quality gate. Use when: compressing inter-agent prompts or subagent results, a long-running run is burning tokens, or trimming handoff notes without losing meaning.
---

## One-Liner
Compress the words between agents, never the rigor — cut tokens in prompts/handoffs/results while every quality gate stays fully intact.

Wraps [`../../vendor/caveman`](../../vendor/caveman) (MIT) and applies the policy in
[../../resources/token-budget.md](../../resources/token-budget.md).

## When to activate
- **On by default in every workflow** — `workflow-intake`/`bootstrap`/`feature`/`team`/`bugfix` apply
  this skill to every **inter-agent prompt** and **subagent result** as a standing rule (see
  [../../resources/token-budget.md](../../resources/token-budget.md)). The `caveman-activate` hook
  records `caveman_mode: on` at session start.
- This is the default target; it is where most wasted "politeness" tokens live.
- The `caveman-budget` hook only *escalates* (suggests a stronger level) when token usage runs high —
  it is not the trigger; caveman is already on.

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
