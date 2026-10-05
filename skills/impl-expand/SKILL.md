---
name: impl-expand
version: 2
description: 将已经明确的需求、Intent、Gate、高层 Impl 或 Plan，结合当前 repository 的真实实现与 change surface，展开为可直接用于后续执行的具体 Implementation Plan；在选择技术路线前先判断变化传播范围，必要时调用 impact 进行结构性调查，但不执行修改。
---

# Impl Expand

将当前已经明确的 Requirement、Intent、Gate、高层 Impl 或 Plan，
结合 repository 的真实状态，展开为具体实施方案。

本 Skill 负责回答：

> 在当前 repository 中，准备具体怎样实现？

它不负责重新定义 Intent 或 Gate，也不执行代码修改。

如果当前信息中混有“目标 / 约束 / 实现手段”，应尊重 `intent`、`gate`、`impl` 的语义区别，不要在展开过程中擅自把 Impl 提升为 Gate。

# 输入

输入不要求固定格式。

可以来自当前上下文中的：

- Requirement / Goal；
- Intent；
- Gate / Hard Constraints；
- 已确认的高层 Impl；
- 粗略 Plan；
- 用户明确指定的技术方向；
- 已知遗留问题。

如果其中只有一部分，也可以继续。

不要为了形式完整而强制补齐全部输入。

# Repository First

实施方案必须基于真实 repository，而不是只根据输入文字推演。

在选择 Implementation route 之前，先判断当前变化的 change surface 与传播范围。

首先进行轻量判断：

```text
change surface 是否明显局部？
    ├─ YES → 自行完成必要的最小调查，然后继续 impl-expand
    └─ NO / UNCERTAIN → 调用 impact
```

当变化明显局部、边界清楚、没有重要结构传播时，不要为了形式完整机械调用 `impact`。

当以下任一情况不清楚时，应调用 `impact` 先完成专门调查：

- 数据或状态如何跨模块传播；
- ownership 或 lifecycle 是否变化；
- 持久化或恢复路径是否受影响；
- public API / internal contract 是否变化；
- 调度、缓存、渲染或异步链路是否存在隐藏耦合；
- 表面修改范围是否明显低估真实 change surface；
- 当前架构是否能够自然承载该变化。

如果已有可靠、近期且与当前任务一致的 Impact 结果，应直接复用，不要重复调查。

`impact` 负责回答：

> 什么会改变，以及变化传播多远？

`impl-expand` 在此基础上继续回答：

> 基于这些影响，具体准备怎样实现？

不要为了“完整了解项目”进行无边界调查。

只读取足以决定当前实施路线的上下文；必要时可以在 Impact 结果之外补充局部 implementation-specific investigation。

# 从抽象到具体

本 Skill 可以并且应该做技术决策。

但技术决策应建立在已经理解 change surface 的基础上。

不要一边猜测影响范围，一边直接选择方案。

Intent 提供方向，Gate 划定可接受空间，Impl 表示当前技术选择；
`impl-expand` 则需要结合真实 repository 进一步收缩 solution space，
形成一条具体且合理的实施路线。

可以确定：

- 总体技术路线；
- 需要修改、删除、替换或保留的机制；
- 基于 Impact 结果确定主要模块和文件范围；
- 基于 Impact 结果决定数据流、状态、ownership 或 lifecycle 应怎样调整；
- 必要的 API / contract 变化；
- 数据迁移或兼容策略；
- 实施阶段及依赖顺序；
- 各阶段需要保持的 Gate；
- 已知风险与遗留问题。

# 不要过度设计

实施方案不是代码的文字转录。

只提前确定会显著影响执行方向、跨模块关系、
不可逆成本或 Gate 满足方式的决策。

以下内容通常留给执行阶段自行决定：

- 局部函数名；
- helper 的具体组织；
- 无跨模块影响的函数签名细节；
- 机械性代码修改；
- 可逆的局部实现选择；
- 执行者读取代码后即可可靠判断的细节。

原则：

> 确定执行者不能安全自行决定的内容；
> 将局部、可逆、低影响决策留给执行阶段。

# 不确定性

不要为了让 Plan 看起来完整而猜测。

对于实施前确实需要确定的问题：

- 先通过 repository 调查；
- 能通过现有上下文合理决定时，直接做出技术决策；
- 如果不同选择会改变 Requirement、Intent、Gate 或用户可观察语义，则明确暴露该决策；
- 如果只是局部 Impl 差异，则可以留给执行阶段。

# 分阶段

按真实技术依赖组织实施阶段，而不是为了形式平均拆分。

每个阶段建议描述：

## Phase N: <目标>

Purpose:
- 本阶段解决什么。

Changes:
- 主要修改内容；
- 涉及的 subsystem / 文件族；
- 关键数据流或 contract 变化。

Gate:
- 本阶段必须保持或实现哪些 Gate。

Notes:
- 关键技术决策；
- 与后续阶段的依赖；
- 明确暂不处理的问题。

阶段应尽可能形成可理解、可检查的中间状态，
但不要求每个阶段都能独立发布。

# 输出

输出一份面向执行 Agent 的 Implementation Plan。

推荐结构：

# Implementation Plan

## Goal

## Relevant Intent / Gate / Constraints

## Current State
只总结与本方案直接有关的 repository 现状。

## Technical Direction
说明选择的总体实现路线及关键原因。

## Phases

### Phase 1
...

### Phase 2
...

## Cross-cutting Changes
必要时记录跨阶段的数据结构、API、文档或测试变化。

## Deferred / Out of Scope
明确本轮不解决的事项。

## Execution Notes
仅记录执行阶段必须知道、但不值得独立形成 Phase 的事项。

# 与 Impact 的关系

`impl-expand` 不把 `impact` 当成固定仪式步骤，但必须先完成 impact 判断。

原则：

```text
Local and obvious
→ impl-expand 自行完成最小必要调查

Not obviously local / structurally uncertain
→ impact
→ consume Change Map
→ impl-expand
```

因此：

- Impact thinking 是形成 Implementation Plan 前的逻辑必经条件；
- `impact` Skill 是按需调用的专门调查动作；
- 不要因为存在 `impact` 就让每个局部任务多一层分析流程；
- 也不要在结构传播尚不清楚时跳过调查直接给出 Implementation Plan。

# 不负责

本 Skill 不负责：

- 修改代码；
- 创建 worktree；
- 调用 Subagent；
- 执行测试；
- Integration；
- Review；
- 重新定义 Intent；
- 重新定义 Gate；
- 把所有局部实现细节提前设计完。

# 核心原则

> **impl-expand 先确认变化传播范围已经足够清楚；局部变化自行完成最小调查，结构影响不明时调用 impact。随后基于这些事实选择技术路线并展开为具体 Implementation Plan。**
