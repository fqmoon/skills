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

`LIFE_ROOT` 未设置时用 `~/life`。环境里若还残留 `MEMO_ROOT`，说明是旧树的变量，**报告出来，不要静默采用**。

```markdown
# Life

第二大脑。这是**判据集**，不是档案。

## 规矩

1. 它是判据集不是档案：只留转折点，不留全集。
2. 主体是**你**，不是项目：换个项目还成立 → 进这里；不成立 → 留在项目里（intent / ADR / progress / debt）。
3. 条目写**判据**不写**记录**：「遇到 X 先看 Z」省一次决策，「我把 X 改成 Y」只省一次检索。
4. 入树门槛：只有「下次遇到我会因此做错一件事」的才进。
5. 只留当前有效结论，不留「曾经认为 X」。演变由 git 承载，正文不留墓碑。
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

# 定时提交（兜底）

**消息格式：第一行一句话，其后分条。**

```text
改：`life-load` 检查项加了「状态打架」这一条
- 同一件事两处说法不再放过，按状态不一致处理
- 顺带把「不是日记」拆成独立检查项
- 文件：README.md
```

- 第一行是**主题**（一句话说这次改了什么），所以 `git log --oneline` 就是一份可读的历史；
- 后面分条，**每条说一件事**，不要写成文件清单；
- 末行「文件：」由脚本追加，不用手写；
- 消息由 `life-save` 收尾时写进 `<root>/.commit-msg`（**不进版本库**，已在 `.gitignore`），cron 提交时读取并删除；
- 没有 `.commit-msg` 时（手工改文件、迁移等），脚本自造一句 `auto: 改动 N 个文件`，正文照样列文件。

**提交与推送的唯一入口就是这里。** `life-save` 只写盘不提交，靠这条每天把当天的改动收进去。代价是消息只有文件清单、没有理由 —— 理由落在每次的收尾汇报里。

脚本放 `~/.hermes/scripts/life_auto_commit.sh`：

```bash
#!/usr/bin/env bash
# life 自动提交 + 推送：版本管理唯一的入口。
# life-save 只写盘、只预备消息（.commit-msg），不提交。
# 消息格式：第一行一句话，其后分条 —— 让 git log 直接可当历史读。
# 无改动 = 静默；失败 = 非 0 退出（让 cron 报警，而不是静默烂掉）。
set -u
ROOT="${LIFE_ROOT:-$HOME/life}"
[ -d "$ROOT/.git" ] || exit 0

gc() { git -C "$ROOT" -c user.name=life -c user.email=life@localhost -c core.quotepath=false "$@"; }

# 1. 暂存；无改动就静默（顺手清掉可能过期的待提交消息）
gc add -A
if gc diff --cached --quiet; then
  rm -f "$ROOT/.commit-msg"
  exit 0
fi

# 2. 取消息：life-save 预备的 .commit-msg，缺省时自动生成一句话
MSG="$ROOT/.commit-msg"
if [ -s "$MSG" ]; then
  subject=$(head -n 1 "$MSG" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  body=$(tail -n +2 "$MSG")
else
  n=$(gc diff --cached --name-only | wc -l | tr -d ' ')
  subject="auto: 改动 ${n} 个文件"
  body=""
fi

# 3. 正文永远带上文件清单（分条）
files=$(gc diff --cached --name-only | sed 's/^/- 文件：/')
commit_body=$(printf '%s\n%s\n' "$body" "$files" | sed '/^[[:space:]]*$/d')

if ! gc commit -q -m "$subject" -m "$commit_body"; then
  echo "[life] commit 失败：$subject"
  exit 1
fi
rm -f "$MSG"
echo "[life] commit: $subject"

# 4. 有远端就推（本地领先也推，兜住上次推送失败）
if gc remote get-url origin >/dev/null 2>&1; then
  if ! out=$(gc push -q origin HEAD 2>&1); then
    echo "[life] push 失败：$out"
    exit 1
  fi
fi

exit 0
```

现成的脚本在 `~/.hermes/scripts/life_auto_commit.sh`，不要重写，只补缺。

注册（`--no-agent`，不经 LLM，不花钱）：

```bash
hermes cron create "0 6 * * *" --name "life 自动提交" --no-agent \
  --script life_auto_commit.sh --deliver local --failure-deliver origin
```

- `--deliver local`：正常跑不打扰；
- `--failure-deliver origin`：**push 失败必须让人知道** —— 否则它会每天静默失败，你以为在备份；
- **cron 挂在注册它时的那个 profile 下**。现在只有 `default`，换 profile / 新开 profile 时这条不会跟着走，重跑本 skill 补齐。

# 不负责

- 不写结论（那是 `life-save`）；
- 不改写结论、不删条目；
- 不迁移旧内容（一次性的人工动作，不固化进 skill）；
- 不配远端（要用户当场拍板）；
- 不删旧树与旧 skill。

# 核心原则

> **检查并补齐：根目录、入口、git、兜底提交 —— 重跑任意次结果相同。**
