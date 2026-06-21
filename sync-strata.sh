#!/usr/bin/env bash
#
# sync-strata.sh — vendor the strata plugin into this marketplace at its release version.
#
# This catalog is the gating step for updates: Claude Code and Codex pull strata from
# here, not from the strata repo directly. Run this after cutting a strata release
# (bump plugin.json, tag, push), then review the diff and commit + push this repo.
#
#   ./sync-strata.sh [path-to-strata-checkout]      # defaults to ../strata
#
# It does two things:
#   1. Re-vendors the Codex package under plugins/strata/ (the installable subset).
#   2. Bumps the Claude catalog version label in .claude-plugin/marketplace.json to
#      match strata's plugin.json, so both harnesses detect the new version.
#
# It only touches files; it does not commit or push (review first).

set -euo pipefail

# --- locate this marketplace repo (the directory holding this script) ---
MP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- locate the strata checkout (arg, or ../strata next to this repo) ---
SRC_IN="${1:-$MP_ROOT/../strata}"
SRC="$(cd "$SRC_IN" 2>/dev/null && pwd || true)"
if [ -z "$SRC" ] || [ ! -f "$SRC/.claude-plugin/plugin.json" ]; then
  echo "error: strata checkout not found or invalid: $SRC_IN" >&2
  echo "usage: $0 [path-to-strata-checkout]   (default: ../strata)" >&2
  exit 1
fi

DST="$MP_ROOT/plugins/strata"
CLAUDE_MP="$MP_ROOT/.claude-plugin/marketplace.json"
[ -d "$DST" ]        || { echo "error: $DST missing — is this the marketplace repo?" >&2; exit 1; }
[ -f "$CLAUDE_MP" ]  || { echo "error: $CLAUDE_MP missing — is this the marketplace repo?" >&2; exit 1; }

# --- read the release version from strata's plugin.json ---
VERSION="$(grep -m1 '"version"' "$SRC/.claude-plugin/plugin.json" \
  | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
[ -n "$VERSION" ] || { echo "error: could not read version from $SRC/.claude-plugin/plugin.json" >&2; exit 1; }

echo "strata version : $VERSION"
echo "strata source  : $SRC"
echo "marketplace    : $MP_ROOT"
echo

# --- re-vendor the Codex package (faithful mirror of the installable subset) ---
# Vendored set: commands/, hooks/, skills/strata/, README.md, LICENSE, Strata.png,
# and .codex-plugin/plugin.json. NOT vendored: .claude-plugin/ (Claude points at the
# repo), tests/, docs/, CHANGELOG/MIGRATIONS, working screenshots.
rm -rf "$DST/commands" "$DST/hooks" "$DST/skills"
mkdir -p "$DST/skills"
cp -r "$SRC/commands"                  "$DST/commands"
cp -r "$SRC/hooks"                     "$DST/hooks"
cp -r "$SRC/skills/strata"             "$DST/skills/strata"
cp    "$SRC/README.md"                 "$DST/README.md"
cp    "$SRC/LICENSE"                   "$DST/LICENSE"
cp    "$SRC/Strata.png"                "$DST/Strata.png"
cp    "$SRC/.codex-plugin/plugin.json" "$DST/.codex-plugin/plugin.json"

# --- bump the Claude catalog version label to match (minimal, in-place) ---
sed -i -E 's/("version"[[:space:]]*:[[:space:]]*")[^"]*(")/\1'"$VERSION"'\2/' "$CLAUDE_MP"

# --- verify ---
VENDORED="$(grep -m1 '"version"' "$DST/.codex-plugin/plugin.json" | sed -E 's/.*"([0-9][^"]*)".*/\1/')"
CATALOG="$(grep -m1 '"version"' "$CLAUDE_MP" | sed -E 's/.*"([0-9][^"]*)".*/\1/')"
echo "vendored Codex plugin.json : $VENDORED"
echo "Claude catalog label       : $CATALOG"
[ "$VENDORED" = "$VERSION" ] && [ "$CATALOG" = "$VERSION" ] \
  && echo "OK — both at $VERSION" \
  || { echo "WARNING: versions do not all match $VERSION — check the output above" >&2; exit 1; }

cat <<EOF

Synced. Review and ship:
  git -C "$MP_ROOT" add -A
  git -C "$MP_ROOT" status
  git -C "$MP_ROOT" commit -m "strata: sync to $VERSION"
  git -C "$MP_ROOT" push
EOF
