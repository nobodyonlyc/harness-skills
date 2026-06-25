#!/usr/bin/env bash
# FROZEN verification (F49) — enforce that NO gate decides pass/fail by the model judging its own
# work. Every gate is classified at its head with a `# gate-audit: <type> — <basis>` tag, and this
# lint checks the classification is complete, consistent with the code, and self-eval-free.
#
# Invariants:
#   completeness  every hooks/*.sh carries exactly one valid `# gate-audit:` tag.
#   mechanical    blocks (exit 1/2) AND derives the decision from an artifact (file/grep/awk/path,
#                 $COMMAND/CLAUDE_TOOL_INPUT, or an exit-code read) — never a self-report.
#   judgment      declares tier=judgment AND a routing word (route/stronger/user) — the chokepoint is
#                 explicit and escalated, never a silent model self-grade.
#   advisory      never blocks (no exit 1/2) — nudge/helper only.
#   no-self-eval  no gate gates a decision on a self-affirmation phrase (looks good / lgtm / ...).
#
# Usage: lint-no-self-eval-gates.sh [--hooks-dir <dir>]   (default: <skills-src>/hooks)
# Exit 0 = all checks pass; exit 1 otherwise.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$ROOT/hooks"
[ "${1:-}" = "--hooks-dir" ] && [ -n "${2:-}" ] && HOOKS_DIR="$2"
[ -d "$HOOKS_DIR" ] || { echo "lint-no-self-eval: no hooks dir at $HOOKS_DIR" >&2; exit 1; }

fail=0
n_mech=0 n_judg=0 n_adv=0 n_total=0

# Non-comment code lines only (drop full-line comments incl. the gate-audit tag).
code_of() { grep -vE '^[[:space:]]*#' "$1"; }
blocks() { code_of "$1" | grep -qE '\bexit[[:space:]]+[12]\b'; }
reads_artifact() {
  code_of "$1" | grep -qE '\[[[:space:]]+-[ef]|grep|awk|sed|cat|docs/|\.harness/|EVIDENCE|PLAN|ARCH|COMMAND|CLAUDE_TOOL_INPUT|\$\?'
}

# Self-affirmation phrases used as a DECISION (in a grep/test/case), not a printed message.
SELF_EVAL='looks good|lgtm|i confirm|self-assess|trust me|seems (done|fine|correct|good)|i think it (works|is done)|good enough by me'

for f in "$HOOKS_DIR"/*.sh; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  n_total=$((n_total + 1))

  tags="$(grep -cE '^# gate-audit:' "$f")"
  if [ "$tags" -ne 1 ]; then
    echo "FAIL [$name]: expected exactly one '# gate-audit:' tag, found $tags." >&2
    fail=1; continue
  fi
  tagline="$(grep -m1 -E '^# gate-audit:' "$f")"
  type="$(printf '%s' "$tagline" | sed -E 's/^# gate-audit:[[:space:]]*([a-z]+).*/\1/')"

  case "$type" in
    mechanical)
      n_mech=$((n_mech + 1))
      if ! blocks "$f"; then
        echo "FAIL [$name]: classified mechanical but contains no blocking 'exit 1'/'exit 2'." >&2; fail=1
      fi
      if ! reads_artifact "$f"; then
        echo "FAIL [$name]: classified mechanical but reads no artifact (file/command/exit-code)." >&2; fail=1
      fi
      ;;
    judgment)
      n_judg=$((n_judg + 1))
      if ! grep -qE 'tier=judgment' "$f"; then
        echo "FAIL [$name]: classified judgment but header lacks 'tier=judgment'." >&2; fail=1
      fi
      if ! grep -qiE 'route|stronger|user' "$f"; then
        echo "FAIL [$name]: judgment chokepoint declares no routing (route/stronger/user)." >&2; fail=1
      fi
      ;;
    advisory)
      n_adv=$((n_adv + 1))
      if blocks "$f"; then
        echo "FAIL [$name]: classified advisory but contains a blocking 'exit 1'/'exit 2'." >&2; fail=1
      fi
      ;;
    *)
      echo "FAIL [$name]: invalid gate-audit type '$type' (want mechanical|judgment|advisory)." >&2
      fail=1
      ;;
  esac

  # Core check: a decision must never hinge on a model self-affirmation phrase.
  if code_of "$f" | grep -iE 'grep|\[\[?|case|=~|test ' | grep -qiE "$SELF_EVAL"; then
    echo "FAIL [$name]: a decision references a self-affirmation phrase (model self-eval)." >&2
    code_of "$f" | grep -inE 'grep|\[\[?|case|=~|test ' | grep -iE "$SELF_EVAL" >&2
    fail=1
  fi
done

if [ "$n_total" -eq 0 ]; then
  echo "lint-no-self-eval: FAIL — no hooks found in $HOOKS_DIR" >&2
  exit 1
fi

if [ "$fail" -eq 0 ]; then
  echo "lint-no-self-eval: PASS ($n_total gates: $n_mech mechanical, $n_judg judgment, $n_adv advisory; no model self-eval)"
else
  echo "lint-no-self-eval: FAIL" >&2
fi
exit "$fail"
