# belousov-petr marketplace

A catalog of agentic plugins for [Claude Code](https://claude.com/claude-code) and
[Codex](https://github.com/openai/codex), from
[belousov-petr](https://github.com/belousov-petr). Add it once, then install any plugin
below.

## Plugins

| Plugin | What it does |
|---|---|
| **strata** | Keeps a project's docs, decisions, issues, and layered memory in step with the code, under `.strata/`. |

## Install

Add the catalog once, then install the plugins you want. The examples use `strata`; swap
in any name from the table.

**Claude Code**
```bash
claude plugin marketplace add belousov-petr/marketplace
claude plugin install strata@belousov-petr
```

**Codex**
```bash
codex plugin marketplace add belousov-petr/marketplace --ref main
codex plugin add strata@belousov-petr
```

## Staying updated

Once a plugin is installed, new versions arrive on their own:

- **Claude Code:** turn on auto-update for this catalog (`/plugin` → **Marketplaces** →
  **belousov-petr** → enable auto-update), then run `/reload-plugins` after it updates.
- **Codex:** automatic at startup; start a new thread to load a new version.

To update by hand: Claude `claude plugin update <plugin>@belousov-petr`, or Codex
`codex plugin marketplace upgrade belousov-petr` then a new thread.

## For maintainers

Each plugin's Claude entry points at the plugin's own repo; the Codex side keeps a
vendored copy under `plugins/<plugin>/`. When a plugin cuts a release, a GitHub Action
re-syncs this catalog on its own (it also runs on a schedule, and can be run by hand from
the **Actions** tab). The workflow files under `.github/workflows/` have the setup details.
