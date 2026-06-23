# Stack Selection — defaults, versions, and convention resolution

How the project-creation flow turns a requirement into a concrete, version-pinned technology stack.
Owned by [design-architecture](../skills/design-architecture/SKILL.md) Phase 2; the
[persona-mode](persona-mode.md) decides whether the choice is asked (Developer) or defaulted
(Non-Technical). The result is recorded as a machine-readable Stack block (see bottom) and enforced
by the `stack-decision-gate` hook.

## Rule 0 — research the current version before deciding (ALWAYS)
**Never pick a version from memory.** Knowledge is stale by construction; a release train moves and
your training cutoff lags reality, so a recalled version is wrong by default. Before recording any
stack:
1. **Call the `web-research` capability** ([agent-tool-mapping.md](agent-tool-mapping.md)) and read
   the **official source** for the **current latest LTS** (or current stable, if the technology has
   no LTS track) of every language/runtime/framework/database you are about to choose — e.g.
   nodejs.org/about/releases, python.org/downloads, go.dev/dl, postgresql.org/support/versioning, or
   the framework's releases page. This is an actual tool call, not a recollection. If the runtime has
   no web access, **STOP and ask the user** — never fill the version in from memory.
2. Pin to that **latest LTS / stable** unless a requirement forces otherwise (then log why).
3. Record each result in the dedicated artifact **`docs/design/stack-versions.md`** via
   [design-stack-research](skills/design-stack-research/SKILL.md) — version + channel + **fetched
   source URL** + as-of date — then copy the pins into the architecture Stack block. This is what the
   `stack-decision-gate` checks: `harness verify` is blocked until `stack-versions.md` exists with a
   researched version and a source URL. A text marker can be faked; a cited URL is the evidence.

"Latest LTS" beats "latest": prefer the newest version on a **long-term-support** line over a
bleeding-edge release, so the project lands on something supported, not something deprecated next
quarter. If only a rolling/stable line exists (no LTS), use the current stable and say so.

## Rule 1 — default stack by app type (Non-Technical; Developer may override)
For a Non-Technical user the agent **chooses a conventional default and logs it** — it does not ask.
These are sensible defaults; always version-pin them per Rule 0 at decision time.

| App type / signal | Default stack (version-pin per Rule 0) | Convention / expert |
|---|---|---|
| Full-stack web app | TypeScript + Next.js (React) + PostgreSQL, Node LTS | `typescript-node.md` + `nextjs-developer`/`react-expert` |
| API / backend service | Python + FastAPI + PostgreSQL | `python.md` + `fastapi-expert` |
| Backend (Node shop) | TypeScript + NestJS + PostgreSQL | `typescript-node.md` + `nestjs-expert` |
| CLI tool | Go (single static binary) | `go.md` + `golang-pro` |
| Performance / systems | Rust | `rust.md` + `rust-engineer` |
| Mobile app | Flutter (Dart) | expert `flutter-expert` |
| Data / scripting / ML | Python | `python.md` + `python-pro` |
| Static site / landing | Astro or Next.js (static export) | `typescript-node.md` + `frontend-design` |

If the request matches no row, choose the closest by primary concern (UI-heavy → web; throughput →
Go/Rust; data → Python) and **log the reasoning** in the ADR. Developer persona: present this default
plus 1 alternative as the trade-off matrix and let the user pick.

## Rule 2 — resolve the convention / craft source
The chosen stack selects how craft depth is enforced, in priority order:
1. **`resources/conventions/<lang>.md`** if it exists. Curated subset today: `go`, `python`, `rust`,
   `typescript-node`.
2. Otherwise the **vendored expert** for that stack from
   [expert-skills-map.md](expert-skills-map.md) is the convention authority (e.g. Java →
   `java-architect`, C# → `csharp-developer`, Vue → `vue-expert`). Absence of a `conventions/` file is
   **not** a blocker — the expert carries the idioms.

So a stack outside the four curated files is fully supported: `plan-skeleton` and `dev-*` follow the
mapped expert instead of a missing convention file.

## Rule 3 — record the decision machine-readably
`design-architecture` writes this block into `docs/design/architecture.md` (in addition to the prose
ADR). It is the single machine-readable source of truth for the stack; downstream skills
(`plan-skeleton`, `plan-tasks`, `dev-*`) read it instead of re-deriving the stack from prose, and the
`stack-decision-gate` parses it.

```markdown
## Stack (machine-readable)
<!-- Pinned to latest LTS/stable; versions researched from official sources, not recalled. -->
- source_dir: acme-search/   # app code lives in this subfolder (slug of the system name); harness/docs stay at repo root
- language: TypeScript
- runtime: Node.js 22.x (LTS "Jod"; verified current as of 2026-06-22, source nodejs.org/about/releases)
- framework: Next.js 15.x
- database: PostgreSQL 17
- package-manager: pnpm 9.x
- test-runner: Vitest 2.x
- convention: resources/conventions/typescript-node.md
- lts-research: Node 22 active-LTS until 2027-04; Postgres 17 current stable — checked 2026-06-22
```

**`source_dir`** is the subfolder the app is scaffolded into — a slug of the system name (e.g.
`acme-search/`), never the repo root. The harness keeps its own files (`.harness/`, `docs/`,
`AGENTS.md`, `init.sh`, `run.sh`) at the root; all application code, manifests, and tests live under
`source_dir`. `plan-skeleton` creates it; `init.sh` / `run.sh` and the test verifications operate
inside it.

Required fields the gate enforces: a `## Stack` heading, a `language:` line, at least one pinned
**version** (a concrete number), and an **LTS/research marker** (`lts` / `as of` / `verified`). No
placeholders (`TBD`, `TODO`, `<…>`, `FILL`).
