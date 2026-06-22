# Codex hook wiring

Codex has no universal PreToolUse/Stop hook system equivalent to Claude Code. Two options:

1. **If your Codex runtime supports pre/post-tool hooks**, point them at the same canonical scripts:
   - before tool (shell): `.harness/skills-src/hooks/git-guard.sh`, `phase-guard.sh`,
     `persona-gate.sh`, `quality-gate.sh`, `review-gate.sh`
   - session end: `context-budget-guard.sh`, `caveman-budget.sh`, `step-gate.sh`, `session-guard.sh`

2. **If it does not**, the gates live in the skills themselves: each `workflow-*`/`check-*` skill
   already enforces the same contract via the **ask-user** capability
   (`resources/agent-tool-mapping.md`, `resources/step-gate.md`). The harness CLI also enforces
   plan/verify gates server-side regardless of agent, so no quality gate is lost.

The scripts are the single source of truth; never copy them — reference them from the submodule.
