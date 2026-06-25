# Expert-skills map (the bridge)

The harness `dev-*` / `test-*` / `design-*` skills are the **orchestration spine** — persona,
step-gate, conventions, evidence, handoff, gates. They are intentionally thin on per-language and
per-framework craft. That depth lives in **vendored expert skills** (see
[`../vendor/EXPERT-SKILLS.md`](../vendor/EXPERT-SKILLS.md), all MIT).

## How to use this map
When a harness skill runs against a concrete stack, **delegate the craft** to the matching expert:
load and follow `skills/<expert>/SKILL.md` for idioms, tooling, and patterns, while the harness
skill keeps owning *what* to build and the gates. The expert never replaces a quality gate.

The stack itself is chosen and version-pinned by `design-architecture` and recorded in the
machine-readable Stack block; **[stack-defaults.md](stack-defaults.md) Rule 2** resolves the craft
source: a `conventions/<lang>.md` file (curated subset: go/python/rust/typescript-node) when one
exists, otherwise the mapped expert below is the convention authority. A stack with no `conventions/`
file is therefore fully supported.

> **This map is GENERATED — do not hand-edit the tables below.** The single source of truth is the
> `metadata.delegates` frontmatter of each harness skill. Change the frontmatter, then run
> `scripts/gen-expert-map.sh --write`; `scripts/lint-expert-map.sh` fails if the two drift.
> `dev-fe` consults the **frontend** rows, `dev-be` the **backend** rows.

> Languages without a dedicated `dev-<lang>` wrapper (Java, C++, C#, Kotlin, Swift, PHP, SQL) have
> no harness language skill — invoke the expert **directly** under the relevant component skill
> (`dev-be`/`dev-cli`/`dev-db`/…), which still owns the gates.

<!-- GENERATED:START — source of truth is skill frontmatter (metadata.delegates); run scripts/gen-expert-map.sh --write -->

### Languages
| Harness skill | Language / stack | Delegate to |
|---|---|---|
| `dev-be` | C# | `csharp-developer` |
| `dev-be` | C++ | `cpp-pro` |
| `dev-be` | Java | `java-architect` |
| `dev-be` | Kotlin | `kotlin-specialist` |
| `dev-be` | PHP | `php-pro` |
| `dev-db` | SQL (query/schema craft) | `sql-pro` |
| `dev-fe` | Swift | `swift-expert` |
| `dev-go` | Go | `golang-pro` |
| `dev-js-ts` | JavaScript (Node/browser) | `javascript-pro` |
| `dev-js-ts` | TypeScript | `typescript-pro` |
| `dev-python` | Python | `python-pro` |
| `dev-rust` | Rust | `rust-engineer` |

### Web frameworks
| Harness skill | Framework / stack | Delegate to |
|---|---|---|
| `dev-be` | ASP.NET Core (.NET) | `dotnet-core-expert` |
| `dev-be` | Django (Python) | `django-expert` |
| `dev-be` | FastAPI (Python) | `fastapi-expert` |
| `dev-be` | Laravel (PHP) | `laravel-specialist` |
| `dev-be` | NestJS (Node) | `nestjs-expert` |
| `dev-be` | Next.js (full-stack) | `nextjs-developer` |
| `dev-be` | Rails (Ruby) | `rails-expert` |
| `dev-be` | Spring Boot (Java) | `spring-boot-engineer` |
| `dev-fe` | Angular | `angular-architect` |
| `dev-fe` | Flutter (mobile) | `flutter-expert` |
| `dev-fe` | React | `react-expert` |
| `dev-fe` | React Native (mobile) | `react-native-expert` |
| `dev-fe` | visual/design polish | `frontend-design` |
| `dev-fe` | Vue (JS) | `vue-expert-js` |
| `dev-fe` | Vue (TS) | `vue-expert` |

### Test / design / debug
| Harness skill | Trigger | Delegate to |
|---|---|---|
| `check-code-review` | review depth | `code-reviewer` |
| `design-api` | endpoint/contract design | `api-designer` |
| `design-architecture` | system & component design | `architecture-designer` |
| `test-e2e` | browser/UI end-to-end | `playwright-expert` |
| `test-e2e` | browser/UI end-to-end (app-level) | `webapp-testing` |
| `test-unit` | strict TDD cadence (red-green) | `tdd-workflow` |
| `test-unit` | test design | `test-master` |
| `workflow-bugfix` | root-cause / debugging | `debugging-wizard` |
| `workflow-bugfix` | root-cause / debugging (six-phase) | `debug-diagnose` |

## Vendored experts (generated; machine-checked by scripts/lint-expert-map.sh)
Every name below resolves to `skills/<name>/SKILL.md`. This fenced block is the single
source the lint parses; it is generated from the `delegates` frontmatter above.

```text
angular-architect
api-designer
architecture-designer
code-reviewer
cpp-pro
csharp-developer
debug-diagnose
debugging-wizard
django-expert
dotnet-core-expert
fastapi-expert
flutter-expert
frontend-design
golang-pro
java-architect
javascript-pro
kotlin-specialist
laravel-specialist
nestjs-expert
nextjs-developer
php-pro
playwright-expert
python-pro
rails-expert
react-expert
react-native-expert
rust-engineer
spring-boot-engineer
sql-pro
swift-expert
tdd-workflow
test-master
typescript-pro
vue-expert
vue-expert-js
webapp-testing
```
<!-- GENERATED:END -->
