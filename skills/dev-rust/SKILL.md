---
name: dev-rust
description: Phase 5 implementation in Rust — language idioms, tooling, and project layout. Composes with a component skill (dev-be/dev-cli/dev-batch). Use when: the stack is Rust, implementing a component skill in Rust, or setting Rust tooling (cargo, clippy) and layout.
metadata:
  layer: language
  tier: mechanical
  delegates:
    - {language: rust, to: rust-engineer}
---

## One-Liner
The Rust language layer (idioms, tooling, layout) that composes under a component skill — the component owns *what*, this owns *how* in Rust.

Use **with** a component skill (e.g. `dev-cli` for a tool, `dev-be` for a service) — the component
skill says *what* to build; this says *how* in Rust. Follow
[../../resources/conventions/rust.md](../../resources/conventions/rust.md).

**Delegate craft depth to the expert.** For ownership/lifetimes, trait design, and async (tokio)
patterns load the vendored [`rust-engineer`](../rust-engineer/SKILL.md), per
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md). This skill keeps the
harness wiring; the expert supplies the depth.

## Setup & tooling
- Cargo workspace; `cargo fmt` + `cargo clippy -- -D warnings` clean before review.
- Test: `#[cfg(test)]` unit modules + `tests/` for integration; `cargo test` green.

## Idioms
- Errors via `Result<T, E>`; use `thiserror`/`anyhow` as the repo does; avoid `unwrap()`/`expect()`
  in library code (ok in tests / `main` with context).
- Make illegal states unrepresentable with the type system; prefer borrowing over cloning.
- Keep `unsafe` out unless justified and documented; no data races (the compiler enforces, don't fight it).

## Layout
- `src/main.rs` or `src/lib.rs` + modules; `cmd`/binaries under `src/bin/` or workspace crates.

Hand off to `check-code-review` then the test types selected by `check-test-strategy`.
