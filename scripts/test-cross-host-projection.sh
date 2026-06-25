#!/usr/bin/env bash
# FROZEN verification (F50) — cross-host skill projection.
#
# Runs skills-src/install.sh against a hermetic temp PROJECT_ROOT + GEMINI_CONFIG_DIR and asserts the
# single canonical skills dir is projected into every host WITHOUT content duplication:
#   CC          -> .claude/skills            symlink -> canonical
#   Codex       -> .agents/skills            symlink -> canonical
#   Antigravity -> .agents/skills.json       registry {entries:[{path: <abs canonical>}]}
#               -> <GEMINI>/config/skills.json  (merge-safe, deduped)
# Plus: no duplication (projections are symlinks, not copies), idempotency, and global merge-safety.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$ROOT/install.sh"
CANON="$(python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$ROOT/skills")"
[ -f "$INSTALL" ] || { echo "test-cross-host-projection: missing $INSTALL" >&2; exit 1; }
[ -d "$CANON" ]   || { echo "test-cross-host-projection: canonical skills dir missing: $CANON" >&2; exit 1; }

rp() { python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$1"; }
fail=0; pass=0
check() { if [ "$2" -eq 0 ]; then pass=$((pass + 1)); else echo "FAIL: $1" >&2; fail=1; fi; }

PROJ="$(mktemp -d)"
GEM="$(mktemp -d)"
GL="$GEM/config/skills.json"

# Pre-seed the global registry with an UNRELATED entry to prove merge-safety.
mkdir -p "$GEM/config"
printf '{"entries":[{"path":"/opt/other/skills"}]}\n' > "$GL"

run() { HARNESS_PROJECT_ROOT="$PROJ" GEMINI_CONFIG_DIR="$GEM" bash "$INSTALL" >/dev/null 2>&1; }

run; rc=$?
check "install.sh exits 0" "$rc"

# --- CC + Codex symlinks resolve to the canonical dir --------------------------------------
[ -L "$PROJ/.claude/skills" ] && c=0 || c=1; check ".claude/skills is a symlink" "$c"
[ "$(rp "$PROJ/.claude/skills")" = "$CANON" ] && c=0 || c=1; check ".claude/skills -> canonical" "$c"
[ -L "$PROJ/.agents/skills" ] && c=0 || c=1; check ".agents/skills is a symlink (Codex)" "$c"
[ "$(rp "$PROJ/.agents/skills")" = "$CANON" ] && c=0 || c=1; check ".agents/skills -> canonical" "$c"

# --- No content duplication: projections are symlinks, not real copied dirs ----------------
{ [ -L "$PROJ/.claude/skills" ] && [ -L "$PROJ/.agents/skills" ]; } && c=0 || c=1
check "projections are symlinks, not copies (no duplication)" "$c"

# --- Antigravity workspace registry --------------------------------------------------------
WS="$PROJ/.agents/skills.json"
[ -f "$WS" ] && c=0 || c=1; check ".agents/skills.json exists" "$c"
python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$WS" 2>/dev/null && c=0 || c=1
check ".agents/skills.json is valid JSON" "$c"
ws_path="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['entries'][0]['path'])" "$WS" 2>/dev/null)"
case "$ws_path" in /*) c=0;; *) c=1;; esac; check "workspace entry path is absolute" "$c"
[ "$(rp "$ws_path")" = "$CANON" ] && c=0 || c=1; check "workspace entry path -> canonical" "$c"

# --- Antigravity global registry: contains canonical + preserves the pre-seeded entry ------
[ -f "$GL" ] && c=0 || c=1; check "global skills.json exists" "$c"
python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$GL" 2>/dev/null && c=0 || c=1
check "global skills.json is valid JSON" "$c"
canon_in_global() {
  python3 -c "import json,os,sys
d=json.load(open(sys.argv[1])); canon=os.path.realpath(sys.argv[2])
print(sum(1 for e in d.get('entries',[]) if os.path.realpath(e.get('path','')) == canon))" "$GL" "$CANON"
}
[ "$(canon_in_global)" = "1" ] && c=0 || c=1; check "global registry has exactly one canonical entry" "$c"
grep -q '/opt/other/skills' "$GL" && c=0 || c=1; check "global registry preserved the pre-seeded entry (merge-safe)" "$c"

# --- Idempotency: a second run does not duplicate or break anything ------------------------
run
[ "$(rp "$PROJ/.agents/skills")" = "$CANON" ] && c=0 || c=1; check "idempotent: Codex symlink intact after re-run" "$c"
[ "$(canon_in_global)" = "1" ] && c=0 || c=1; check "idempotent: no duplicate canonical entry in global registry" "$c"
grep -q '/opt/other/skills' "$GL" && c=0 || c=1; check "idempotent: pre-seeded entry still present" "$c"

rm -rf "$PROJ" "$GEM"

if [ "$fail" -eq 0 ]; then
  echo "test-cross-host-projection: PASS ($pass checks)"
else
  echo "test-cross-host-projection: FAIL" >&2
fi
exit "$fail"
