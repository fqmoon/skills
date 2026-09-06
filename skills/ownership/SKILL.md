---
name: ownership
version: 1
description: 将任务按互斥 ownership 拆分，并在独立 Git worktree 与独立执行上下文中并行执行；仅汇总结果，不自动集成。
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

# 用途

对可以按 ownership 独立处理的任务进行一次性并行执行。

每个执行单元必须同时拥有：

- 独立 ownership；
- 独立 Git worktree；
- 独立执行上下文。

执行完成后，由当前主上下文统一读取真实修改并汇总。

本 Skill 只负责：

1. ownership 拆分；
2. 隔离执行；
3. 结果汇总。

不负责 Integration。

本 Skill 不依赖特定 Subagent、Agent、Workflow 或编排插件。

# 核心流程

1. 按 `OWNERSHIP.md` 分析当前任务。
2. 只确定：
   - 当前目标；
   - 必须满足的硬约束；
   - 可以独立处理的 ownership；
   - 每个 worker 的负责范围。
3. 如果不能形成至少两个适合独立执行的 ownership，则停止，并报告当前任务不适合使用本 Skill。
4. 按 `EXECUTION.md` 检查当前环境的隔离执行能力。
5. 如果不存在可用的独立上下文执行方式，则停止并报告失败。
6. 为各 ownership 创建独立 worktree。
7. 在独立上下文中并行执行各 worker。
8. 等待本轮全部 worker 完成或失败。
9. 主上下文读取各 worktree 的：
   - 实际代码；
   - Git diff；
   - commit；
   - 接口定义；
   - `WORKER_RESULT.md`。
10. 主上下文汇总：
    - 各 ownership 的实际修改；
    - 关键局部决策；
    - contract / API 变化；
    - 实际代码层面的不一致和冲突；
    - 需要人工判断的问题。
11. STOP，等待人工介入。

# Source of Truth

`WORKER_RESULT.md` 仅作为快速索引。

以下内容才是 source of truth：

1. 实际文件；
2. Git diff；
3. 接口定义；
4. commit。

如果 `WORKER_RESULT.md` 与真实修改不一致，以真实修改为准。

worker 的返回消息只代表执行状态，不代表执行结果。

# 强制停止

完成汇总后不得：

- merge；
- cherry-pick；
- rebase；
- 自动修改其他 worktree；
- 自动解决跨 ownership 冲突；
- 自动重新派遣 worker；
- 自动进入 Integration；
- 自动执行 repository-wide 修复。

即使所有修改看起来可以直接整合，也必须停止并等待人工介入。
