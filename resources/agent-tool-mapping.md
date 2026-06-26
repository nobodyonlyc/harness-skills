# Agent Tool Mapping

Skills name **capabilities**; each agent maps them to a concrete tool. When a skill says "use
the *ask-user* capability", use whichever your runtime exposes.

| Capability | What it does | Claude Code | Codex | Antigravity |
|---|---|---|---|---|
| **ask-user** | Ask a question / get explicit confirmation at a gate | `AskUserQuestion` (use `options`) | `ask_question` with choices | interactive choice prompt |
| **spawn-subagents** | Run independent sub-tasks; for review/QA phases the subagent carries a **design-derived role** + records **review provenance** (see below) | `Agent` / `Task` | `invoke_subagent` | sub-agent / task spawn |
| **generate-image** | Produce a mockup/asset image | image tool if present, else static HTML/CSS mockup | same fallback | same fallback |
| **web-research** | Fetch current facts from the live web (latest LTS/stable versions, release dates, official docs) | `WebSearch` + `WebFetch` | web/search tool | browser / fetch tool |

## spawn-subagents: carry a design-derived role + record provenance
A spawned reviewer/tester is **never a faceless agent**. At each judgment phase, resolve its role
from the design and bracket its work with provenance:

1. **Role from the design.** `bash .harness/skills-src/scripts/role-resolver.sh --phase <design|review|security|qa> --stack docs/design/architecture.md`
   returns a role spec (title, archetype, `expertise` SKILL.md chain, mandate) derived from the
   Stack block — e.g. a *Go Backend Tech Lead* for a Go review. Inject the title + mandate + the
   expertise chain into the subagent prompt. See [phase-roles.md](phase-roles.md).
2. **Provenance, CLI-recorded.** `harness review open <id> --phase <p> --role '<spec>'` mints a
   nonce + binds the current diff-hash; the reviewer (which **must not be the author**) does the
   work; `harness review record <id> --nonce <n> --verdict clean|findings --findings <N>` stamps it.
   The `review-provenance-gate` then blocks `harness verify` unless the provenance is **CURRENT**
   (diff-hash matches the working tree) — so a review cannot be faked by writing into evidence.md,
   and a fix made after the review (STALE) re-opens the gate.

**Fallback:** no subagent capability → a fresh-context pass seeing only the diff + design docs;
still `open`/`record` provenance and note the fallback. The role resolver degrades to a generic role
when the stack is unresolved — spawning never blocks.

## ask-user: prefer click-select options
When a question has a **discrete answer set** — yes/no, "which approach", approve/revise, pick
from a list — present **selectable options the user clicks**, never free text. Mark the
recommended option `(recommended)`. Use free text only for genuinely open answers ("describe
your project idea"). Every runtime still lets the user type past the options.

## web-research: fetch, never recall
When a skill needs a fact that goes stale — most importantly the **current latest LTS/stable
version** of a language/runtime/framework/database — you **must** actually call the **web-research**
capability and read the official source. A model's training memory is stale by construction; a
version recalled from memory is wrong by default. Record the **exact source URL you fetched** and the
date. **Fallback:** if the runtime genuinely has no web access, **STOP and ask the user** (ask-user)
for the current version — do **not** fill it in from memory.

## Model-tier (cost optimization)
Pass a **tier** when spawning a subagent so mechanical work does not burn a strong model. Tiers
are abstract (not model names) so they map across runtimes and do not go stale:

| Tier | Use for | Claude Code | Others |
|---|---|---|---|
| **fast** | Mechanical, low-judgment: run tests/lint, file ops, commit messages, formatting | `Agent(model: "haiku")` | cheapest capable model |
| **strong** (default) | Judgment: design, planning, review, QA, security, orchestration | session model | default model |

Default tier per group is in [../CATEGORIES.md](../CATEGORIES.md). **When in doubt, use `strong`** —
saving tokens must never weaken a review/test/verify gate (see [token-budget](token-budget.md)).

## Rules
- If a runtime lacks a capability (e.g. **generate-image**), use the fallback — never block.
- A **hard gate** means: use **ask-user** and get explicit approval before continuing — unless the
  run is `auto`, where the gate becomes a logged decision (see [autonomy-mode](autonomy-mode.md)).
  The always-stop list in that doc overrides every mode.
- Persona changes *how much* you ask, not *whether* gates exist — see [persona-mode](persona-mode.md).
