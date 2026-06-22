#!/usr/bin/env bash
# Re-vendor expert skills from the pinned source into skills/.
# This documents HOW the vendored experts were produced; verifications check the files exist
# in-tree (no network at verify time). Requires `gh` + network when actually re-vendoring.
#
# Usage: bash scripts/vendor-experts.sh <skill-name> [<skill-name> ...]
set -euo pipefail

REPO="nobodyonlyc/skills"
PIN="f6c3127a9b90cf17eaa185d61ad5f1496a440891"   # see vendor/EXPERT-SKILLS.md

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

[ "$#" -ge 1 ] || { echo "usage: vendor-experts.sh <skill-name> [...]" >&2; exit 2; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
echo "==> fetching $REPO @ $PIN"
gh api "repos/$REPO/tarball/$PIN" > "$tmp/src.tar.gz"
tar xzf "$tmp/src.tar.gz" -C "$tmp"
src="$(ls -d "$tmp"/*/ | head -1)"

for name in "$@"; do
  if [ ! -d "${src}skills/$name" ]; then
    echo "  SKIP: $name not found in source" >&2; continue
  fi
  rm -rf "skills/$name"
  cp -R "${src}skills/$name" "skills/$name"
  echo "  vendored: skills/$name"
done

echo "==> remember to add each name to resources/expert-skills-map.md and run scripts/lint-expert-map.sh"
