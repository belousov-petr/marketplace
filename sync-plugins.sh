#!/usr/bin/env bash
#
# sync-plugins.sh — vendor each plugin's Codex package into plugins/<name>/ at its release
# version, and set the Claude catalog version label to match. Sources are PUBLIC, so the
# workflow checks them out with the default GITHUB_TOKEN (no read tokens needed).
#
# Generalized from the original single-strata sync so the catalog can grow to many plugins.
# Add a plugin = add a vendor_* + set_catalog_version + check line below, plus a catalog
# entry in .claude-plugin/marketplace.json and .agents/plugins/marketplace.json, and a
# checkout step in .github/workflows/sync-plugins.yml.
#
#   ./sync-plugins.sh <strata-src> [<next-plugin-src> ...]
#
# Touches files only; the workflow (or you) commits.

set -euo pipefail
command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }

MP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_MP="$MP_ROOT/.claude-plugin/marketplace.json"
[ -f "$CLAUDE_MP" ] || { echo "error: $CLAUDE_MP missing — run from the marketplace repo" >&2; exit 1; }

read_version() { jq -r '.version' "$1/.claude-plugin/plugin.json"; }

# Set a plugin's version label in the Claude catalog, preserving formatting. Anchored on the
# plugin's "name" and non-greedy to its first following "version" — stays correct once the
# catalog holds more than one plugin (a blind first-"version" sed would not).
set_catalog_version() {  # <plugin-name> <version>
  PL_NAME="$1" PL_VER="$2" perl -0pi -e \
    's/("name"\s*:\s*"\Q$ENV{PL_NAME}\E".*?"version"\s*:\s*")[^"]*(")/$1$ENV{PL_VER}$2/s' \
    "$CLAUDE_MP"
}

# Assembled-subset vendor: build the Codex package from an explicit list of source paths
# (dirs or files; sub-paths preserved). The source must carry .codex-plugin/plugin.json.
vendor_assembled() {  # <src> <name> <path...>
  local src="$1" name="$2"; shift 2
  local dst="$MP_ROOT/plugins/$name" p
  [ -f "$src/.codex-plugin/plugin.json" ] || { echo "error: not a $name checkout: $src" >&2; exit 1; }
  rm -rf "$dst"; mkdir -p "$dst/.codex-plugin"
  cp -p "$src/.codex-plugin/plugin.json" "$dst/.codex-plugin/plugin.json"
  for p in "$@"; do
    mkdir -p "$dst/$(dirname "$p")"
    cp -Rp "$src/$p" "$dst/$p"
  done
}

# Prebuilt-dir vendor: source ships a ready-made codex/<name>/ package. Unused today; kept
# for a future plugin that uses this style (see the PluginPhantom marketplace for an example).
vendor_prebuilt() {  # <src> <name>
  local src="$1" name="$2" pkg dst
  pkg="$src/codex/$name"; dst="$MP_ROOT/plugins/$name"
  [ -f "$pkg/.codex-plugin/plugin.json" ] || { echo "error: not a $name checkout: $src" >&2; exit 1; }
  rm -rf "$dst"; mkdir -p "$dst"; cp -Rp "$pkg/." "$dst/"
}

check() {  # <plugin-name> <want-version>
  local name="$1" want="$2" vend cat
  vend="$(jq -r '.version' "$MP_ROOT/plugins/$name/.codex-plugin/plugin.json")"
  cat="$(jq -r --arg n "$name" '.plugins[] | select(.name==$n) | .version' "$CLAUDE_MP")"
  echo "  $name: vendored=$vend catalog=$cat want=$want"
  [ "$vend" = "$want" ] && [ "$cat" = "$want" ]
}

# ----------------------------------------------------------------------------------------
# Per-plugin wiring — edit this block when adding or removing a plugin.
# ----------------------------------------------------------------------------------------
STRATA_SRC="$(cd "${1:?usage: $0 <strata-src> [<next-plugin-src> ...]}" && pwd)"
STRATA_VER="$(read_version "$STRATA_SRC")"
[ -n "$STRATA_VER" ] && [ "$STRATA_VER" != "null" ] || { echo "error: no version in strata source" >&2; exit 1; }

echo "strata : $STRATA_VER  (src: $STRATA_SRC)"
echo

vendor_assembled "$STRATA_SRC" "strata" commands hooks skills/strata README.md LICENSE Strata.png
set_catalog_version "strata" "$STRATA_VER"

ok=1
check "strata" "$STRATA_VER" || ok=0
if [ "$ok" = 1 ]; then
  echo "OK — catalog labels + vendored manifests consistent"
else
  echo "WARNING: version mismatch after sync — check output above" >&2
  exit 1
fi
