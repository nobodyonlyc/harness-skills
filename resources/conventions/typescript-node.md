# Convention: TypeScript / Node

- **Strict mode** on (`"strict": true`); no implicit `any`; prefer `unknown` over `any`.
- **ESM** modules; named exports over default exports.
- **Errors**: throw `Error` subclasses; never reject with strings; no silent catch.
- **Async**: `async/await`, not raw promise chains; handle every `await` failure path.
- **Validation** at boundaries (zod or equivalent) for external input.
- **Lint/format**: ESLint + Prettier; code must pass before review.
- **Tests**: colocate `*.test.ts`; unit with the test runner the project already uses (vitest/jest).
- **No secrets** in code or logs; read from env/config.
