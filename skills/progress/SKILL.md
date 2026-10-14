---
name: progress
version: 1
description: 将当前执行阶段的真实进展同步到项目中的 Execution Plan；在阶段任务完成、进入或结束人工验收以及回复用户前存在未登记的阶段性进展时主动执行，也可由用户手动调用 /progress。
---

# Progress

Progress 是一次性的执行式状态同步 Action，不是项目管理器、调度器或重新规划器。

目标：**Persist execution state, not execution history.**

将下一次执行所需的最小状态原地写入已有 Execution Plan，降低跨会话、跨 Agent 的恢复成本。只记录可确认的结果、剩余工作、阻塞和下一步，不编造进度，不复制完整对话或工具日志。

# 定位 Plan

1. 优先使用用户明确指定的 Plan 路径。
2. 其次遵循项目已有的 Execution Plan 路径约定。
3. 默认查找 `<repo>/docs/progress/<task-slug>.md`，并依据当前任务及上下文确认具体文件。

优先沿用当前会话或任务中已经确定的 Plan 路径，不因执行 Progress 而另建文件或迁移目录。

若存在多个候选 Plan，必须根据当前任务确认对应文件，不要猜测后写错。找不到对应 Plan 时，说明无法定位并请求路径；**Progress 不凭空创建 Execution Plan**。

# 主动触发

出现下列事件时，应主动同步到 Plan：

- Agent 完成任何有实际结果的阶段性任务或 Phase；
- Agent 完成当前阶段的工作、即将交给用户人工验收；
- 人工验收完成，用户明确通过、拒绝或提出返工要求；
- Agent 准备返回用户前，若本轮存在尚未登记的阶段性进展，先同步再回复。

可由用户手动调用 `/progress`，立即同步当前可确认的执行状态。

**不是每次回复都写入**：没有状态变化时无需改动文件；同一阶段的连续小操作不必制造重复条目。阶段是技术上的可检查里程碑，不要求为 Progress 强行切分 Agent 会话或执行流程。

# 状态

每个 Phase 只需使用适用的简单状态：

- `pending`：尚未开始；
- `in-progress`：正在实施；
- `awaiting-human`：Agent 部分已经交付，但仍待必要的人工验收；
- `rework`：已知未通过验收或需要返工；
- `done`：该阶段要求的验收已满足。

不要把“代码已写完”“自测通过”自动等同于人工验收通过。若阶段明确需要人工验收，只有用户确认后才能标记为 `done`。不需要人工验收的阶段，可根据可核对的完成条件标记为 `done`。

# 执行动作

1. 定位当前 Plan 和相关 Phase，阅读已有的目标、Gate 与进度。
2. 结合当前执行上下文，以及必要时最小范围的文件、diff、测试或用户验收反馈，核对实际进展；不要为写进度而重新调查整个项目。
3. 原地更新对应 Phase 的 Status、实际 Result / Evidence、Remaining / Blocker（仅在有内容时），并更新 Plan 顶部的 Current / Next 摘要。
4. 保留原有目标、技术路线、Phase 和 Gate；若发现计划与 Reality 冲突，仅记录重要偏差和待决事项，不擅自重新规划。
5. 仅在发生实质变化时写入。回复用户时简洁报告已登记状态与下一步；若写入失败则如实说明，不宣称已经持久化。

写入内容应短小、可供下一个 Agent 直接恢复。尤其要说明接下来做什么、哪些验收仍未完成。不要引入完成百分比、工作日报或冗长时间线。

# 建议格式

沿用现有 Plan 结构；若尚无进度区，可在顶部加入：

```markdown
## Progress
- Current: Phase 2
- Next: 验证旧数据兼容性
- Blocker: 无

## Phases

### Phase 1: ...
Status: done
Result:
- 已完成结构调整，相关测试通过

### Phase 2: ...
Status: awaiting-human
Result:
- 新写入路径已完成并自测
Remaining:
- 人工验收迁移结果
```

这只是轻量建议，不要求改写既有格式。没有必要为空字段写占位内容。

# 边界

- 不创建新的执行计划，不负责初始拆分阶段；由 `concretize` 负责。
- 不重新定义 Intent、Gate 或重要 Impl 决策；出现重大偏差时先暴露，必要时另行修订 Plan。
- 不自动启动新 Phase、测试、Review 或 Subagent。
- 不因为记录阶段完成就强迫当前 Agent 暂停或重启。
- 不能用进度文档替代 repository 的真实事实；恢复时仍需核查必要证据。
- 不能代替 `regress` 的执行后语义回归。

# 核心原则

> **只同步可确认的执行状态，让下一次执行知道当前在哪里、下一步是什么；保持执行连续，不制造额外交接。**
