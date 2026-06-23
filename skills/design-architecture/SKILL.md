---
name: design-architecture
description: Phase 2 system architecture — define components, boundaries, data flow, and stack, recording the choice as an ADR with a trade-off matrix plus a machine-readable Stack block. Always research the current latest LTS/stable versions before deciding; pin to them. Use when: designing a new system, choosing a stack/framework/version, defining component boundaries, recording an architecture decision.
---

Input: `docs/requirements.md`. Output: `docs/design/architecture.md`.

**Delegate craft depth to the expert.** For component/boundary design, scalability patterns, and ADR
authoring, load the vendored [`architecture-designer`](../architecture-designer/SKILL.md) (also feeds
[design-detailed](../design-detailed/SKILL.md)); see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md). This skill keeps the
trade-off-matrix + ADR gate.

## One-Liner
Pick the architecture by comparing options against the requirements in a trade-off matrix, **research
the current latest LTS version of each chosen technology**, then record the decision as an ADR plus a
machine-readable Stack block — so the *why* and the *exact versions* survive, not just the *what*.

## Core Philosophy
An unrecorded architecture decision gets re-litigated every time someone new reads the code. Compare
real options against the actual NFRs; don't default to the trendiest stack — and don't pick versions
from memory. Persona sets how much is surfaced
([../../resources/persona-mode.md](../../resources/persona-mode.md)); defaults and version rules live
in [../../resources/stack-defaults.md](../../resources/stack-defaults.md).

## Workflow
### Phase 1 — Components & flow
Define components + responsibilities, the boundaries between them, and the data flow.
**Gate:** every requirement maps to a component that owns it.

### Phase 2 — Choose the stack (trade-off matrix)
List 1–2 viable options; score against the requirements/NFRs.
- **Non-Technical:** take the conventional default for the app type from the default-stack table in
  [stack-defaults.md](../../resources/stack-defaults.md) (Rule 1), choose it, and **log** the
  rationale — do not ask.
- **Developer:** present the default + one alternative as the matrix and get approval.

**Gate (Developer):** user approved the choice. **Non-Technical:** a conventional default is chosen
and logged (not asked).

### Phase 2.5 — Research the version (latest LTS — REQUIRED, do this before recording)
Delegate to **[design-stack-research](../design-stack-research/SKILL.md)**: it makes one
`web-research` call per chosen technology, reads the official source, and writes the dedicated
artifact `docs/design/stack-versions.md` (version + channel + fetched source URL + as-of date). Then
**pin the Stack block below FROM that artifact** — copy its researched versions, do not recall them.
If the runtime has no web access, design-stack-research STOPs and asks the user.
**Gate:** `docs/design/stack-versions.md` exists with a researched version + source URL for every
chosen technology, and the Stack block pins match it.

### Phase 3 — Record the ADR + machine-readable Stack block
Write the decision + rationale + rejected alternatives **and** the Stack block to
`docs/design/architecture.md`. The Stack block is the single machine-readable source of truth that
`plan-skeleton` / `plan-tasks` / `dev-*` read (Rule 3) and the `stack-decision-gate` enforces.
**Gate:** the ADR names what was chosen, why, and what was rejected; the Stack block names language +
pinned versions + the LTS/research marker, with no placeholders.

## Output contract
```markdown
## Trade-off matrix
| Option | Fit to NFRs | Complexity | Cost | Team familiarity | Verdict |
|---|---|---|---|---|---|
| A: <stack> | … | … | … | … | chosen |
| B: <stack> | … | … | … | … | rejected: <reason> |

## ADR-001: <decision title>
- Status: accepted
- Context: <forces from requirements/NFRs>
- Decision: <what we chose>
- Consequences: <trade-offs accepted, follow-ups>
- Rejected: <option B> because <reason>

## Stack (machine-readable)
<!-- Pinned to latest LTS/stable; versions researched from official sources, not recalled. -->
- source_dir: <system-name>/   # app scaffolds into this subfolder (slug of the system name), NOT the repo root
- language: TypeScript
- runtime: Node.js 22.x (LTS "Jod"; verified current as of <date>, source nodejs.org/about/releases)
- framework: Next.js 15.x
- database: PostgreSQL 17
- package-manager: pnpm 9.x
- test-runner: Vitest 2.x
- convention: resources/conventions/typescript-node.md   # or: expert <name> when no conventions file
- lts-research: <what was checked, version support window, date>
```

## Handoff
Feeds `design-database` / `design-api` / `design-detailed`. The Stack block's `convention:` line
resolves the craft source per [stack-defaults.md](../../resources/stack-defaults.md) Rule 2: a
`../../resources/conventions/<lang>.md` guide when one exists, else the mapped vendored expert.
`plan-skeleton` pins manifests to the researched versions.
