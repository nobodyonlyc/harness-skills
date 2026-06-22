# Token Budget (caveman + compaction)

Cost optimization that **never weakens a gate**. Three levers: caveman compression, artifact
compaction, and model-tier (the last is in [agent-tool-mapping](agent-tool-mapping.md)).

## 1. Caveman — compress inter-agent prose
[`../vendor/caveman`](../vendor/caveman) (MIT) strips politeness/narrative from output while
keeping technical content. Policy:

- **Apply to inter-agent prompts and subagent results** — orchestrator→subagent instructions and
  the data subagents return. This is where most wasted tokens live.
- **Do NOT apply to user-facing output** unless the user opted in (`/caveman` or "talk like
  caveman"). User communication respects the user's language and normal tone — especially for
  Non-Technical users (see [persona-mode](persona-mode.md)).
- **Never** apply to reasoning/thinking — caveman shrinks the mouth, not the brain.
- The `opt-caveman` skill activates it; levels `lite|full|ultra` trade compression for readability.

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
