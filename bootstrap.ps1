# bootstrap.ps1 — reproduce the belousov-petr Claude Code / Codex plugin setup on a new
# Windows machine. Sources are public; idempotent.
$ErrorActionPreference = 'Continue'
function H($s) { Write-Host "`n== $s ==" -ForegroundColor Cyan }

H "preflight"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Write-Host "WARN: 'claude' not on PATH" }

H "Claude: add the catalog + install"
claude plugin marketplace add belousov-petr/marketplace
# strata is also usable as a global ~/.claude/skills/strata skill; installing as a plugin is optional.
foreach ($p in 'strata@belousov-petr') { Write-Host "-- $p"; claude plugin install $p }

if (Get-Command codex -ErrorAction SilentlyContinue) {
  H "Codex: add the catalog + install (public marketplace — added remotely, like Claude)"
  codex plugin marketplace add belousov-petr/marketplace --ref main
  codex plugin add strata@belousov-petr
}

H "done - restart Claude Code, and start a fresh Codex session, to load everything"
