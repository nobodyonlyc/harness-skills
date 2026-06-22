# Token Budget (caveman + compaction)

Cost optimization that **never weakens a gate**. Three levers: caveman compression, artifact
compaction, and model-tier (the last is in [agent-tool-mapping](agent-tool-mapping.md)).

## 1. Caveman — ON BY DEFAULT in every workflow
[`../vendor/caveman`](../vendor/caveman) (MIT) strips politeness/narrative from output while
keeping technical content. **Standing rule:** caveman is **on by default** in every workflow
(`workflow-intake`/`bootstrap`/`feature`/`team`/`bugfix`) — apply the `opt-caveman` skill to every
inter-agent prompt and subagent result without waiting to be asked. The `caveman-activate` hook
records `caveman_mode: on` at session start; the `caveman-budget` hook escalates when usage runs
high. Scope of the rule:

- **Always apply to inter-agent prompts and subagent results** — orchestrator→subagent instructions
  and the data subagents return. This is the default target and where most wasted tokens live.
- **Do NOT apply to user-facing output** unless the user opted in (`/caveman` or "talk like
  caveman"). User communication respects the user's language and normal tone — especially for
  Non-Technical users (see [persona-mode](persona-mode.md)).
- **Never** apply to reasoning/thinking — caveman shrinks the mouth, not the brain.
- **Never** where it would weaken a gate (see Hard rule below): judgment-critical review/test/design
  prose stays full + `strong` tier.
- Levels `lite|full|ultra` trade compression for readability; `lite` is the safe default for
  inter-agent prose, `ultra` only for high-volume low-ambiguity data passing.

## 2. Compaction — keep long artifacts out of context
- Write long outputs (specs, design docs, plans, evidence, logs > ~10 lines) to **files**, not chat.
- Between steps pass **paths + a short summary**, not the full artifact. The next step reads the
  file only if it needs detail.
- Harness already routes reports/logs to `.harness/reports/` and `.harness/logs/`; follow that.

## 3. Context threshold
- `context-budget-guard` warns when the session nears the configured token threshold
  (`./harness config set context_warn_threshold <n>`, default 150000).
- On warning: checkpoint (`./harness session stop`), commit, and resume fresh — do not push past
  the threshold and lose coherence.

## Hard rule
Quality outranks cost. If compressing a prompt or downgrading a model would risk a weaker review,
test, or verify result, **don't** — use `strong` and full prose for judgment steps. The loops are
already capped for runaway protection ([autonomy-mode](autonomy-mode.md)).
