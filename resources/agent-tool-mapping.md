# Agent Tool Mapping

Skills name **capabilities**; each agent maps them to a concrete tool. When a skill says "use
the *ask-user* capability", use whichever your runtime exposes.

| Capability | What it does | Claude Code | Codex | Antigravity |
|---|---|---|---|---|
| **ask-user** | Ask a question / get explicit confirmation at a gate | `AskUserQuestion` (use `options`) | `ask_question` with choices | interactive choice prompt |
| **spawn-subagents** | Run independent sub-tasks in parallel | `Agent` / `Task` | `invoke_subagent` | sub-agent / task spawn |
| **generate-image** | Produce a mockup/asset image | image tool if present, else static HTML/CSS mockup | same fallback | same fallback |
| **web-research** | Fetch current facts from the live web (latest LTS/stable versions, release dates, official docs) | `WebSearch` + `WebFetch` | web/search tool | browser / fetch tool |

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
