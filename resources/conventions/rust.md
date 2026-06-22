# Convention: Rust

- **Format/lint**: `cargo fmt` + `cargo clippy -- -D warnings` clean before review.
- **Errors**: `Result<T, E>`; `thiserror` for library errors, `anyhow` for app/bin; avoid
  `unwrap()`/`expect()` in library paths (acceptable in tests and `main` with a message).
- **Ownership**: prefer borrowing over cloning; make illegal states unrepresentable via the type system.
- **Unsafe**: avoid; if required, isolate, document the invariant, and test it.
- **Concurrency**: rely on `Send`/`Sync` + the borrow checker; no data races; use channels/`Arc<Mutex<>>` as fits.
- **Tests**: `#[cfg(test)]` unit modules + `tests/` for integration; `cargo test` green before review.
- **No secrets** in code; read from env/config.
