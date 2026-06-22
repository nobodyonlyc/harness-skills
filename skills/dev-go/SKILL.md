---
name: dev-go
description: Phase 5 implementation in Go — language idioms, tooling, and project layout. Composes with a component skill (dev-be/dev-cli/dev-batch).
---

Use **with** a component skill (e.g. `dev-be` for a service, `dev-cli` for a tool) — the component
skill says *what* to build; this says *how* in Go. Follow
[../../resources/conventions/go.md](../../resources/conventions/go.md).

## Setup & tooling
- Modules (`go.mod`); `gofmt` + `go vet` clean; `golangci-lint` if the repo uses it.
- Test: `_test.go`, table-driven; `go test ./...` green before review.

## Idioms
- Return `error` last; wrap with `fmt.Errorf("...: %w", err)`; never discard errors.
- Pass `context.Context` as the first arg for cancellable/timeout-bound work.
- Small, consumer-defined interfaces; accept interfaces, return structs.
- Protect shared state; no goroutine leaks (always have a stop/return path).

## Layout
- `cmd/<bin>/` for entry points, `internal/` for private packages, `pkg/` only for shared libs.

Hand off to `check-code-review` then the test types selected by `check-test-strategy`.
