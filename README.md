# belousov-petr marketplace

The single plugin catalog for [belousov-petr](https://github.com/belousov-petr).
It is shaped for both Claude Code and Codex.

## Claude Code

```bash
claude plugin marketplace add belousov-petr/marketplace
claude plugin install strata@belousov-petr
```

Update later with `claude plugin marketplace update belousov-petr` then
`claude plugin update strata@belousov-petr`.

## Codex

```bash
codex plugin marketplace add belousov-petr/marketplace --ref main
codex plugin add strata@belousov-petr
```

Update later with `codex plugin marketplace upgrade belousov-petr`, then start a
new Codex thread. (Codex also auto-upgrades Git marketplaces at startup — see below.)

## Plugins

| Plugin | What it does | Source |
|---|---|---|
| **strata** | Keeps a project's docs, decisions, issues, and layered memory in step with the code, under `.strata/`. Shared by Claude Code + Codex. | [`belousov-petr/strata`](https://github.com/belousov-petr/strata) |

The Claude marketplace entry points to the Strata repo directly. The Codex marketplace
vendors an installable package under `plugins/strata` because Codex marketplace
entries resolve local package paths inside this repo. Plugin versions here mirror
Strata's `plugin.json` so Claude and Codex detect refreshes.

## Auto-updates

- **Claude Code:** opt-in per marketplace. In `/plugin` → **Marketplaces** → **belousov-petr**, enable auto-update; new versions then land at startup (run `/reload-plugins` after). Auto-update only updates a plugin you already have installed.
- **Codex:** automatic for this Git marketplace. Codex refreshes configured Git marketplaces at startup, so a new release lands on the next `codex` start / new thread. Manual: `codex plugin marketplace upgrade belousov-petr`.

Either way, a release only reaches anyone once this catalog is updated — see below.

## Releasing a new strata version

This catalog is the gating step: the harnesses pull strata from here, not from the
strata repo directly. After cutting a strata release (bump `plugin.json`, tag, push),
sync it in:

```bash
./sync-strata.sh /path/to/strata        # defaults to ../strata
git add -A && git commit -m "strata: sync to <version>" && git push
```

`sync-strata.sh` re-vendors the Codex package under `plugins/strata/` and bumps the
Claude catalog's version label to match strata's `plugin.json`. Once pushed, the new
version auto-lands per **Auto-updates** above.
