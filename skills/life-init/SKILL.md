---
name: life-init
version: 1
description: 装配第二大脑：检查并补齐根目录、入口、git 与定时提交。可重入，写坏/换机重跑即可。
---

# Life Init

第二大脑（`~/life`）的**装配器**。

**它是一次性的动作，但必须可重复执行。** 换机器、配置丢了、git 仓库坏了、cron 被删了 —— 重跑一次就补齐。所以它写的是「**检查并补齐**」，不是「创建」。凡已存在的，跳过；缺什么补什么。

判定它做完的标准不是那几行命令跑完了，是：**`life-save` 能一路写到 commit 成功**。链条不通 = 没做完。

# 装配什么

| 步骤 | 检查什么 | 缺了就补 |
|---|---|---|
| 1. 根目录 | `$LIFE_ROOT`（默认 `~/life`）存在 | 建目录 + `refer/` + `archive/` |
| 2. 入口 | `<root>/README.md` 存在且含下面那 7 条规矩 | 写入口（只创建，不覆盖） |
| 3. git | `<root>/.git` 存在且有至少一次 commit | `git init` + `.gitignore` + 首次 commit |
| 4. 定时提交 | 名为 `life 自动提交` 的 cron 存在 | 装兜底脚本 + 注册 cron |
| 5. 自检 | 上面四项都过 | 报告缺哪个 |

**它只管三件东西：目录、git、cron。** 内容从哪来、要不要搬旧东西，不关它的事 —— 见「不负责」。

# 入口 README

**立意与规矩的落点是入口 README，不是 SKILL.md。** `life-load` 每次只读入口；写在 SKILL.md 开头的立意、只存在于 skill 里的规矩，**进不了装载路径**，等于没写。改立意 = 改 README（换树时先让它可重建），SKILL.md 只指路。

`LIFE_ROOT` 未设置时用 `~/life`。环境里若还残留 `MEMO_ROOT`，说明是旧树的变量，**报告出来，不要静默采用**。

模板（与现网 `~/life/README.md` 保持一致；改一边必须改另一边）：

```markdown
# Life

第二大脑。这是**判据集**，不是档案。

## 规矩

1. 它是判据集不是档案：只留转折点，不留全集。
2. 主体是**你**，这是**上位**层：项目资料也在内 —— 因为它代表「我的人生里做过这个」。判据不是「跨不跨项目」，而是**「五年后的我，会不会为了理解自己而翻它」**。会 → 进这里，粒度是「我做过什么、学到什么」；不会（纯配置值、纯进度）→ 留在项目里（intent / ADR / progress / debt）。
   **主语判据：每条的主语必须是「我」。** 主语是项目/模块/系统 → 那是项目文档，不是这里；出现项目名字不违规，它只是场景。
3. 条目写**判据**不写**记录**：「遇到 X 先看 Z」省一次决策，「我把 X 改成 Y」只省一次检索。
4. 入树门槛：只有「下次遇到我会因此做错一件事」的才进。
5. **正文是当前状态，不是日记**：任何时刻读它，读到的都是「我现在相信什么」，不含时间线。时间线归 git —— `git log` 就是日记。条目上的日期是这条**最近一次确认的时间**（新鲜度），不是事件发生的时间。
   推论：同一件事只能有一条说法，出现两条就是状态不一致（bug），必须合并。
6. 改与删先告知（git 可回滚，所以是告知与确认，不是审批）。
7. 优化命中率不是完整度：二十条每次都被读到，胜过两百条烂在盘上。

## 索引

| 文件 | 内容 |
|---|---|
| — | — |

## 最近变化

- —

## 说明

- `refer/` 是原始材料快照（带日期）；没被任何条目引用的是孤儿。
- `hits.md` 是装载痕迹（`life-load` 维护），可选，只用于分析**入口描述写得好不好**。
- `archive/` 是移出检索范围的内容 —— 装载不读它，索引不列它。
```

# git

**必须显式传身份**，不依赖 `~/.gitconfig` —— cron 环境下没有全局身份，会静默失败：

```bash
git -C "$ROOT" -c user.name=life -c user.email=life@localhost commit -m "..."
```

`.gitignore` 至少含：`*.swp`、`.DS_Store`。

**远端是必需项** —— 提交与推送都由 cron 负责（`life-save` 只写盘），所以没有远端时「防丢」这半边是空的。

- 私有仓库，默认 `fqmoon/life`：
  ```bash
  gh repo create fqmoon/life --private --source="$ROOT" --remote=origin --push
  ```
- 凭据走 `gh auth git-credential`（`gh auth setup-git` 一次即可）。**push 前先确认树里没有凭据值** —— 只记位置可以（`~/.cloudflared/...`），记值不行。
- 远端是**私有不等于安全**：一推上去就随历史走，删要重写历史。所以不确定的东西别推。

# 定时推送

**只有一条 job：每天 06:00，纯脚本，不经过模型，不花钱。**

- **它只 push，不 commit** —— commit 归 `life-save`（写的时候才知道「为什么」）；
- 没有本地领先 → 静默；没有远端 → 静默；push 失败 → 非 0 退出 + 失败直达用户。

脚本 `~/.hermes/scripts/life_push.sh`：

```bash
#!/usr/bin/env bash
set -u
ROOT="${LIFE_ROOT:-$HOME/life}"
[ -d "$ROOT/.git" ] || exit 0
git -C "$ROOT" remote get-url origin >/dev/null 2>&1 || exit 0
out=$(git -C "$ROOT" -c user.name=life -c user.email=life@localhost \
        -c core.quotepath=false push -q origin HEAD 2>&1) || {
  echo "[life] push 失败：$out"; exit 1; }
```

注册：

```bash
hermes cron create "0 6 * * *" --name "life 推送" --no-agent \
  --script life_push.sh --deliver local --failure-deliver origin
```

- `--no-agent`：只是推一下，没必要叫模型；
- `--deliver local`：正常不打扰；
- `--failure-deliver origin`：**push 失败必须让人知道** —— 否则它每天静默失败，你以为在备份；
- **cron 挂在注册它时的那个 profile 下**。换 profile / 新开 profile 时这条不会跟着走，重跑本 skill 补齐。

# 不负责

- 不写结论（那是 `life-save`）；
- 不改写结论、不删条目；
- 不迁移旧内容（一次性的人工动作，不固化进 skill）；
- 不擅自创建远端仓库（对外可见，动前一并确认仓库名与可见性）；
- 不删旧树与旧 skill。

# 核心原则

> **检查并补齐：根目录、入口、git、兜底提交 —— 重跑任意次结果相同。**
