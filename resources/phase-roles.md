# Phase → role matrix (the role a subagent carries at each lifecycle phase)

Subagents spawned during the 9-phase lifecycle must carry a **role**, not run as a faceless agent.
The role's *archetype* comes from the **phase**; the role's *expertise* comes from the **design**
(the machine-readable Stack block, resolved by [`experts-resolver.sh`](../scripts/experts-resolver.sh)).
So a code review on a Go backend spawns a **Go Backend Tech Lead** backed by `dev-be → dev-go →
golang-pro`, and a security pass spawns a **Security Reviewer**.

> **This table is documentation. The single source of truth is
> [`scripts/role-resolver.sh`](../scripts/role-resolver.sh)** (the `PHASE_ROLES` table). Run
> `bash scripts/role-resolver.sh --phase <p> --language <l> --component <c>` to get the exact role
> spec a host should inject into the subagent prompt. Keep this table in sync with the script.

## The matrix
| Phase | Archetype | Title shape | Mandate (summary) | Base skill |
|---|---|---|---|---|
| `design` | `architect` | `<Lang> <Component> Architect` | Challenge architecture: soundness, boundaries, scalability, trade-offs | [design-architecture](../skills/design-architecture/SKILL.md) |
| `review` | `techlead` | `<Lang> <Component> Tech Lead` | check-code-review dimensions; try to find problems, don't approve | [check-code-review](../skills/check-code-review/SKILL.md) |
| `security` | `security-reviewer` | `<Lang> <Component> Security Reviewer` | Auth, injection, secrets, data exposure, deps | [check-security-review](../skills/check-security-review/SKILL.md) |
| `qa` | `qa-engineer` | `<Lang> <Component> QA Engineer` | Run the selected test set; reproduce each failure with a test | [check-qa](../skills/check-qa/SKILL.md) |
| `code` | `implementer` | `<Lang> <Component> Implementer` | Implement per design via the expert chain; expert ≠ gate | [dev-be](../skills/dev-be/SKILL.md) (component-specific) |

`<Lang>` and `<Component>` are filled from the resolved chain (e.g. `dev-go` → Go, `dev-be` →
Backend); empty parts are dropped, so a stack with no language wrapper (e.g. Java) yields
`Backend Tech Lead`. When the Stack block does not resolve, the role still emits with an empty
expertise chain (a generic reviewer) — spawning never blocks.

## The role spec
`role-resolver.sh --phase <p> [--language/--framework/--component/--stack]` emits:
```json
{
  "phase": "review",
  "archetype": "techlead",
  "title": "Go Backend Tech Lead",
  "language": "Go",
  "component": "dev-be",
  "base_skill": "check-code-review",
  "expertise": ["dev-be", "dev-go", "golang-pro"],
  "mandate": "Apply the check-code-review dimensions ...",
  "based_on": "docs/design/architecture.md#stack",
  "independent": true
}
```

## How phases consume it
Each phase's skill reads the spec and injects it into the spawned subagent's prompt (title +
mandate + the `expertise` SKILL.md chain to load), then records review provenance via
`harness review open/record` (see [agent-tool-mapping.md](agent-tool-mapping.md) and the
review-provenance gate). `independent: true` is the standing rule that the reviewer is never the
author.
