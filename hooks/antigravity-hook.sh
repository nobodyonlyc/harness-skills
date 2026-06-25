#!/usr/bin/env bash
# gate-audit: advisory — adapter/bridge; the wrapped gate owns the decision.
# Antigravity hook adapter.
#
# Antigravity's hook contract differs from Claude Code's: it delivers a JSON
# payload on STDIN (toolCall.args.CommandLine, workspacePaths, transcriptPath)
# and reads a JSON decision on STDOUT ({"decision":"allow|deny|ask",...}).
# The canonical harness gate scripts instead read $CLAUDE_TOOL_INPUT_COMMAND
# and signal allow/deny via exit code + stderr (the Claude Code contract).
#
# This adapter bridges the two so the SAME gate scripts enforce on both hosts:
#   1. parse the Antigravity stdin payload,
#   2. cd into the workspace and export the command the gate expects,
#   3. run the canonical gate, capturing its exit code + stderr,
#   4. emit Antigravity's JSON decision (exit 0 -> allow, non-zero -> deny).
#
# Usage (from .agents/hooks.json):
#   bash .harness/skills-src/hooks/antigravity-hook.sh <gate-script.sh>
#
# The adapter itself always exits 0 — Antigravity reads the decision from the
# JSON on stdout, not from this process's exit code.

set -uo pipefail

GATE="${1:-}"
[ -n "$GATE" ] || { printf '{"decision":"allow"}\n'; exit 0; }

DIR="$(cd "$(dirname "$0")" && pwd)"
GATE_PATH="$DIR/$GATE"
[ -f "$GATE_PATH" ] || { printf '{"decision":"allow"}\n'; exit 0; }

PAYLOAD="$(cat)"

# Extract a field from the payload — jq first, python3 fallback, else empty.
field() { # $1 = jq filter   $2 = python expression over `d`
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$PAYLOAD" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try: d=json.load(sys.stdin)
except Exception: d={}
print($2)" 2>/dev/null
  fi
}

CMD="$(field '.toolCall.args.CommandLine' "d.get('toolCall',{}).get('args',{}).get('CommandLine','') or ''")"
WORKDIR="$(field '.workspacePaths[0]' "(d.get('workspacePaths') or [''])[0] or ''")"
TRANSCRIPT="$(field '.transcriptPath' "d.get('transcriptPath','') or ''")"

# Run the gate from the workspace root so its relative paths resolve.
[ -n "$WORKDIR" ] && cd "$WORKDIR" 2>/dev/null || true

export CLAUDE_TOOL_INPUT_COMMAND="$CMD"

# Feed a Claude-shaped stdin for Stop-class gates that read transcript_path;
# command-class gates ignore stdin and use the exported env / argument.
ERR="$(printf '{"transcript_path":"%s"}' "$TRANSCRIPT" | bash "$GATE_PATH" "$CMD" 2>&1 1>/dev/null)"
CODE=$?

# JSON-encode the (possibly multi-line) reason. jq -Rs first, python3 fallback.
json_str() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -Rs . 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$1" | python3 -c 'import sys,json;print(json.dumps(sys.stdin.read()))' 2>/dev/null
  else
    printf '"%s"' "$(printf '%s' "$1" | tr -d '\n"\\')"
  fi
}

if [ "$CODE" -eq 0 ]; then
  # Advisory hooks (caveman, context-budget) pass (exit 0) but may print a note on stderr —
  # carry it as a reason so Antigravity can surface it, instead of dropping it silently.
  if [ -n "$ERR" ]; then
    printf '{"decision":"allow","reason":%s}\n' "$(json_str "$ERR")"
  else
    printf '{"decision":"allow"}\n'
  fi
else
  printf '{"decision":"deny","reason":%s}\n' "$(json_str "$ERR")"
fi
exit 0
