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

### Web frameworks
Pick by the project's stack. `dev-fe` consults the **frontend** rows, `dev-be` the **backend** rows.

| Harness skill | Framework / stack | Delegate to expert |
|---|---|---|
| dev-fe | React | `react-expert` |
| dev-fe | React Native (mobile) | `react-native-expert` |
| dev-fe | Angular | `angular-architect` |
| dev-fe | Vue (TS) | `vue-expert` |
| dev-fe | Vue (JS) | `vue-expert-js` |
| dev-fe | Flutter (mobile) | `flutter-expert` |
| dev-fe | visual/design polish | `frontend-design` |
| dev-fe / dev-be | Next.js (full-stack) | `nextjs-developer` |
| dev-be | Django (Python) | `django-expert` |
| dev-be | FastAPI (Python) | `fastapi-expert` |
| dev-be | Spring Boot (Java) | `spring-boot-engineer` |
| dev-be | Rails (Ruby) | `rails-expert` |
| dev-be | Laravel (PHP) | `laravel-specialist` |
| dev-be | NestJS (Node) | `nestjs-expert` |
| dev-be | ASP.NET Core (.NET) | `dotnet-core-expert` |

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
react-expert
react-native-expert
angular-architect
vue-expert
vue-expert-js
nextjs-developer
django-expert
fastapi-expert
spring-boot-engineer
rails-expert
laravel-specialist
nestjs-expert
dotnet-core-expert
flutter-expert
frontend-design
```
