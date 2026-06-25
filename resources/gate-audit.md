# Gate audit — no model self-evaluation

**Principle.** A gate's pass/fail must be computed by a *script reading artifacts* — test/lint exit
codes, evidence files, command strings, git state, token counts — **never** by the model judging its
own work. The author-model that produced a change must not also be the authority that grades it.

Every `hooks/*.sh` is classified at its head with a machine-checked tag:

```
# gate-audit: <mechanical|judgment|advisory> — <decision basis / routing>
```

`scripts/lint-no-self-eval-gates.sh` (the frozen verification) enforces this:
- **completeness** — every hook carries exactly one valid tag;
- **mechanical** — blocks (`exit 1`/`exit 2`) AND reads an artifact (file/`grep`/`awk`/path,
  `$COMMAND`/`CLAUDE_TOOL_INPUT`, or an exit-code read);
- **judgment** — declares `tier=judgment` AND a routing word, so the chokepoint is explicit/escalated;
- **advisory** — never blocks (nudge/helper only);
- **no-self-eval** — no gate gates a decision on a self-affirmation phrase
  (`looks good`/`lgtm`/`i confirm`/`self-assess`/…).

The header tags are the source of truth (co-located with code, cannot drift); this table is the
narrative the lint backs.

## Classification (19 gates)

### Mechanical — decision read from an artifact, blocks (11)
| Gate | Decision basis (artifact) | Blocks |
|---|---|---|
| `git-guard` | `$COMMAND` + current git branch | force-push to main/master |
| `phase-guard` | `docs/design-docs/<id>/plan.md` (presence/content/placeholders) | `harness start` |
| `quality-gate` | `evidence.md` has `## Test` + `## Review` | `harness verify` |
| `review-gate` | `evidence.md` `## Review` length / placeholders | `harness verify` |
| `review-fix-gate` | count of open `- [ ]` findings in `## Review` | `harness verify` |
| `it-testcase-gate` | integration test-case table (Steps/Expected + PASS/FAIL row) | `harness verify` |
| `e2e-coverage-gate` | E2E coverage matrix (spec files, no uncovered flow) | `harness verify` |
| `test-type-coverage-gate` | `## Test` verdict lines all green | `harness verify` |
| `stack-decision-gate` | `architecture.md` Stack block + `stack-versions.md` source URLs | `harness verify` |
| `persona-gate` | `.harness/context.json` `user_role` | `harness start` (HARD mode) |
| `context-budget-guard` | token count from trace/transcript | end-of-turn past hard threshold |

### Judgment — irreducible, routed (NOT self-eval) (1)
| Gate | Why it cannot be mechanical | Routed to |
|---|---|---|
| `step-gate` | "is this step satisfactory to advance" is an inherent judgment, not derivable from an artifact | the **user** (gated mode) or a **logged decision** (auto mode) — `tier=judgment` |

`step-gate` is the single judgment chokepoint. It is **not** the model grading its own work: the
authority is the user (or, where automated, a recorded decision that a stronger reviewer can audit).

### Advisory — never blocks; nudge/helper only (7)
`task-state-guard`, `session-guard`, `caveman-budget`, `caveman-activate`, `notify`,
`expert-inject`, `antigravity-hook` (adapter; the wrapped gate owns the decision).

## Finding
No gate in the tree decides pass/fail from a model self-affirmation. The 11 enforcement gates are all
mechanical; the only judgment is `step-gate`, correctly tagged and routed. The lint locks this in and
fails on regression (an untagged hook, an advisory that blocks, a mechanical that never blocks, a
judgment without `tier=judgment`, or any self-affirmation phrase used in a decision).
