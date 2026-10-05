---
name: impact
version: 1
description: 基于当前 repository 调查一个拟议变化的真实影响范围，重点分析 change surface、数据链路、模块边界、ownership、lifecycle、持久化、API / contract、调度与兼容性传播；用于在实施前判断“这个变化实际上会牵动什么”，但不负责选择最终技术路线或生成 Implementation Plan。Agent 在表面改动范围可能低估真实传播时可以主动调用。
---

# Impact

Impact 是一次性的**实施影响调查动作**。

它回答：

> 如果要实现这个变化，当前系统实际上会被波及到哪里？

Impact 不负责决定最终怎样实现，也不负责拆分实施阶段。

它的职责是在进入 Implementation Plan 之前，把变化的真实传播范围和结构代价暴露出来。

# 什么时候使用

可以由用户显式调用：

```text
/impact
```

Agent 也可以主动调用，但只在表面改动范围可能明显低估真实影响时。

典型场景：

- 一个看似局部的需求可能跨越多个模块；
- 数据如何从入口传播到最终状态尚不清楚；
- ownership 或 lifecycle 可能发生变化；
- 持久化格式或恢复路径可能被影响；
- public API / internal contract 可能变化；
- 调度、缓存、渲染、异步流程等存在隐藏耦合；
- 当前架构是否能够自然承载该变化并不明确；
- 用户准备对齐 Plan，但还不知道实际实施代价来自哪里。

不要因为任务涉及代码就机械调用。

对于明确的局部、机械修改，没有必要进行完整 Impact 调查。

# Repository First

Impact 必须基于真实 repository，而不是只根据需求文字猜测。

调查范围围绕“变化如何传播”展开。

优先读取足以回答以下问题的真实实现：

- 变化从哪里进入系统；
- 数据或状态沿什么路径传播；
- 哪些模块拥有、变换或消费这些数据；
- 哪些边界被穿过；
- 哪些状态具有持久化、缓存或生命周期；
- 哪些 API / contract 将直接或间接受到影响；
- 哪些调度、异步或资源生命周期会被牵动；
- 哪些看似相关的部分实际上不会受到影响。

不要为了“理解整个项目”无边界搜索。

Impact 的目标是建立 change map，不是重建完整架构文档。

# 调查视角

Impact 重点检查以下传播维度。

## Change Surface

识别：

- 直接修改点；
- 被动传播到的模块；
- 需要同步变化的 contract；
- 可能被影响但尚未确定的区域；
- 明确不受影响的区域。

不要只按文件数量理解影响面。

一个只改两个文件的变化，也可能改变关键 ownership 或 lifecycle；
一个改十个文件的机械重命名，也可能仍然只是 Local change。

## Data Flow

如果任务涉及数据、状态或资源，应尽量说明当前链路和变化后的传播关系。

优先使用简单关系描述，例如：

```text
Input
  ↓
State owner
  ↓
Transform
  ↓
Consumer
  ↓
Persistence / Output
```

不要把调用栈逐函数抄出来。

目标是说明“变化从哪里传到哪里”。

## Boundary Crossing

识别变化是否穿过：

- module boundary；
- subsystem boundary；
- runtime / persistence boundary；
- CPU / GPU boundary；
- SDK / App boundary；
- sync / async boundary；
- ownership boundary；
- public / internal API boundary。

边界越多，不自动意味着方案越差，但通常意味着实施代价、协调成本和回归风险更高。

## Ownership / Lifecycle

如果变化会影响状态或资源，调查：

- 谁创建；
- 谁拥有；
- 谁更新；
- 谁销毁；
- 谁调度；
- 谁持久化或恢复。

很多“架构代价”并不来自代码量，而来自 ownership 或 lifecycle 被迫改变。

## Contract / Compatibility

检查变化是否影响：

- public API；
- internal contract；
- serialized format；
- persistence schema；
- caller assumptions；
- compatibility；
- migration；
- observable behavior。

不要因为现有 API 已经存在，就把它自动当成 Gate。
这里只描述变化影响，不决定是否必须保留。

# 架构影响

Impact 可以判断一个变化是否开始触及现有架构，但不要替 Implementation Plan 选择最终方案。

推荐使用以下定性层级：

```text
Local
→ 影响局部实现，不穿越重要边界。

Cross-module
→ 传播到多个模块，但仍沿现有结构自然传递。

Structural
→ 需要改变 ownership、lifecycle、data flow、contract 或 subsystem relationship。

Architectural
→ 当前抽象或系统边界本身与变化发生冲突，需要重新安排重要结构。
```

这个等级不是复杂度打分，也不是工时估计。

它只用于帮助理解变化的结构性质。

# 不估算伪精确工时

Impact 不默认输出：

- 几小时；
- 几天；
- story point；
- 预计代码行数；
- 以文件数量代替复杂度的估算。

如果需要描述实施代价，应解释代价来自哪里，例如：

- 跨越多个 ownership boundary；
- 需要修改持久化 contract；
- 当前调度模型与目标能力耦合；
- 同一状态存在多个消费者；
- 需要兼容旧数据；
- 当前抽象无法承载新的输出语义。

优先解释结构性成本，而不是生成看似精确的数字。

# 与 Impl Expand 的关系

`impact` 和 `impl-expand` 职责不同。

```text
impact
= 调查什么会改变，以及变化传播多远

impl-expand
= 基于已经理解的影响，决定具体怎样实现
```

Impact 可以发现存在多个明显不同的 change shape，例如：

```text
Route A
→ 沿现有结构传播
→ Cross-module

Route B
→ 改变 ownership / lifecycle
→ Structural
```

但 Impact 不应继续替用户或 `impl-expand` 选择最终路线并拆成 Phase。

如果当前影响调查已经足以支持后续规划，应在这里停止。

# 与认知模型的关系

Impact 不是 Intent / Gate / Impl / Debt 之外的第五个持续认知坐标。

它是一个一次性的分析动作。

```text
Intent / Gate / Impl / Debt
= 持续认知模型

Impact
= change propagation investigation
```

Impact 调查过程中仍应尊重这些语义区别。

特别是：

- 当前架构是 Impl，不天然是 Gate；
- 当前修改很麻烦，不代表不能修改；
- 发现结构代价，不代表必须立即解决所有相关问题；
- 不要把调查中看到的历史实现自动提升为永久约束。

# 输出

默认输出一份紧凑的 Change Map。

推荐结构：

# Impact

## Change

一句话说明准备改变什么。

## Current Path

只描述理解传播所需的当前数据流、调用流、ownership 或 lifecycle。

必要时优先画简单文本图，而不是逐文件流水账。

## Change Surface

说明：

- 直接影响；
- 传播影响；
- 需要跨越的边界；
- 明确不受影响的部分。

## Structural Consequences

只列出真正有结构意义的变化，例如：

- data flow；
- ownership；
- lifecycle；
- persistence；
- API / contract；
- scheduling；
- compatibility。

## Impact Level

`Local / Cross-module / Structural / Architectural`

并用一两句话解释为什么。

不要求机械填满所有小节。

对于局部变化，输出可以非常短。

# 不负责

Impact 不负责：

- 选择最终技术路线；
- 生成完整 Implementation Plan；
- 拆分 Phase；
- 修改代码；
- 执行测试；
- Review；
- Integration；
- 把所有潜在风险都升级为阻塞项；
- 把当前架构自动视为不可改变的约束；
- 进行与当前 change propagation 无关的全局架构审计。

# 核心原则

> **Impact 负责发现一个变化会触及什么、沿什么链路传播、是否穿过重要结构边界；它暴露 change shape，但不替 Implementation Plan 决定最终怎样实现。**
