# cc-buddy-roller

```
  ╭──────────────────────────────────╮
  │  🎰  CC Buddy Roller  🎰        │
  │  抽到心仪的那只为止。              │
  ╰──────────────────────────────────╯
```

> Claude Code 的 `/buddy` 宠物**不是随机的**——它由一个确定性种子生成。只要找到对的种子，你就能拥有任何你想要的宠物。这个工具帮你从几百万个种子里搜出你的"天命之宠"。

## 为什么需要这个

在 Claude Code 里敲 `/buddy`，你的宠物的物种、稀有度、帽子、眼睛、闪光状态和属性值，全部由一个种子字符串决定。默认种子是你的 `oauthAccount.accountUuid`——换句话说，你的宠物从注册那一刻就定了。

**cc-buddy-roller** 让你可以：
- 🔍 按条件搜索能出你想要特征的种子
- 👀 写入前先预览效果
- ✍️ 一键写入配置（自动备份，安全无忧）
- 🌐 中英文界面随意切换

简单说：**这是一个宠物抽卡器**，但你不用删号重来。

## 安装

### 一键安装（推荐）

```bash
curl -fsSL https://github.com/liuxiaopai-ai/cc-buddy-roller/raw/refs/heads/main/install.sh | bash
cc-buddy-roller guide
```

**系统要求：** 只需要 `bash`、`curl`、`tar`——安装脚本会自动搞定 Bun。

如果装完在当前终端找不到 `cc-buddy-roller`，开个新终端，或者先执行：

```bash
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
```

想更新？再跑一遍安装命令就行。

### 手动安装

需要先装 [Bun](https://bun.sh)（不能用 Node.js——Claude Code 内部用的是 `Bun.hash`）。

```bash
curl -fsSL https://bun.sh/install | bash
git clone https://github.com/liuxiaopai-ai/cc-buddy-roller.git
cd cc-buddy-roller
bun buddy.mjs guide
```

## 命令一览

### `guide` — 交互式抽卡

推荐的入门方式。带你选筛选条件、跑搜索、看结果、决定要不要写入。

```bash
cc-buddy-roller guide
```

### `hunt` — 直接搜

跳过交互，直接按参数搜索。

```bash
# 搜一只闪光传说龙
cc-buddy-roller hunt --species dragon --rarity legendary --shiny

# 史诗稀有度，所有属性不低于 40
cc-buddy-roller hunt --rarity epic --stat-floor 40

# 保留 5 个结果慢慢挑
cc-buddy-roller hunt --species cat --rarity rare --limit 5
```

### `inspect` — 看看当前宠物

显示你的配置路径、当前种子、以及这个种子对应的宠物。

```bash
cc-buddy-roller inspect
```

### `preview` — 先看后买

输入任意种子，看看会出什么宠物，不动你的配置。

```bash
cc-buddy-roller preview 9ab738bf-fb82-40fb-917d-0020259c8408
```

### `stamp` — 写入种子

先自动备份你的配置，然后把种子写进去。

```bash
cc-buddy-roller stamp f853b71e-3774-4bc7-b4a8-4cc0ed266f9f
```

## 搜索参数

| 参数 | 说明 |
|---|---|
| `--species <name>` | 指定物种（如 `dragon`、`cat`、`axolotl`） |
| `--rarity <tier>` | 指定稀有度（`common`、`uncommon`、`rare`、`epic`、`legendary`） |
| `--eye <char>` | 指定眼睛样式（`·` `✦` `×` `◉` `@` `°`） |
| `--hat <name>` | 指定帽子（`crown`、`wizard`、`halo` 等） |
| `--shiny` | 要求闪光 |
| `--stat-floor <n>` | 每项属性都不低于这个值 |
| `--limit <n>` | 保留几个结果（默认 1） |
| `--tries <n>` | 搜索预算——最多试多少个种子 |
| `--seed-format <uuid\|hex>` | 手动指定种子格式 |

## 语言切换

```bash
cc-buddy-roller guide --lang zh    # 中文
cc-buddy-roller guide --lang en    # 英文
cc-buddy-roller guide --lang auto  # 自动检测
```

## 卡池一览

| 特征 | 可能的值 |
|---|---|
| **物种** | duck, goose, blob, cat, dragon, octopus, owl, penguin, turtle, snail, ghost, axolotl, capybara, cactus, robot, rabbit, mushroom, chonk |
| **稀有度** | common (60%), uncommon (25%), rare (10%), epic (4%), legendary (1%) |
| **眼睛** | `·` `✦` `×` `◉` `@` `°` |
| **帽子** | none, crown, tophat, propeller, halo, wizard, beanie, tinyduck |
| **属性** | DEBUGGING, PATIENCE, CHAOS, WISDOM, SNARK |
| **闪光** | 有 / 无 |

## 原理

宠物特征是**确定性**的——同一个种子永远出同一只宠物。

```
seed + "friend-2026-401" → Bun.hash (wyhash) → SplitMix32 伪随机数 → 特征
```

默认种子来自你的 Claude 配置：

```
oauthAccount.accountUuid ?? userID ?? "anon"
```

只有宠物的**名字**和**性格**由 `/buddy hatch` 时的 LLM 生成。物种、稀有度、帽子、眼睛、闪光、属性值——全都是种子决定的。

## 配置文件查找顺序

工具按以下顺序查找你的 Claude 配置：

1. `$BUDDY_ROLLER_CONFIG`（环境变量覆盖）
2. `$CLAUDE_CONFIG_DIR/.claude.json`
3. `~/.claude.json`
4. `~/.claude/.claude.json`

## 旧命令兼容

如果你看过早期文档，这些旧命令还能用：

| 旧命令 | 新命令 |
|---|---|
| `search` | `hunt` |
| `current`、`show` | `inspect` |
| `check`、`peek` | `preview` |
| `apply`、`write` | `stamp` |

## 注意事项

- Claude Code 在认证刷新时可能重写 `oauthAccount.accountUuid`，宠物会恢复原样。再 `stamp` 一次就好。
- 派生逻辑基于 Claude Code **2.1.89**。如果 Anthropic 改了盐值或生成流程，结果会变。
- `stamp` 在动你的配置之前，一定会先生成带时间戳的备份。

## License

MIT
