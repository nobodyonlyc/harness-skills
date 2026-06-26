#!/usr/bin/env bash
# gate-audit: mechanical — queries 'harness review status --json'; blocks verify on NONE/STALE.
#
# HARD gate: block `harness verify <id>` unless an INDEPENDENT review provenance exists whose
# diff-hash still matches the working tree (state=CURRENT). This is the EXECUTION-grade half of the
# review enforcement: provenance is stamped by the CLI (harness review record) and bound to the git
# diff, so — unlike the textual review-gate/review-fix-gate checklists — it cannot be forged by a
# model writing into evidence.md. NONE = no review ran; STALE = code changed after the review.
#
# Event: PreToolUse(Bash). Exit 1 = block. `--override-snapshot` bypasses (explicit intent),
# mirroring review-fix-gate / the verify snapshot guard.
#
# Fail-open by design where it cannot positively decide: if no harness binary is found, or the
# binary predates the `review` subcommand (status errors / empty), the gate exits 0 rather than
# false-block a harness that lacks the new CLI. It blocks ONLY on a positive NONE/STALE verdict.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

# Locate the harness binary (project-local preferred). Never false-block if absent.
HARNESS=""
for c in "./harness" "${CLAUDE_PROJECT_DIR:-.}/harness" "harness"; do
  if [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; then HARNESS="$c"; break; fi
done
[ -n "$HARNESS" ] || exit 0

# Query provenance. An old binary without `review` errors here -> fail open.
STATUS_JSON="$("$HARNESS" review status "$FEATURE_ID" --json 2>/dev/null)" || exit 0
[ -n "$STATUS_JSON" ] || exit 0

STATE="$(printf '%s' "$STATUS_JSON" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('state','?'))
except Exception: print('?')" 2>/dev/null)"

case "$STATE" in
  CURRENT)
    exit 0 ;;
  NONE)
    echo "REVIEW-PROVENANCE GATE [${FEATURE_ID}]: no independent review recorded." >&2
    echo "  Resolve the reviewer role, then run the review and record it:" >&2
    echo "    bash .harness/skills-src/scripts/role-resolver.sh --phase review --stack docs/design/architecture.md" >&2
    echo "    harness review open ${FEATURE_ID} --phase review --role '<spec>'   # spawn the role reviewer" >&2
    echo "    harness review record ${FEATURE_ID} --nonce <n> --verdict clean|findings --findings <N>" >&2
    echo "  See check-review-loop. Bypass (explicit intent): --override-snapshot." >&2
    exit 1 ;;
  STALE)
    echo "REVIEW-PROVENANCE GATE [${FEATURE_ID}]: the recorded review is STALE — the working tree changed since it was reviewed." >&2
    echo "  Re-run the independent review on the current diff (harness review open/record), then verify." >&2
    echo "  Bypass (explicit intent): --override-snapshot." >&2
    exit 1 ;;
  *)
    exit 0 ;;
esac
