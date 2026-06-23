---
name: design-stack-research
description: Phase 2 stack version research — for every technology in the chosen stack, web-research the current latest LTS/stable from the official source and record it to docs/design/stack-versions.md (version + channel + source URL + as-of date). Use when: pinning stack versions before architecture is finalized, replacing recalled versions with researched ones, or producing the version evidence the stack gate requires.
---

## One-Liner
Versions are facts that go stale — never recall them. For each technology the architecture chose,
call the **web-research** capability, read the official source, and write the result to a dedicated,
checkable artifact. The architecture Stack block then pins **from this file**, not from memory.

Input: the candidate technologies from [design-architecture](../design-architecture/SKILL.md)
(language, runtime, framework, database, major libraries). Output: `docs/design/stack-versions.md`.

## Procedure
1. **List the technologies** to pin: every language / runtime / framework / database / major library
   the architecture selected.
2. **Research each — one `web-research` call per technology**
   ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)). Read the
   **official source** (e.g. nodejs.org, python.org, go.dev, postgresql.org, the framework's releases
   page). Prefer the current **latest LTS**; if there is no LTS line, the current **stable**. This is
   a real tool call — a version recalled from training memory is stale by default. If the runtime has
   **no web access**, STOP and ask the user for the current version (ask-user) — do not guess.
3. **Record** each result: one row + one machine-readable line per technology, carrying the exact
   version, the channel (LTS / stable), the **source URL actually fetched**, and the as-of date.

## Output template (docs/design/stack-versions.md)
```markdown
# Stack Versions (researched — not recalled)

> One web-research call per technology; each row cites the official source URL fetched and the date.

| Technology | Channel | Pinned version | Source URL (fetched) | As of |
|---|---|---|---|---|
| Node.js    | LTS    | 22.x  | https://nodejs.org/en/about/previous-releases  | 2026-06-23 |
| PostgreSQL | stable | 17.x  | https://www.postgresql.org/support/versioning/ | 2026-06-23 |

## Machine-readable
- node | 22.x | lts | https://nodejs.org/en/about/previous-releases | 2026-06-23
- postgres | 17.x | stable | https://www.postgresql.org/support/versioning/ | 2026-06-23
```

## Gate
Every chosen technology has a row with a concrete version, a channel, an `https://` source URL that
was actually fetched, and an as-of date — no placeholders, no bare names.
[design-architecture](../design-architecture/SKILL.md) copies these pins into its Stack block; the
`stack-decision-gate` blocks `harness verify` until `docs/design/stack-versions.md` exists and
carries a researched version with a source URL. Step-gate; write to file.
