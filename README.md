# belousov-petr marketplace

A catalog of agentic plugins for [Claude Code](https://claude.com/claude-code) and
[Codex](https://github.com/openai/codex), from
[belousov-petr](https://github.com/belousov-petr). Add it once, then install any plugin
below.

## Plugins

| Plugin | What it does |
|---|---|
| [**strata**](https://github.com/belousov-petr/strata) | Keeps a project's docs, decisions, issues, and layered memory in step with the code, under `.strata/`. |

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

> [!TIP]
> **Don't forget to turn on auto-updates.** In Claude Code they are off until you switch them on: `/plugin` → **Marketplaces** → **belousov-petr** → enable auto-update. Codex updates on its own.

After that, new versions arrive without you doing anything:

- **Claude Code:** updates at startup; run `/reload-plugins` once it does.
- **Codex:** updates at startup; start a new thread to load it.

To update by hand: Claude `claude plugin update <plugin>@belousov-petr`, or Codex
`codex plugin marketplace upgrade belousov-petr` then a new thread.

## For maintainers

Claude Code and Codex install plugins from this catalog, not from each plugin's own repo.
So a plugin's new version only reaches people after the catalog is updated to point at it.
That update is automatic: a GitHub Action refreshes the catalog whenever a plugin
publishes a release. It also runs on a schedule, and you can run it by hand from the
**Actions** tab. The workflow files under `.github/workflows/` explain how it works.
