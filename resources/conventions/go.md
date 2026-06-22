# Convention: Go

- **Format/vet**: `gofmt` + `go vet` clean; idiomatic naming (short, clear).
- **Errors**: return `error` as the last value; wrap with `fmt.Errorf("...: %w", err)`; never discard.
- **Concurrency**: pass `context.Context` first arg for cancellable work; protect shared state; no goroutine leaks.
- **Interfaces** small and consumer-defined; accept interfaces, return structs.
- **Tests**: `_test.go`; table-driven tests; `go test ./...` green before review.
- **No secrets** in code; read from env/config.
