#!/usr/bin/env bash
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
  echo "CONTEXT BUDGET: ~${LAST_TOKENS} tokens used (threshold ${THRESHOLD})${note}. Checkpoint: ./harness session stop && commit && ./harness resume" >&2
  [ "${CONTEXT_GUARD_HARD:-0}" = "1" ] && exit 1
fi
exit 0
