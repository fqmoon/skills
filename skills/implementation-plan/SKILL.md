---
name: implementation-plan
version: 1
description: 将已经明确的需求、Gate、设计意图或高层 Plan，结合当前 repository 的真实实现，展开为可直接用于后续执行的具体实施方案；负责选择技术路线、确定主要修改范围与实施顺序，但不执行修改。
---

# Implementation Plan

将当前已经明确的目标、Gate、设计意图或高层 Plan，
结合 repository 的真实状态，展开为具体实施方案。

本 Skill 位于“需求 / Gate / Plan”与“执行”之间。

它负责回答：

> 在当前 repository 中，准备具体怎样实现？

它不负责重新定义需求，也不执行代码修改。

# 输入

输入不要求固定格式。

可以来自当前上下文中的：

- Requirement / Goal；
- Gate / Hard Constraints；
- 已确认的设计意图；
- 粗略 Plan；
- 用户明确指定的技术方向；
- 已知遗留问题。

如果其中只有一部分，也可以继续。

优先级：

1. Gate / Hard Constraints；
2. 明确 Requirement；
3. 已确认的 Plan / Design Intent；
4. 实现便利性。

较低优先级内容不得违反较高优先级内容。

# Repository First

实施方案必须基于真实 repository，而不是只根据输入文字推演。

在形成方案前，应调查与任务直接相关的：

- 当前实现；
- 数据结构；
- 调用路径；
- 模块责任；
- API / contract；
- 持久化格式；
- 测试与文档；
- 已存在的相关机制。

不要为了“完整了解项目”进行无边界调查。

只读取足以决定当前实施路线的上下文。

# 从抽象到具体

本 Skill 可以并且应该做技术决策。

Gate 刻意保持 solution space 开放；
Implementation Plan 则需要根据当前实现收缩 solution space，
选择一条具体且合理的实施路线。

可以确定：

- 总体技术路线；
- 需要修改、删除、替换或保留的机制；
- 主要模块和文件范围；
- 数据流与状态变化；
- 必要的 API / contract 变化；
- 数据迁移或兼容策略；
- 实施阶段及依赖顺序；
- 各阶段对应的 Gate；
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
- 如果不同选择会改变 Requirement、Gate 或用户可观察语义，
  则明确标记为需要用户决策；
- 如果只是局部实现差异，则留给执行阶段。

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

## Relevant Gate / Constraints

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

# 不负责

本 Skill 不负责：

- 修改代码；
- 创建 worktree；
- 调用 Subagent；
- 执行测试；
- Integration；
- Review；
- 重新定义 Gate；
- 把所有局部实现细节提前设计完。
