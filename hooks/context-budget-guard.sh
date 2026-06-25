#!/usr/bin/env bash
# gate-audit: mechanical — reads token count (trace/transcript); blocks (exit 2) past hard threshold.
# Warn when token context approaches threshold. Event: Stop.
# Soft by default; set CONTEXT_GUARD_HARD=1 to block.
CONTEXT_FILE=".harness/context.json"
TRACE_FILE=".harness/trace.md"
[ -f "$CONTEXT_FILE" ] || exit 0

# Stop hooks receive a JSON payload on stdin (incl. transcript_path); capture it for the
# automatic estimate below. Non-blocking read so the hook still works when stdin is empty.
HOOK_INPUT=""
if [ ! -t 0 ]; then HOOK_INPUT="$(cat 2>/dev/null || true)"; fi

THRESHOLD=$(python3 -c "
import json
try:
    print(json.load(open('$CONTEXT_FILE')).get('context_warn_threshold', 150000))
except Exception:
    print(150000)
" 2>/dev/null || echo 150000)

# Critical threshold — past this we exit 2 so Claude Code actually SURFACES the warning (a soft
# exit-0 Stop hook's stderr is not shown to the user). Default = 1.5x the warn threshold; override
# with context_hard_threshold in context.json.
HARD_THRESHOLD=$(python3 -c "
import json
try:
    c=json.load(open('$CONTEXT_FILE'))
    print(int(c.get('context_hard_threshold', int(c.get('context_warn_threshold',150000))*3//2)))
except Exception:
    print(225000)
" 2>/dev/null || echo 225000)

# Loop guard: if Claude Code is re-invoking us because a prior Stop hook already blocked, do NOT
# block again (it would trap the agent). stop_hook_active arrives in the Stop payload.
STOP_ACTIVE=$(printf '%s' "$HOOK_INPUT" | python3 -c "import json,sys
try: print('1' if json.load(sys.stdin).get('stop_hook_active') else '0')
except Exception: print('0')" 2>/dev/null)
STOP_ACTIVE="${STOP_ACTIVE:-0}"

# Preferred source: an explicit `./harness trace ... tokens=N` entry (most accurate).
LAST_TOKENS=0
SOURCE=""
if [ -f "$TRACE_FILE" ]; then
  LAST_TOKENS=$(grep -oE 'tokens=[0-9]+' "$TRACE_FILE" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)
  LAST_TOKENS="${LAST_TOKENS:-0}"
  [ "$LAST_TOKENS" -gt 0 ] 2>/dev/null && SOURCE="trace"
fi

# Fallback: estimate from the session transcript so the guard is not silent when no
# manual trace exists. ~4 chars/token; the transcript grows monotonically, which is
# exactly the "context is getting big" signal we want — approximate, not exact.
if [ "${LAST_TOKENS:-0}" -le 0 ] 2>/dev/null && [ -n "$HOOK_INPUT" ]; then
  TRANSCRIPT=$(printf '%s' "$HOOK_INPUT" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('transcript_path',''))
except Exception: print('')" 2>/dev/null)
  if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    CHARS=$(wc -c < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
    LAST_TOKENS=$(( ${CHARS:-0} / 4 ))
    SOURCE="estimate"
  fi
fi
LAST_TOKENS="${LAST_TOKENS:-0}"

if [ "$LAST_TOKENS" -gt "$THRESHOLD" ] 2>/dev/null; then
  note=""
  [ "$SOURCE" = "estimate" ] && note=" (estimated from transcript size; run ./harness trace for an exact figure)"
  # Critical: block the silent stop (exit 2) so the user actually sees it — unless we are already in
  # a stop-hook loop, or the user opted out with CONTEXT_GUARD_SOFT=1.
  if { [ "$LAST_TOKENS" -gt "$HARD_THRESHOLD" ] 2>/dev/null || [ "${CONTEXT_GUARD_HARD:-0}" = "1" ]; } \
     && [ "$STOP_ACTIVE" != "1" ] && [ "${CONTEXT_GUARD_SOFT:-0}" != "1" ]; then
    echo "CONTEXT BUDGET CRITICAL: ~${LAST_TOKENS} tokens (hard threshold ${HARD_THRESHOLD})${note}." >&2
    echo "  Start a fresh session now: ./harness session stop && commit, then resume in a NEW session." >&2
    exit 2
  fi
  echo "CONTEXT BUDGET: ~${LAST_TOKENS} tokens used (threshold ${THRESHOLD})${note}. Checkpoint: ./harness session stop && commit && ./harness resume" >&2
fi
exit 0
