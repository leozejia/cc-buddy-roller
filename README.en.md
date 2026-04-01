# cc-buddy-roller

A bilingual seed workshop for the virtual pet behind Claude Code's `/buddy` command.

The workflow is guide-first, the docs are split by language, and the CLI vocabulary is centered around `guide`, `hunt`, `inspect`, `preview`, and `stamp`.

## Overview

`cc-buddy-roller` helps you work with the deterministic seed that drives the virtual pet shown by Claude Code's `/buddy` command.

It can:

- inspect the active Claude config and show the currently derived buddy
- preview any seed before you write it
- hunt for seeds that match a trait combination
- stamp a chosen seed into the config with an automatic backup
- switch the interface between English and Chinese with `--lang`

## Install

### One-line install

If the user does not already have Bun, use the installer. It installs Bun when needed, refreshes a local copy of the project, and creates a reusable `cc-buddy-roller` launcher.

```bash
curl -fsSL https://raw.githubusercontent.com/liuxiaopai-ai/cc-buddy-roller/main/install.sh | bash
cc-buddy-roller guide
```

If `cc-buddy-roller` is not available in the same shell yet, open a new terminal or run:

```bash
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
```

For the standard install path, the user does not need Bun or Git in advance. The installer handles Bun itself and downloads the source archive directly from GitHub. In practice, the system just needs `bash`, `curl`, and `tar`, which are already present on most macOS and Linux machines.

You can run the installer again later to update the local copy.

### Manual install

You need [Bun](https://bun.sh). Claude Code uses `Bun.hash`, so plain Node.js does not produce matching buddy traits.

```bash
curl -fsSL https://bun.sh/install | bash
git clone https://github.com/liuxiaopai-ai/cc-buddy-roller.git
cd cc-buddy-roller
bun buddy.mjs guide
```

## Command Model

| Command | Purpose |
|---|---|
| `bun buddy.mjs guide` | Guided flow for choosing filters, running the search, and optionally writing a result |
| `bun buddy.mjs hunt [filters]` | Direct seed search mode |
| `bun buddy.mjs inspect` | Show the current config path, active seed slot, and derived buddy |
| `bun buddy.mjs preview <seed>` | Render the buddy for a single seed |
| `bun buddy.mjs stamp <seed>` | Back up the config and write a seed into the active slot |

## Language Support

The CLI supports:

- `--lang en`
- `--lang zh`
- `--lang auto`

Examples:

```bash
bun buddy.mjs guide --lang zh
bun buddy.mjs inspect --lang en
```

## Examples

```bash
# Guided flow
bun buddy.mjs guide

# Hunt a shiny legendary dragon and keep two matches
bun buddy.mjs hunt --species dragon --rarity legendary --shiny --limit 2

# Require every stat to stay above 40
bun buddy.mjs hunt --rarity epic --stat-floor 40

# Preview a seed before writing it
bun buddy.mjs preview 9ab738bf-fb82-40fb-917d-0020259c8408

# Stamp a seed into the active config
bun buddy.mjs stamp f853b71e-3774-4bc7-b4a8-4cc0ed266f9f

# If installed with install.sh, the launcher works too
cc-buddy-roller inspect --lang en
```

## Search Filters

| Flag | Meaning |
|---|---|
| `--species <name>` | Target species |
| `--rarity <tier>` | Target rarity |
| `--eye <char>` | Target eye style |
| `--hat <name>` | Target hat |
| `--shiny` | Require shiny |
| `--stat-floor <n>` | Require every stat to be at least `n` |
| `--limit <n>` | Number of matches to keep |
| `--tries <n>` | Search budget |
| `--seed-format <uuid|hex>` | Override seed format |

## Config Discovery

The tool looks for a Claude config in this order:

1. `BUDDY_ROLLER_CONFIG`
2. `CLAUDE_CONFIG_DIR/.claude.json`
3. `~/.claude.json`
4. `~/.claude/.claude.json`

## Seed Model

Buddy traits are derived deterministically from a single seed:

```text
seed + "friend-2026-401" -> Bun.hash (wyhash) -> SplitMix32 -> traits
```

The active seed comes from:

```text
oauthAccount.accountUuid ?? userID ?? "anon"
```

Only the buddy name and personality come from the LLM during `/buddy hatch`. The species, rarity, hat, eye style, shiny flag, and stat rolls are all seed-driven.

## Trait Palette

| Trait | Values |
|---|---|
| Species | duck, goose, blob, cat, dragon, octopus, owl, penguin, turtle, snail, ghost, axolotl, capybara, cactus, robot, rabbit, mushroom, chonk |
| Rarity | common, uncommon, rare, epic, legendary |
| Eyes | `·` `✦` `×` `◉` `@` `°` |
| Hats | none, crown, tophat, propeller, halo, wizard, beanie, tinyduck |
| Stats | DEBUGGING, PATIENCE, CHAOS, WISDOM, SNARK |

## Compatibility Aliases

The repo documents a new command shape, but it still accepts a few legacy aliases:

- `search` -> `hunt`
- `current` or `show` -> `inspect`
- `check` or `peek` -> `preview`
- `apply` or `write` -> `stamp`

## Notes

- Claude Code may refresh `oauthAccount.accountUuid` during auth updates, which can revert the buddy.
- The derivation logic here is based on Claude Code 2.1.89 behavior and may drift if Anthropic changes the salt or generation path.
- `stamp` always creates a timestamped backup before editing the config.

## License

MIT
