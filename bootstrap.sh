#!/usr/bin/env bash
# bootstrap.sh — reproduce the belousov-petr Claude Code / Codex plugin setup on a new
# machine. Sources are public; idempotent. On native Windows PowerShell, use bootstrap.ps1.
set -u
h() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

h "preflight"
command -v claude >/dev/null 2>&1 || echo "WARN: 'claude' not on PATH"

# Plugin installs clone via git@github.com. If this machine has no working GitHub SSH key,
# pin the host key and force HTTPS so clones succeed without one.
if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -qi 'successfully authenticated'; then
  h "no GitHub SSH key here — pin host key + force HTTPS clones"
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keyscan -t rsa,ecdsa,ed25519 github.com 2>/dev/null >> "$HOME/.ssh/known_hosts"
  sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts" 2>/dev/null || true
  git config --global url."https://github.com/".insteadOf "git@github.com:"
fi

h "Claude: add the catalog + install"
claude plugin marketplace add belousov-petr/marketplace 2>&1 | tail -1
# strata is also usable as a global ~/.claude/skills/strata skill; installing it as a plugin
# is optional. Add more names here as the catalog grows.
for p in strata@belousov-petr; do
  printf '  %-28s ' "$p"; claude plugin install "$p" 2>&1 | tail -1
done

if command -v codex >/dev/null 2>&1; then
  h "Codex: add the catalog + install (public marketplace — added remotely, like Claude)"
  codex plugin marketplace add belousov-petr/marketplace --ref main 2>&1 | tail -1
  codex plugin add strata@belousov-petr 2>&1 | tail -1
fi

h "done — restart Claude Code, and start a fresh Codex session, to load everything"
