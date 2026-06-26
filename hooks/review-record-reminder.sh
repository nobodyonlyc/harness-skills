#!/usr/bin/env bash
# gate-audit: advisory — reminds to record review provenance after a reviewer subagent stops; never blocks.
#
# Event: SubagentStop (Claude Code). When a subagent finishes during an in-progress feature, the main
# agent may have just run the Phase-6 role reviewer — but a hook CANNOT know the reviewer's verdict,
# so it never fabricates a `harness review record`. It only NUDGES: if the in-progress feature has no
# CURRENT review provenance, inject a system-reminder telling the agent to record it (or re-review if
# STALE). Stays silent when provenance is already CURRENT or no feature is active. Always exits 0.
#
# This is the SOFT, observable companion to the HARD review-provenance-gate (which blocks at verify).
# Honest limit (cf. expert-inject.sh): a hook can remind, not think.
set -uo pipefail

FEATURES=".harness/features.json"
[ -f "$FEATURES" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

ID="$(python3 -c "
import json
try:
    d = json.load(open('$FEATURES'))
    print(next((f['id'] for f in d.get('features', []) if f.get('status') == 'in_progress'), ''))
except Exception:
    print('')
" 2>/dev/null)"
[ -n "$ID" ] || exit 0

# Locate the harness binary; if absent or it predates `review`, stay silent (cannot assess).
HARNESS=""
for c in "./harness" "${CLAUDE_PROJECT_DIR:-.}/harness" "harness"; do
  if [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; then HARNESS="$c"; break; fi
done
[ -n "$HARNESS" ] || exit 0

STATUS_JSON="$("$HARNESS" review status "$ID" --json 2>/dev/null)" || exit 0
[ -n "$STATUS_JSON" ] || exit 0
STATE="$(printf '%s' "$STATUS_JSON" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('state','?'))
except Exception: print('?')" 2>/dev/null)"

[ "$STATE" = "CURRENT" ] && exit 0   # already recorded for this diff — nothing to nudge

if [ "$STATE" = "STALE" ]; then
  MSG="Review provenance for ${ID} is STALE (code changed since the last review). If the subagent that just finished re-reviewed the current diff, record it: harness review record ${ID} --nonce <n> --verdict clean|findings --findings <N> (open a fresh nonce first if needed)."
else
  MSG="No CURRENT review provenance for ${ID}. If the subagent that just finished was the Phase-6 role reviewer, record its verdict: harness review record ${ID} --nonce <n> --verdict clean|findings --findings <N>. The review-provenance-gate will block 'harness verify ${ID}' until this is recorded."
fi

REMINDER="$(printf '<system-reminder>\nREVIEW PROVENANCE [%s]: %s\n</system-reminder>' "$ID" "$MSG")"
printf '%s\n' "$REMINDER" >&2
python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SubagentStop","additionalContext":sys.argv[1]}}))' "$REMINDER" 2>/dev/null || true
exit 0
