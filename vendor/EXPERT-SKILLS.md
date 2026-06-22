# Vendored expert skills — provenance

Per-language/framework expert skills vendored into `skills/` to give the harness `dev-*` / `test-*`
/ `design-*` skills real craft depth. They are first-class, invocable skills; the harness skills
**delegate** to them via [`../resources/expert-skills-map.md`](../resources/expert-skills-map.md).

## Source (pinned)
- Repo: **nobodyonlyc/skills** — https://github.com/nobodyonlyc/skills
- Commit: `f6c3127a9b90cf17eaa185d61ad5f1496a440891` (branch `master`)
- Vendored: 2026-06-22

## License & attribution
Each vendored skill keeps its original `license:` / `metadata.author` frontmatter (all **MIT**).
Upstream authors are credited there (e.g. https://github.com/Jeffallan, theneoai, Anthropic). This
is a copy, not a fork — to update, re-vendor from a newer pinned commit (see
[`../scripts/vendor-experts.sh`](../scripts/vendor-experts.sh)).

## Vendored so far
The authoritative machine-checked list lives in the fenced block of
[`../resources/expert-skills-map.md`](../resources/expert-skills-map.md)
(validated by `scripts/lint-expert-map.sh`). Rollout phases: F39 (python-pro, proof) → F40
(languages) → F41 (web frameworks) → F42 (test/design/debug).
