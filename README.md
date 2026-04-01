# cc-buddy-roller

[English](README.en.md) | [简体中文](README.zh-CN.md)

A bilingual seed workshop for the virtual pet behind Claude Code's `/buddy` command.
一个给 Claude Code `/buddy` 命令里的电子宠物用的双语种子工作台。

## What You Get

- A guide-first CLI with `guide`, `hunt`, `inspect`, `preview`, and `stamp`
- Chinese and English output via `--lang en|zh`
- Safe config write-back with automatic backup files
- Split English and Chinese docs for cleaner GitHub browsing

## Quick Taste

```bash
curl -fsSL https://raw.githubusercontent.com/liuxiaopai-ai/cc-buddy-roller/main/install.sh | bash
cc-buddy-roller guide

# or run from a clone
bun buddy.mjs guide --lang zh
bun buddy.mjs hunt --species dragon --rarity legendary --shiny --limit 2
bun buddy.mjs inspect --lang en
```

## Runtime

This project requires [Bun](https://bun.sh) because Claude Code derives buddy traits with `Bun.hash`.
The one-line installer handles that automatically if Bun is missing.
For a normal macOS/Linux setup, users usually only need built-in `bash`, `curl`, and `tar`.

See the full docs in:

- [README.en.md](README.en.md)
- [README.zh-CN.md](README.zh-CN.md)
