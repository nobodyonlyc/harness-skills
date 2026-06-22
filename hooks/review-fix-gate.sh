#!/usr/bin/env bash
# HARD gate: block `harness verify <id>` while the evidence ## Review section has unresolved findings.
# Finding markers (check-review-loop): "- [ ]" open (blocks) · "- [x]" fixed/accepted (ok).
# Event: PreToolUse(Bash). Exit 1 = block.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

EVIDENCE="docs/design-docs/${FEATURE_ID}/evidence.md"
[ -f "$EVIDENCE" ] || exit 0

# Isolate the ## Review section (until the next ## heading), count open "- [ ]" findings.
OPEN=$(awk '/^## [Rr]eview/{f=1;next} /^## /{f=0} f' "$EVIDENCE" | grep -cE '^[[:space:]]*- \[ \]')

if [ "${OPEN:-0}" -gt 0 ] 2>/dev/null; then
  echo "REVIEW-FIX GATE [${FEATURE_ID}]: ${OPEN} unresolved review finding(s) ('- [ ]') in evidence ## Review." >&2
  echo "  Fix each (mark '- [x] … — fixed') or consciously accept ('- [x] … (accepted: reason)') before verify." >&2
  echo "  See check-review-loop." >&2
  exit 1
fi
exit 0
