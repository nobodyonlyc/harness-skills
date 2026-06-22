---
name: test-e2e
description: Phase 7 end-to-end testing — drive complete user-facing flows through the real system to confirm it works as the user experiences it. For any UI, E2E code must cover the ENTIRE system — every user-facing flow from design-ux-flow gets a spec; no flow left uncovered. Required when a user flow exists. Use when: a task delivers a user-facing end-to-end flow, validating a journey through the real UI/API, or the test-strategy selected e2e from a design-ux-flow.
---

## One-Liner
Drive the whole flow through the real system as a user would — happy path plus a key failure path —
on seeded data, not mocks. **For a UI, coverage is the whole system: every user-facing flow in
[design-ux-flow](../design-ux-flow/SKILL.md) must have an E2E spec — no flow left uncovered.**

**Activation:** required when the task delivers a **user-facing end-to-end flow**. For UI work the
bar is **full-system coverage**, not a sample of flows.

**Delegate craft depth to the experts.** For browser automation, Page Object Model, fixtures, and
flake control, load the vendored [`playwright-expert`](../playwright-expert/SKILL.md) /
[`webapp-testing`](../webapp-testing/SKILL.md) (see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)).

## Full-system coverage (the rule for UI)
1. **Enumerate every flow** from `design-ux-flow` (and every primary nav route / screen). That list
   is the coverage universe — nothing is "out of scope" without a written reason.
2. **One spec per flow.** Each flow gets a dedicated spec file driving the real UI.
3. **Per flow, cover:** the **happy path** + at least one **failure path** (invalid input / auth
   required / empty state / network error). Add boundary cases where the flow has them.
4. **Build a coverage matrix** (below) and prove it is complete — every flow row is `COVERED`.
   A flow with no spec is a coverage hole, which is a quality failure, not a token saving.

## Evidence format (REQUIRED — the `e2e-coverage-gate` enforces this)
Record the verdict **and** a coverage matrix that names a real spec file for every flow:

```
## Test
- e2e: PASS — all user flows via real UI on seeded data (happy + failure path each)

### E2E Coverage Matrix
| Flow (design-ux-flow)   | Spec file                    | Happy | Failure path           | Status  |
|-------------------------|------------------------------|-------|------------------------|---------|
| Sign up                 | e2e/signup.spec.ts           | ✓     | invalid email          | COVERED |
| Log in                  | e2e/login.spec.ts            | ✓     | wrong password         | COVERED |
| Browse catalog          | e2e/catalog.spec.ts          | ✓     | empty results          | COVERED |
| Add to cart / checkout  | e2e/checkout.spec.ts         | ✓     | declined card          | COVERED |
| Account settings        | e2e/account.spec.ts          | ✓     | unauthorized access    | COVERED |
```

The gate requires: an `e2e:` verdict line **plus** an `### E2E Coverage Matrix` table that
references at least one real spec file (`*.spec.*` / `*.cy.*` / `*_test.*` / `test_*`) and has
**every row `COVERED`**. Any row marked `MISSING` / `UNCOVERED` / `PARTIAL` / `TODO` / `—` blocks
the gate — close the hole, don't delete the row.

## Page Object Model scaffold (Playwright)
Keep flows maintainable with a page object per screen and role-based selectors:

```ts
// e2e/pages/CheckoutPage.ts
import { type Page, type Locator, expect } from '@playwright/test';
export class CheckoutPage {
  readonly placeOrder: Locator;
  readonly cardError: Locator;
  constructor(public page: Page) {
    this.placeOrder = page.getByRole('button', { name: 'Place order' });
    this.cardError  = page.getByRole('alert');
  }
  async goto() { await this.page.goto('/checkout'); }
  async pay(card: string) { await this.page.getByLabel('Card number').fill(card); await this.placeOrder.click(); }
}

// e2e/checkout.spec.ts
import { test, expect } from '@playwright/test';
import { CheckoutPage } from './pages/CheckoutPage';
test('checkout happy path places order', async ({ page }) => {
  const co = new CheckoutPage(page); await co.goto();
  await co.pay('4242424242424242');
  await expect(page).toHaveURL(/\/orders\/\w+/);
});
test('declined card surfaces an error', async ({ page }) => {
  const co = new CheckoutPage(page); await co.goto();
  await co.pay('4000000000000002');
  await expect(co.cardError).toContainText(/declined/i);
});
```

## Run
- Drive flows through the real UI/API as a user would (browser automation or full-stack HTTP).
- Use a realistic environment (seeded test data), not mocks of the system under test.
- Keep flows independent and idempotent; clean up created state. Enable trace/screenshot on failure.

## Record
Record the verdict, the coverage matrix, and artifacts (screenshots/traces written to files) in
evidence `## Test`; this is the `e2e:` verification. E2E is the slowest tier — run after unit +
integration are green.

**Gate:** every user-facing flow passes happy + a failure path end-to-end, **and** the coverage
matrix shows every flow `COVERED` (after UT + IT green).
