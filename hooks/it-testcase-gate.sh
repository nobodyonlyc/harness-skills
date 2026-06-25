#!/usr/bin/env bash
# gate-audit: mechanical — reads evidence integration test-case table; blocks.
# Block `harness verify <id>` when integration testing was selected but evidence lacks an explicit
# integration test-case table (concrete Steps + Expected Output + at least one executed row).
# Enforces test-integration/SKILL.md: every IT is a documented case, never a vague "it works".
# Event: PreToolUse(Bash). Exit 0 = allow, Exit 1 = block.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

EVIDENCE="docs/design-docs/${FEATURE_ID}/evidence.md"
[ -f "$EVIDENCE" ] || exit 0

# Only enforce when integration was actually selected (a formal "integration:" verdict line exists).
grep -qiE '^[-*[:space:]]*integration:' "$EVIDENCE" 2>/dev/null || exit 0

# 1. A test-case section heading.
if ! grep -qiE 'integration test cases' "$EVIDENCE" 2>/dev/null; then
  echo "IT-TESTCASE GATE [${FEATURE_ID}]: integration selected but no '### Integration Test Cases' section in evidence." >&2
  echo "  Add a test-case table with columns: ID | Scenario | Preconditions | Steps | Input | Expected Output | Result." >&2
  exit 1
fi

# 2. A table header that has both a Steps and an Expected column.
if ! grep -iE '\|' "$EVIDENCE" 2>/dev/null | grep -i 'steps' | grep -qi 'expected'; then
  echo "IT-TESTCASE GATE [${FEATURE_ID}]: test-case table missing 'Steps' and/or 'Expected Output' columns." >&2
  exit 1
fi

# 3. At least one real data row (a pipe row carrying a PASS/FAIL result, not just placeholders).
if ! grep -E '^[[:space:]]*\|' "$EVIDENCE" 2>/dev/null | grep -qiE '\b(PASS|FAIL)\b'; then
  echo "IT-TESTCASE GATE [${FEATURE_ID}]: no executed test-case row found (need a row with a concrete Result)." >&2
  echo "  A table of TBD/TODO placeholders does not satisfy the gate." >&2
  exit 1
fi
exit 0
