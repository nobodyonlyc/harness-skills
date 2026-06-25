#!/usr/bin/env bash
# gate-audit: mechanical — reads evidence E2E coverage matrix; blocks.
# Block `harness verify <id>` when E2E was selected but the UI is not fully covered: evidence must
# carry an E2E coverage matrix that names real spec files and leaves no flow uncovered.
# Enforces test-e2e/SKILL.md: for a UI, E2E covers the ENTIRE system — every flow gets a spec.
# Event: PreToolUse(Bash). Exit 0 = allow, Exit 1 = block.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

EVIDENCE="docs/design-docs/${FEATURE_ID}/evidence.md"
[ -f "$EVIDENCE" ] || exit 0

# Only enforce when E2E was actually selected (a formal "e2e:" verdict line exists).
grep -qiE '^[-*[:space:]]*e2e:' "$EVIDENCE" 2>/dev/null || exit 0

# 1. A coverage matrix section.
if ! grep -qiE 'coverage matrix' "$EVIDENCE" 2>/dev/null; then
  echo "E2E-COVERAGE GATE [${FEATURE_ID}]: E2E selected but no '### E2E Coverage Matrix' in evidence." >&2
  echo "  Enumerate every user flow (design-ux-flow) -> spec file -> Status, and prove full coverage." >&2
  exit 1
fi

# 2. At least one real spec-file reference.
if ! grep -qiE '\.spec\.|\.cy\.|\.e2e\.|_test\.|test_[a-z0-9]' "$EVIDENCE" 2>/dev/null; then
  echo "E2E-COVERAGE GATE [${FEATURE_ID}]: coverage matrix references no spec file (*.spec.* / *.cy.* / *_test.* / test_*)." >&2
  exit 1
fi

# 3. No uncovered flow: scan table rows for holes.
if grep -E '^[[:space:]]*\|' "$EVIDENCE" 2>/dev/null | grep -qiE 'missing|uncovered|not covered|no spec|partial|\btodo\b'; then
  echo "E2E-COVERAGE GATE [${FEATURE_ID}]: a flow is not fully covered (MISSING/UNCOVERED/PARTIAL/TODO in the matrix)." >&2
  echo "  Full-system coverage is required for UI — close the hole, do not delete the row." >&2
  exit 1
fi

# 4. At least one row positively marked COVERED (\bCOVERED\b does not match inside 'uncovered').
if ! grep -qiE '\bcovered\b' "$EVIDENCE" 2>/dev/null; then
  echo "E2E-COVERAGE GATE [${FEATURE_ID}]: no flow marked COVERED in the matrix." >&2
  exit 1
fi
exit 0
