#!/usr/bin/env bash
# FROZEN verification (F51) — implicit-invocation policy: only tier:entry skills are implicitly
# auto-selectable; all craft/expert/component skills are explicit-name only.
#
# (a) Codex   — gen-implicit-policy.sh emits an openai.yaml where the 5 workflow-* (tier:entry) are
#               allow_implicit_invocation:true and EVERY other skill is false; complete + deterministic.
# (b) install — install.sh writes .agents/openai.yaml with that policy AND the explicit Antigravity
#               spine (.agents/workflows/harness-workflow-*.md adapters), so neither host relies on
#               implicit pickup of non-entry skills.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$ROOT/scripts/gen-implicit-policy.sh"
INSTALL="$ROOT/install.sh"
SKILLS_DIR="$ROOT/skills"
[ -x "$GEN" ] || { echo "test-implicit-policy: missing/!executable $GEN" >&2; exit 1; }

fail=0; pass=0
check() { if [ "$2" -eq 0 ]; then pass=$((pass + 1)); else echo "FAIL: $1" >&2; fail=1; fi; }

POLICY="$(bash "$GEN" 2>/dev/null)"

# implicit_of <skill> -> prints true|false|MISSING for that skill in the policy
implicit_of() {
  printf '%s\n' "$POLICY" | awk -v s="  $1:" '
    $0==s {found=1; next}
    found {sub(/^[[:space:]]*allow_implicit_invocation:[[:space:]]*/,""); print; exit}
    END   {if(!found) print "MISSING"}
  '
}

# --- completeness: every skills/*/ dir appears exactly once ---------------------------------
n_dirs=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
n_listed=$(printf '%s\n' "$POLICY" | grep -cE '^  [A-Za-z0-9_-]+:$')
[ "$n_dirs" = "$n_listed" ] && c=0 || c=1; check "policy lists every skill ($n_listed listed vs $n_dirs dirs)" "$c"

missing=0
for d in "$SKILLS_DIR"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  v="$(implicit_of "$name")"
  [ "$v" = "MISSING" ] && { echo "  not in policy: $name" >&2; missing=1; }
done
[ "$missing" -eq 0 ] && c=0 || c=1; check "no skill missing from policy" "$c"

# --- (a) the 5 workflow-* entry skills are implicit ON --------------------------------------
for w in workflow-intake workflow-bootstrap workflow-feature workflow-bugfix workflow-team; do
  [ "$(implicit_of "$w")" = "true" ] && c=0 || c=1; check "$w implicit ON (entry)" "$c"
done

# --- spot-check: craft / expert / component / design / review / opt skills are OFF ----------
for s in dev-be dev-go python-pro react-expert design-api check-code-review opt-caveman test-unit ship-deploy core-explore; do
  [ "$(implicit_of "$s")" = "false" ] && c=0 || c=1; check "$s implicit OFF" "$c"
done

# --- invariant: count of true == number of tier:entry skills, and no non-entry is true ------
n_true=$(printf '%s\n' "$POLICY" | grep -c 'allow_implicit_invocation: true')
n_entry=0
for d in "$SKILLS_DIR"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  t=$(awk '/^metadata:/{m=1} m&&/^  tier:/{print $2; exit}' "$d/SKILL.md")
  [ "$t" = "entry" ] && n_entry=$((n_entry + 1))
done
[ "$n_true" = "$n_entry" ] && c=0 || c=1; check "true-count ($n_true) == tier:entry count ($n_entry)" "$c"
# every true line's skill must actually be tier:entry
bad=0
while IFS= read -r name; do
  t=$(awk '/^metadata:/{m=1} m&&/^  tier:/{print $2; exit}' "$SKILLS_DIR/$name/SKILL.md" 2>/dev/null)
  [ "$t" = "entry" ] || { echo "  non-entry skill granted implicit: $name (tier=$t)" >&2; bad=1; }
done < <(printf '%s\n' "$POLICY" | awk '/^  [A-Za-z0-9_-]+:$/{n=$1; sub(/:$/,"",n)} /allow_implicit_invocation: true/{print n}')
[ "$bad" -eq 0 ] && c=0 || c=1; check "no non-entry skill is implicit ON" "$c"

# --- determinism ----------------------------------------------------------------------------
a="$(bash "$GEN" 2>/dev/null)"; b="$(bash "$GEN" 2>/dev/null)"
[ "$a" = "$b" ] && c=0 || c=1; check "generator is deterministic" "$c"

# --- (b) install wiring: .agents/openai.yaml + explicit workflow spine ----------------------
if [ -f "$INSTALL" ]; then
  PROJ="$(cd "$(mktemp -d)" && pwd -P)"; GEM="$(mktemp -d)"
  HARNESS_PROJECT_ROOT="$PROJ" GEMINI_CONFIG_DIR="$GEM" bash "$INSTALL" >/dev/null 2>&1
  [ -f "$PROJ/.agents/openai.yaml" ] && c=0 || c=1; check "install wrote .agents/openai.yaml" "$c"
  grep -q 'allow_implicit_invocation' "$PROJ/.agents/openai.yaml" 2>/dev/null && c=0 || c=1
  check ".agents/openai.yaml carries the policy" "$c"
  spine=0
  for w in workflow-intake workflow-bootstrap workflow-feature workflow-bugfix workflow-team; do
    [ -f "$PROJ/.agents/workflows/harness-$w.md" ] || spine=1
  done
  [ "$spine" -eq 0 ] && c=0 || c=1; check "Antigravity explicit /name spine adapters present" "$c"
  rm -rf "$PROJ" "$GEM"
else
  echo "FAIL: install.sh missing" >&2; fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "test-implicit-policy: PASS ($pass checks; 5 entry implicit-on, all others explicit-only)"
else
  echo "test-implicit-policy: FAIL" >&2
fi
exit "$fail"
