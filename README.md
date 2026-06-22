# harness-skills

Reusable **skills, workflows, and hooks** for the [harness](https://github.com/nobodyonlyc/harness)
agent coding platform. One canonical source, consumed by multiple agents
(**Claude Code**, **Codex**, **Antigravity**) and pinned per project as a **git submodule**.

## What lives here

```
harness-skills/
├── CATEGORIES.md          # the skill index + 9-phase lifecycle map
├── install.sh             # wire skills + workflows + hooks into a project, per agent
├── scripts/validate.sh    # structure linter (CI + harness verification)
├── vendor/caveman/        # nested submodule — token-optimization skill (MIT, upstream)
├── skills/                # workflow-* / plan-* / design-* / dev-* / check-* / test-* / ship-* / core-* / opt-*
├── resources/             # shared conventions (agent-tool-mapping, autonomy-mode, persona-mode, token-budget, step-gate)
├── hooks/                 # gate scripts (phase/quality/review/persona/step-gate/caveman-budget …)
└── config-templates/      # per-agent wiring snippets merged by install.sh
```

## How a project consumes it

Pin it as a submodule, then let `install.sh` project it into each agent's native location:

```bash
git submodule add git@github.com:nobodyonlyc/harness-skills.git .harness/skills-src
git submodule update --init --recursive        # --recursive also pulls vendor/caveman
bash .harness/skills-src/install.sh            # wires Claude Code / Antigravity / Codex + hooks
```

Per-agent loading (no `harness mcp serve` dependency):

| Agent | Skills / Workflows | Hooks |
|---|---|---|
| **Claude Code** | symlink `.claude/skills` → `.harness/skills-src/skills`, invoke `/<name>` | `.claude/settings.json` hooks point at `.harness/skills-src/hooks/*.sh` |
| **Antigravity** | generated `.agent/workflows/harness-*.md` adapters, invoke `/harness-*` | `preToolCall` / `session_end` events mapped to the same hook scripts |
| **Codex** | read `.harness/skills-src/skills/<name>/SKILL.md` by path | pre/post-tool hooks where supported, else gate lives in the skill via ask-user |

Update everywhere with one command, reproducibly (commit-pinned):

```bash
git submodule update --remote .harness/skills-src && bash .harness/skills-src/install.sh
```

## Design principles

- **Single source, multi-agent projection** — write a skill once; `install.sh` projects it per agent.
- **Persona-aware** — behavior branches on `user_role` (Non-Technical = requirement-level; Developer = exhaustive). See `resources/persona-mode.md`.
- **Step-gated** — every phase ends with an ask-user confirmation before advancing (`resources/step-gate.md`); `auto` mode logs the decision instead (`resources/autonomy-mode.md`).
- **Hard quality gates** — review + a requirement-driven set of tests (UT/IT/regression/e2e/perf/security) must pass before `harness verify`.
- **Token-aware** — caveman (`vendor/caveman`) compresses inter-agent prompts; long artifacts are written to files and only summaries pass between steps (`resources/token-budget.md`).

## License

Repo content: see `LICENSE`. `vendor/caveman` is MIT, upstream
[JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).
