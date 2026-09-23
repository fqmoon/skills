---
name: impl
version: 1
description: 将 Implementation 作为当前实现手段的认知模型；用于区分技术选择、现有代码、历史 Plan 与真正的 Intent / Gate，避免把可替换的实现方案误当成永久需求。适合在讨论、设计、实现或 Review 中需要判断“这是手段还是约束”时主动调用。
---

# Impl

Impl 描述当前任务中**准备怎样实现，或系统现在怎样实现**。

它回答的是：

> 当前选择了什么手段？

而不是：

> 为什么要这样做？

也不是：

> 什么条件必须成立？

Impl 是当前对 solution space 的具体选择，但默认是可替换的。

# 什么属于 Impl

Impl 通常包括：

- 架构；
- 算法；
- 数据结构；
- class / module 划分；
- API 形状；
- 调用路径；
- 状态组织；
- 当前技术路线；
- 临时 workaround；
- 实施顺序；
- 为满足 Intent / Gate 而选择的具体机制。

例如：

> 使用 BVH 加速查询。

这是典型的 Impl。

它描述了当前采用的技术手段，但并不自动说明为什么必须使用 BVH。

# Impl 不是 Intent

Intent 描述方向、目标和取舍。

Impl 描述当前手段。

例如：

```text
Intent:
查询性能优先于实现简单性

Impl:
当前使用 BVH 加速查询
```

如果以后存在更合适的实现，只要仍符合 Intent，就可以替换 BVH。

需要理解“为什么做、什么更重要”时，使用 `intent` Skill。

# Impl 不是 Gate

Gate 描述所有可接受方案都必须满足的条件。

Impl 描述当前选中的一个方案。

判断一个决定是否只是 Impl，可以问：

> 如果完全换一种实现方式，只要最终结果仍然可接受，这个决定还能被替换吗？

如果答案是“可以”，它通常属于 Impl。

例如：

```text
Gate:
用户数据刷新后仍然存在

Impl:
当前使用 IndexedDB 持久化
```

IndexedDB 是实现手段，不应仅因为已经使用就升级为 Gate。

需要显式定义不可违反的边界时，使用 `gate` Skill。

# 现有代码属于事实，不属于权威

Repository 中已经存在的代码首先描述：

> 系统现在怎样实现。

它并不天然描述：

> 系统必须怎样实现。

因此不要自动把以下内容提升为 Gate 或 Intent：

- 已有 class；
- 当前 module 边界；
- 历史 API；
- 旧 Plan；
- 临时兼容代码；
- 曾经做出的技术选择；
- 只是因为当前 repository 结构而存在的限制。

这些内容可能产生迁移成本、兼容成本或真实外部约束，但需要分别判断。

# Impl 默认可替换

除非已有 Intent、Gate 或外部约束明确要求，否则 Implementation 默认可以被：

- 修改；
- 替换；
- 删除；
- 重构；
- 合并；
- 拆分。

一个 Implementation 已经完成，并不会因此获得更高的语义地位。

历史决定不等于永久决定。

# 多个 Impl 可以同时正确

同一个 Intent 和 Gate 可以对应多个不同的 Implementation。

```text
Intent + Gate
    ├── Impl A
    ├── Impl B
    └── Impl C
```

选择其中一个通常取决于：

- 当前 repository；
- 工程成本；
- 可逆性；
- 性能；
- 复杂度；
- 风险；
- 已知技术事实。

这些因素可以影响当前选择，但不要因此混淆三种语义。

# 允许重新分类

随着讨论和调查深入，一个原本被当成 Gate 的决定，可能被发现其实只是 Impl。

例如：

```text
“不能 full rebuild”
```

如果进一步发现真正要求只是：

```text
Intent:
保持 drawing 交互流畅

Gate:
绘制过程中不能出现不可接受的长帧
```

那么“不能 full rebuild”应该降回 Impl，而不是继续作为硬约束保存。

反过来，某个实现细节也可能暴露出此前没有明确表达的 Intent 或 Gate。

重新分类的目标是保持决策语义正确，而不是维护历史标签。

# 主动调用

Agent **可以主动调用** `impl`，但只在区分“实现手段”和“真正要求”会实质影响判断时。

典型场景：

- 当前 Plan 中包含大量具体技术决定；
- 现有代码正在被误认为不可改变的需求；
- Review 发现历史实现与新的 Intent 冲突；
- 用户准备推翻或替换已有架构；
- 某个所谓硬约束可能只是旧 Implementation；
- 存在多个可行技术路线，需要避免把当前选择永久化。

不要因为任务涉及代码就机械调用。

对于明确且局部的机械修改，没有必要额外强调 Impl 模型。

# 输出

默认静默使用。

不要每次都显式列出 Implementation。

只有当以下情况会帮助判断时，再显式指出：

- 某项要求其实只是 Impl；
- 某个历史实现不应继续作为约束；
- 多个 Impl 都能满足同一 Intent / Gate；
- 需要明确当前采用的技术方向。

# 与 impl-expand 的关系

`impl` 定义 Implementation 的认知语义。

`impl-expand` 则是在需要落地时，将已经明确的 Intent、Gate、Requirement 或高层 Impl 结合真实 repository，展开成具体 Implementation Plan。

两者不是同一个 Skill：

```text
impl
= 理解“什么是当前实现手段”

impl-expand
= 把当前理解展开成可执行实施方案
```

# 核心原则

> **Impl 是当前选择的手段，不是因为已经存在就必须继续存在的要求。**
