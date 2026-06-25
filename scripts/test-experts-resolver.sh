#!/usr/bin/env bash
# FROZEN verification for F47 — the deterministic experts skill-chain resolver.
#
# Asserts a table of (args) -> expected chain over every resolution branch, plus the cross-cutting
# guarantees: FALLBACK paths exist on disk, the resolver is DETERMINISTIC, and unknown input fails
# loud (non-zero) rather than guessing.
#
# Usage: bash scripts/test-experts-resolver.sh
# Exit 0 = all cases pass; exit 1 otherwise.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
R="scripts/experts-resolver.sh"
[ -x "$R" ] || { echo "test-experts-resolver: missing/!executable $R" >&2; exit 1; }

fail=0
pass=0

# expect_names "<description>" "<expected newline-joined names>" -- <resolver args...>
expect_names() {
  local desc="$1" expected="$2"; shift 2
  local got
  got="$(bash "$R" "$@" --format names 2>/dev/null)"
  if [ "$got" = "$expected" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL: $desc" >&2
    echo "  args    : $*" >&2
    echo "  expected: $(echo "$expected" | tr '\n' ' ')" >&2
    echo "  got     : $(echo "$got" | tr '\n' ' ')" >&2
    fail=1
  fi
}

# --- 1. Resolution branches ----------------------------------------------------------------
# language-with-wrapper backend: component + wrapper + expert
expect_names "go backend" "dev-be
dev-go
golang-pro" --language go --component be

# framework + language under a backend component (django is python)
expect_names "django (python) backend" "dev-be
dev-python
django-expert" --language python --framework django --component be

# frontend framework + language
expect_names "react+ts frontend" "dev-fe
dev-js-ts
react-expert" --language typescript --framework react --component fe

# language WITHOUT a dedicated wrapper -> chain has no language line
expect_names "java + spring-boot (no wrapper)" "dev-be
spring-boot-engineer" --language java --framework spring-boot --component be

# bare language-without-wrapper, no framework -> component defaults, expert from language row
expect_names "bare java (default component)" "dev-be
java-architect" --language java

# CLI component reuses the language wrapper + expert
expect_names "go cli" "dev-cli
dev-go
golang-pro" --language go --component cli

# component inferred from the framework when --component is omitted
expect_names "react infers fe" "dev-fe
react-expert" --framework react

# rust backend
expect_names "rust backend" "dev-be
dev-rust
rust-engineer" --language rust --component be

# db component + sql (sql has no wrapper)
expect_names "sql under db" "dev-db
sql-pro" --language sql --component db

# case-insensitive flag values resolve identically
expect_names "case-insensitive Go" "dev-be
dev-go
golang-pro" --language Go --component be

# --- 2. Stack-block parsing equals flag resolution -----------------------------------------
tmp="$(mktemp -d)"
cat > "$tmp/architecture.md" <<'EOF'
# Architecture
## Stack (machine-readable)
- source_dir: demo/
- language: TypeScript
- runtime: Node.js 22.x (LTS "Jod")
- framework: Next.js 15.x
- database: PostgreSQL 17
## Handoff
EOF
expect_names "stack block: ts + next.js" "dev-be
dev-js-ts
nextjs-developer" --stack "$tmp/architecture.md" --component be

cat > "$tmp/a2.md" <<'EOF'
## Stack (machine-readable)
- language: Java
- framework: Spring Boot 3.x
EOF
expect_names "stack block fuzzy: spring boot" "dev-be
spring-boot-engineer" --stack "$tmp/a2.md" --component be

# --- 3. FALLBACK paths exist on disk -------------------------------------------------------
table_out="$(bash "$R" --language python --framework django --component be 2>/dev/null)"
miss=0
while IFS=$'\t' read -r role name path; do
  case "$role" in \#*|"") continue;; esac
  if [ ! -f "$path" ]; then
    echo "FAIL: emitted fallback path missing on disk: $path (role=$role name=$name)" >&2
    miss=1
  fi
done <<< "$table_out"
if [ "$miss" -eq 0 ]; then pass=$((pass + 1)); else fail=1; fi

# --- 4. Determinism: two runs byte-identical -----------------------------------------------
a="$(bash "$R" --language typescript --framework react --component fe 2>/dev/null)"
b="$(bash "$R" --language typescript --framework react --component fe 2>/dev/null)"
if [ "$a" = "$b" ]; then pass=$((pass + 1)); else
  echo "FAIL: resolver is non-deterministic (two runs differ)" >&2; fail=1
fi

# --- 5. Unknown input fails loud (non-zero), never guesses ----------------------------------
if bash "$R" --language cobol --component be >/dev/null 2>&1; then
  echo "FAIL: unknown language 'cobol' should exit non-zero" >&2; fail=1
else pass=$((pass + 1)); fi
if bash "$R" --framework nosuchfw --component be >/dev/null 2>&1; then
  echo "FAIL: unknown framework should exit non-zero" >&2; fail=1
else pass=$((pass + 1)); fi
if bash "$R" --component be >/dev/null 2>&1; then
  echo "FAIL: no language/framework should exit non-zero" >&2; fail=1
else pass=$((pass + 1)); fi

rm -rf "$tmp"

if [ "$fail" -eq 0 ]; then
  echo "test-experts-resolver: PASS ($pass checks)"
else
  echo "test-experts-resolver: FAIL" >&2
fi
exit "$fail"
