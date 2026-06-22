---
name: ship-release
description: Phase 9 release — cut a versioned release with a changelog and tag once features are verified. Strong-tier (judgment about version + scope).
---

Input: a set of `passing` features on the release branch.

## Produce
- **Version bump** per semver (breaking → major, feature → minor, fix → patch); justify the choice.
- **Changelog** — grouped by type (Added/Changed/Fixed/Security), human-readable, linking PRs/USs.
- **Tag** the release; attach build artifacts if applicable.

## Rules
- Only release **verified** work — every included feature is `passing` with evidence.
- A release that touches a shared/protected branch or publishes artifacts is **outward-facing**:
  confirm before pushing the tag / publishing ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- Tier: **strong** — version and scope decisions need judgment.
