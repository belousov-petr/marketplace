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

Update later with `codex plugin marketplace upgrade belousov-petr` and then
rerun `codex plugin add strata@belousov-petr`.

## Plugins

| Plugin | What it does | Source |
|---|---|---|
| **strata** | Keeps a project's docs, decisions, issues, and layered memory in step with the code, under `.strata/`. Shared by Claude Code + Codex. | [`belousov-petr/strata`](https://github.com/belousov-petr/strata) |

The Claude marketplace entry points to the Strata repo directly. The Codex marketplace
vendors an installable package under `plugins/strata` because Codex marketplace
entries resolve local package paths inside this repo. Plugin versions here mirror
Strata's `plugin.json` so Claude and Codex detect refreshes.
