---
name: dev-js-ts
description: Phase 5 implementation in JavaScript/TypeScript (Node) — language idioms, tooling, and project layout. Composes with a component skill (dev-be/dev-fe/dev-cli). Use when: the stack is Node/JS/TS, implementing a component skill in JavaScript/TypeScript, or setting JS/TS tooling and layout.
metadata:
  layer: language
  tier: mechanical
  delegates:
    - {language: typescript, label: "TypeScript", to: typescript-pro}
    - {language: javascript, label: "JavaScript (Node/browser)", to: javascript-pro}
---

## One-Liner
The JS/TS language layer (idioms, tooling, layout) that composes under a component skill — the component owns *what* to build, this owns *how* in Node.

Use **with** a component skill (e.g. `dev-be` for a Node service, `dev-fe` for a React UI) — the
component skill says *what* to build; this says *how* in JS/TS. Follow
[../../resources/conventions/typescript-node.md](../../resources/conventions/typescript-node.md).

**Delegate craft depth to the experts.** For deep type-system / async / tooling patterns load the
vendored [`typescript-pro`](../typescript-pro/SKILL.md) (TS) or [`javascript-pro`](../javascript-pro/SKILL.md)
(vanilla JS/Node), per [../../resources/expert-skills-map.md](../../resources/expert-skills-map.md).
This skill keeps the harness wiring; the expert supplies the depth.

## Setup & tooling
- TypeScript strict; ESM; the project's existing package manager (npm/pnpm/yarn) and scripts.
- Lint/format: ESLint + Prettier — must pass before review.
- Test runner: whatever the repo uses (vitest/jest); colocate `*.test.ts`.

## Idioms
- `async/await`, never floating promises; handle every rejection.
- Validate external input at boundaries (zod or equivalent); narrow `unknown`, avoid `any`.
- Errors as `Error` subclasses; no silent catch.
- Prefer pure functions + small modules; inject side effects for testability.

## Layout
- `src/` for code, `src/**/*.test.ts` for unit tests; build output ignored by git.
- Keep public API in named exports; one responsibility per module.

Hand off to `check-code-review` then the test types selected by `check-test-strategy`.
