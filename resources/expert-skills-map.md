# Expert-skills map (the bridge)

The harness `dev-*` / `test-*` / `design-*` skills are the **orchestration spine** — persona,
step-gate, conventions, evidence, handoff, gates. They are intentionally thin on per-language and
per-framework craft. That depth lives in **vendored expert skills** (see
[`../vendor/EXPERT-SKILLS.md`](../vendor/EXPERT-SKILLS.md), all MIT).

## How to use this map
When a harness skill runs against a concrete stack, **delegate the craft** to the matching expert:
load and follow `skills/<expert>/SKILL.md` for idioms, tooling, and patterns, while the harness
skill keeps owning *what* to build and the gates. The expert never replaces a quality gate.

| Harness skill | Stack / trigger | Delegate to expert |
|---|---|---|
| dev-python | Python | `python-pro` |

## Vendored experts (machine-checked by scripts/lint-expert-map.sh)
Every name below must resolve to `skills/<name>/SKILL.md`. This fenced block is the single source
the lint parses — keep it in sync with the table above as phases land.

```text
python-pro
```
