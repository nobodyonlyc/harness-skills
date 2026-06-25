#!/usr/bin/env bash
# gate-audit: advisory — resolves+injects+logs the skill chain; no pass/fail decision, never blocks.
# Phase-5 (code) entry: deterministically resolve the skill chain from the machine-readable Stack
# block (via the F47 resolver) and (1) INJECT a system-reminder naming the exact skills to load BY
# NAME, (2) AUTO-LOG the chain to the task observability record (.harness/trace.md + task-state).
# So skill loading is DRIVEN and OBSERVABLE by machinery, not a weak model's judgment.
#
# Event: PreToolUse(Bash). SOFT — always exits 0, never blocks a tool call. Fires once per task at
# code-phase entry (idempotent via the '## Resolved skill chain (auto)' marker in the task-state).
#
# NOTE (honest limit, cf. caveman-activate.sh): a hook can name + log the chain, but cannot force a
# model to read each SKILL.md. The skills/AGENTS rules carry that obligation; this makes it explicit.
set -uo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$HOOK_DIR/../scripts/experts-resolver.sh"
FEATURES=".harness/features.json"
TASKS_DIR=".harness/tasks"
ARCH="docs/design/architecture.md"
TRACE=".harness/trace.md"

[ -f "$FEATURES" ] || exit 0
[ -f "$ARCH" ] || exit 0
[ -x "$RESOLVER" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

IDS=$(jq -r '.features[]? | select(.status == "in_progress") | .id' "$FEATURES" 2>/dev/null)

for id in $IDS; do
  ts="$TASKS_DIR/$id.md"
  [ -f "$ts" ] || continue

  # Phase-5 marker: '## Current phase' value is 'code' (resources/task-state.md).
  phase=$(awk '
    /^##[[:space:]]+Current phase/ { grab=1; next }
    grab && /^##[[:space:]]/        { exit }
    grab && NF                      { print; exit }
  ' "$ts" | tr -d '[:space:]' | tr 'A-Z' 'a-z')
  [ "$phase" = "code" ] || continue

  # Idempotency: inject + log exactly once per code-phase entry.
  grep -q '^## Resolved skill chain (auto)' "$ts" && continue

  # Deterministic resolution from the Stack block (component inferred/defaulted by the resolver).
  names=$(bash "$RESOLVER" --stack "$ARCH" --format names 2>/dev/null)
  [ -n "$names" ] || continue
  chain_inline=$(echo $names)   # unquoted: collapse newlines to a single spaced line
  stamp="$(now)"

  # Build the reminder body (named skills + fallback paths).
  reminder="$(
    printf '<system-reminder>\n'
    printf 'EXPERT CHAIN [%s] — load these skills BY NAME for the code phase (deterministic, resolved from the Stack block):\n' "$id"
    while IFS= read -r n; do
      [ -n "$n" ] && printf '  - %s   (fallback path: skills/%s/SKILL.md)\n' "$n" "$n"
    done <<< "$names"
    printf 'Read and follow each SKILL.md in order: component -> language wrapper -> vendored expert. The expert never replaces a gate.\n'
    printf '</system-reminder>\n'
  )"

  # (1) INJECT — stderr (portable: Antigravity bridge reads it, Claude surfaces it) ...
  printf '%s\n' "$reminder" >&2
  # ... and Claude-native additionalContext JSON on stdout (no block; python3 = safe quoting).
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":sys.argv[1]}}))' "$reminder"

  # (2) AUTO-LOG — task-state section (also the idempotency marker) ...
  {
    printf '\n## Resolved skill chain (auto)\n'
    printf -- '- %s — code-phase entry resolved: %s\n' "$stamp" "$chain_inline"
  } >> "$ts"
  # ... and a one-line trace record.
  printf -- '- %s | skill=expert-inject | feature=%s | purpose=code-phase skill chain | result=%s\n' \
    "$stamp" "$id" "$chain_inline" >> "$TRACE"
done

exit 0
