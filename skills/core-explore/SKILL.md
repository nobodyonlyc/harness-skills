---
name: core-explore
description: Read-only exploration — locate code, files, and conventions across the codebase and return conclusions, not file dumps. Fast, single-agent.
---

Goal: $ARGUMENTS

## Do
- Search broadly (by name, content, structure) to **locate** the relevant code/files.
- Read only the excerpts needed to answer; do not dump whole files into context
  ([../../resources/token-budget.md](../../resources/token-budget.md)).
- Return **conclusions** — where things live, how they connect, the naming convention — with
  `file:line` references.

## Rules
- **Read-only.** Make no edits; this skill locates and reports.
- For a true multi-location sweep, fan out subagents (`spawn-subagents`,
  [../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)) and synthesize.
- Hand findings to `core-explain`, `core-fix`, or a workflow as needed.
