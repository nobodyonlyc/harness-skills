# Skill Depth Standard

Thin skills (a few bullet points) under-specify the work, so **weaker models drift or skip steps**.
A skill on the **deep** bar is structured enough that any model can execute it the same way. This is
the standard for the backbone skills (review, debug, test, security, BA, design); breadth/mechanical
skills may stay lighter.

## The deep-skill bar (what `scripts/lint-depth.sh` checks)
1. **Triggers** — frontmatter `description` contains a `Use when:` clause listing concrete situations,
   so the skill fires for the right prompts.
2. **One-Liner** — a `## One-Liner` (or "One-Liner") capturing the core idea in one sentence.
3. **Gates** — at least one explicit **Gate** per phase ("**Gate:** you have X") so progress is
   checkable, not vibes.
4. **On-demand depth** — a `references/` subdirectory with detail files **or** a worked
   example/output template inline, so the skill stays scannable while detail is one click away.

## Recommended full template
```markdown
---
name: <name>
description: <what it does>. Use when: <situation 1>, <situation 2>, <situation 3>.
---

## One-Liner
<one sentence: the core idea / the critical insight>

## Core Philosophy   (optional but valued)
<the anti-pattern this skill prevents; why the naive approach fails>

## Workflow (phases)
### Phase 1 — <name>
<steps>
**Gate:** <the concrete condition that must hold before the next phase>
### Phase 2 — …

## Examples (Bad vs Good)   (for code-touching skills)
```<lang>
# BAD: <why>
# GOOD: <why>
```

## Output template   (for skills that produce an artifact)
<the exact shape of the deliverable>

## Reference Guide   (load on demand)
| Topic | Reference | Load when |
|---|---|---|
| … | references/<file>.md | … |

## Persona / Gate / Token notes
<links to persona-mode, step-gate, token-budget as relevant>
```

## Rules
- Keep the SKILL.md **scannable**; push long checklists/examples into `references/` (token-budget).
- Every phase ends in a **Gate**; weak models need the explicit checkpoint, not an implied one.
- Prefer **Bad vs Good** pairs over prose for code rules — they transfer across model sizes.
- The standard is **opt-in per skill** (enforced via the skill's harness verification calling
  `lint-depth.sh <skill>`), so lightweight skills are not forced to bloat.
