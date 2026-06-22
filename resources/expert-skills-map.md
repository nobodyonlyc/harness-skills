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
| dev-js-ts | TypeScript | `typescript-pro` |
| dev-js-ts | JavaScript (Node/browser) | `javascript-pro` |
| dev-go | Go | `golang-pro` |
| dev-rust | Rust | `rust-engineer` |
| dev-be / dev-cli (+ language) | Java | `java-architect` |
| dev-be / dev-cli (+ language) | C++ | `cpp-pro` |
| dev-be / dev-cli (+ language) | C# / .NET | `csharp-developer` |
| dev-be / dev-cli (+ language) | Kotlin | `kotlin-specialist` |
| dev-be / dev-fe (+ language) | Swift | `swift-expert` |
| dev-be (+ language) | PHP | `php-pro` |
| dev-db / dev-be | SQL (query/schema craft) | `sql-pro` |

> Languages without a dedicated `dev-<lang>` wrapper (Java, C++, C#, Kotlin, Swift, PHP, SQL) have
> no harness language skill — invoke the expert **directly** under the relevant component skill
> (`dev-be`/`dev-cli`/`dev-db`/…), which still owns the gates.

## Vendored experts (machine-checked by scripts/lint-expert-map.sh)
Every name below must resolve to `skills/<name>/SKILL.md`. This fenced block is the single source
the lint parses — keep it in sync with the table above as phases land.

```text
python-pro
typescript-pro
javascript-pro
golang-pro
rust-engineer
java-architect
cpp-pro
csharp-developer
kotlin-specialist
swift-expert
php-pro
sql-pro
```
