---
name: dev-rust
description: Phase 5 implementation in Rust — language idioms, tooling, and project layout. Composes with a component skill (dev-be/dev-cli/dev-batch).
---

Use **with** a component skill (e.g. `dev-cli` for a tool, `dev-be` for a service) — the component
skill says *what* to build; this says *how* in Rust. Follow
[../../resources/conventions/rust.md](../../resources/conventions/rust.md).

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
