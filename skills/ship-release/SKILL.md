---
name: ship-release
description: Phase 9 release — cut a versioned release with a changelog and tag once features are verified. Strong-tier (judgment about version + scope). Use when: cutting a versioned release, choosing a semver bump, writing a changelog, or tagging/publishing verified features.
---

## One-Liner
Release only verified work: choose the semver bump from what actually changed, write a grouped
changelog, and treat tag-push/publish as outward-facing — confirm before it leaves the machine.

Input: a set of `passing` features on the release branch.

## Produce
- **Version bump** per semver (breaking → major, feature → minor, fix → patch); justify the choice.
- **Changelog** — grouped by type (Added/Changed/Fixed/Security), human-readable, linking PRs/USs.
- **Tag** the release; attach build artifacts if applicable.

**Gate:** every included feature is `passing` with evidence, and the version bump is justified
against the actual changes before the tag is created.

## Changelog template
```markdown
## v<MAJOR.MINOR.PATCH> — <date>
### Added    — <feature> (US <id> / #PR)
### Changed  — <change>
### Fixed    — <fix>
### Security — <fix>   (call out explicitly)
```

## Rules
- Only release **verified** work — every included feature is `passing` with evidence.
- A release that touches a shared/protected branch or publishes artifacts is **outward-facing**:
  confirm before pushing the tag / publishing ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)).
- Tier: **strong** — version and scope decisions need judgment.

**Gate:** tag-push / artifact publish is **confirmed with the user** (outward-facing) before it happens.
