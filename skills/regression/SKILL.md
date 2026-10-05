---
name: regression
version: 1
description: 在实现完成或基本完成后，从当前真实结果出发，沿 Impl → Gate → Intent 反向回归，利用执行后才暴露的新事实重新判断原实现、约束与意图是否仍然成立。用于高不确定性任务、实现后发现结果与预期不完全一致、或需要把现实反馈回上层语义时。强烈建议在独立 Subagent、fresh context、context reset 或等价机制中执行。
---

# Regression

Regression 是一次性的 **back-bookend action**。

它不负责证明代码“正确”，也不是回归测试、普通 Review、验收清单或测试执行器。

它回答的是：

> 实现完成以后，带着现在已经知道的现实结果，沿 Impl → Gate → Intent 反向走回去，原来的高层理解还站得住吗？

Front bookend 将高层语义逐步压到可以执行：

```text
Intent
  ↓
Gate
  ↓
Impl
  ↓
Execution
```

Regression 反向回归：

```text
Reality
  ↑
Impl
  ↑
Gate
  ↑
Intent
```

重点不是“检查有没有按原计划做完”，而是利用执行后新增的事实，重新判断原先的 Impl、Gate 和 Intent 是否需要修正。

# 为什么需要 Regression

有些问题在执行前无法被完整理解。

真正实现之后，才可能暴露：

- 实际复杂度；
- 隐藏耦合；
- ownership 或 lifecycle 变化；
- 数据流或状态传播的真实形态；
- 性能与交互效果；
- 原先没有意识到的约束；
- 某个 Gate 过弱、过窄或定义错误；
- 原先对 Intent 的理解不够准确；
- 某个技术方向虽然能满足 Gate，但现实结果并不符合真正想要的方向。

因此，原始 Intent、Gate 和 Impl 都不是不可挑战的权威。

执行不仅产生结果，也产生新的知识。

Regression 的任务，是把这些知识反馈回上层语义。

# 核心路径

Regression 按以下方向重新建立判断：

```text
Reality
  ↓
Impl regression
  ↓
Gate regression
  ↓
Intent regression
```

这不是固定格式的报告流程，而是判断方向。

对于简单任务，如果 Reality 没有产生新的高层信息，可以非常简短地结束。

# 1. Reality

先恢复当前真实结果，而不是相信原 Plan、原实现描述或执行过程中的自我解释。

优先依据：

- 当前 repository；
- diff / changed files；
- 当前真实行为；
- 已有运行结果；
- 必要的测试结果；
- benchmark、截图、日志或其他直接证据；
- 执行过程中明确暴露的新事实。

重点寻找：

> 哪些事情，是执行前不知道、执行后才知道的？

不要为了 Regression 无边界重建整个项目。

只恢复足以重新判断 Impl、Gate 和 Intent 的现实。

# 2. Impl Regression

从 Reality 回看原先的 Implementation 判断。

检查：

- 原先的技术判断是否被现实证实；
- 实际 Implementation 是否与原计划发生重要偏移；
- 哪些假设被推翻；
- 是否出现新的结构成本；
- ownership、lifecycle、data flow、contract 或其他关键机制是否与原理解不同；
- 某个原本看似必要的技术方案是否被证明只是偶然选择；
- 是否发现更简单或更自然的实现方向。

这里的目标不是 Review 代码质量，而是回答：

> 现在看到真实实现后，我们对 Impl 的理解需要改吗？

# 3. Gate Regression

不要只问：

> 实现是否满足原 Gate？

还要问：

> 执行后的现实是否说明原 Gate 本身需要修正？

必须区分：

```text
Impl 不满足 Gate
→ execution problem

Impl 满足 Gate，
但 Reality 说明 Gate 太弱、太窄、遗漏关键条件或定义错误
→ gate problem
```

测试通过不能自动说明 Gate 正确。

Gate 也不是因为已经确认过，就不能被现实推翻。

如果执行后发现：

- Gate 无法区分真正好坏的结果；
- Gate 满足，但结果明显不符合预期；
- 原 Gate 隐含了错误前提；
- 新事实暴露了此前不存在的关键边界；

应明确指出 Gate 需要重新对齐。

# 4. Intent Regression

继续从 Gate 回到 Intent。

核心问题：

> 现在已经看到真实结果、真实代价、真实副作用和真实使用方式后，我们还认为原来的 Intent 是准确的吗？

允许出现：

```text
Impl 正确
Gate 正确
但 Intent 理解需要修正
```

也允许：

```text
Gate 被满足
但满足 Gate 的现实结果并不服务于原 Intent
```

或者：

```text
执行后发现原先真正想解决的问题其实不是这个
```

Intent regression 不要求强行改变 Intent。

如果原 Intent 仍然成立，应直接说明。

不要为了证明 Regression 有价值而制造新的高层解释。

# Context Isolation

Regression **强烈建议在独立或重置后的上下文中执行**。

优先使用：

- 独立 Subagent；
- 新会话；
- fresh context；
- context reset；
- handoff 到独立 Agent；
- 其他能够显著减少 implementation history 影响的机制。

原因：

执行上下文通常包含大量：

- 局部实现选择；
- 中途 workaround；
- 失败尝试；
- 临时解释；
- 已经接受的假设；
- 为推进任务形成的路径依赖；
- Agent 对自己 Implementation 的合理化。

这些信息对 Execution 有价值，但可能妨碍 Regression 重新建立判断。

Regression 需要的是：

> 从 Reality 出发重新建模，而不是延续 execution narrative。

使用独立上下文的目的不是制造“第二人格”，也不是进行多视角表演。

它的目的，是减少前一路径对当前判断的约束。

## 推荐输入

向独立 Agent / Subagent 提供足够但克制的材料：

- 原始 Intent；
- 原始 Gate；
- 必要的高层 Impl / Plan；
- 当前 repository / diff / result；
- 已知的执行后新事实。

不要默认注入完整执行聊天记录、全部失败尝试和长篇实现过程。

只有当某段执行历史本身是理解 Reality 的必要证据时，才补充它。

## 无法隔离上下文时

如果当前环境不支持 Subagent、context reset 或新会话，可以在当前 Agent 中执行 Regression。

但应显式：

- 不把执行过程中的旧判断当成权威；
- 不沿用原有自我解释；
- 重新从 Reality → Impl → Gate → Intent 建立判断；
- 优先依赖当前事实，而不是 implementation narrative。

# 主动调用

Agent **可以主动调用** `regression`，但只在执行后的现实可能改变上层理解时。

典型场景：

- 任务本来就具有较高不确定性；
- 实现过程中暴露了重要的新事实；
- 实际复杂度、结构代价或行为与预期明显不同；
- Gate 看似全部满足，但最终结果仍然“不对”；
- 某个方案只有做出来之后才能判断；
- 实现完成后发现原先的 Requirement / Gate / Intent 可能建模不准确；
- 需要决定下一轮应修 Impl、Gate 还是 Intent。

不要因为每次代码修改都机械调用。

对于明确、局部、机械、低不确定性的修改，Regression 通常没有额外价值。

# 与测试 / Verify 的关系

Regression 不是测试 Skill。

测试、类型检查、运行验证、benchmark 等都可以作为 Reality 的证据来源，但它们不是 Regression 的目标。

Regression 不负责提醒 Agent“应该按 Gate 实现”。

严格按 Gate 执行，本来就是 Execution 的职责。

Regression 关注的是：

> 经过真实实现以后，原先的 Gate 和 Intent 是否仍然值得保留。

因此：

```text
tests pass
≠
Gate 一定正确
≠
Intent 一定正确
```

# 与 Impact 的关系

`impact` 和 `regression` 分别位于执行的两侧。

```text
Impact
= 执行前，调查变化可能怎样传播

Regression
= 执行后，利用真实结果反向修正高层理解
```

可以理解为：

```text
Before:
Intent / Gate
    ↓
Impact
    ↓
Impl

After:
Reality
    ↑
Impl
    ↑
Gate
    ↑
Intent
Regression
```

Impact 关注未来的 change shape。

Regression 关注现实对原有 semantic model 的反馈。

两者不是固定 Workflow，也不要求每个任务都成对调用。

# 与 Premise / Bullshit 的关系

`premise` 负责恢复当前判断需要的最小共同前提。

`bullshit` 负责检查一个当前 mental model 是否站得住脚。

`regression` 则专门处理：

> 执行后新增的现实，是否反过来要求修正 Impl、Gate 或 Intent。

Regression 可以在过程中借用类似的判断方式，但不要退化成普通 premise recovery 或 mental-model review。

# 输出

默认只报告真正需要向上修正的内容。

推荐结构：

```markdown
# Regression

## Reality
执行后新增的、会影响上层判断的事实。

## Regressions
- Impl: 是否需要修正
- Gate: 是否需要修正
- Intent: 是否需要修正

## Convergence
下一轮应该保持现状、修 Impl、修 Gate，还是修 Intent。
```

不要求机械输出完整结构。

如果没有发现需要回归修正的内容，可以简短说明：

> 当前 Reality 没有暴露需要向上修正的新事实；现有 Impl、Gate 与 Intent 仍然一致。

# 不自动修复

Regression 默认只负责重新判断，不直接进入下一轮修改。

它可以指出：

- Impl 应如何重新考虑；
- Gate 哪些地方需要重新对齐；
- Intent 是否需要重新表述；
- 下一轮应该从哪一层重新开始。

但不要因为发现问题就：

- 自动修改代码；
- 自动重写 Intent；
- 自动更新 Gate；
- 自动扩大任务范围；
- 自动进入新的 Implementation Plan。

Back bookend 的职责，是恢复正确的高层理解。

后续是否继续修改，由用户或其他 Skill 决定。

# 不要做什么

- 不要把 Regression 做成 regression testing；
- 不要把测试通过当作完成条件；
- 不要默认原始 Intent / Gate / Plan 是权威；
- 不要只检查实现是否偏离 Plan；
- 不要为了完整而重新审计整个项目；
- 不要把执行过程中的路径依赖直接带入结论；
- 不要为了制造“独立意见”而进行没有意义的多 Agent 辩论；
- 不要把所有 Implementation 细节都上升为 Gate 或 Intent；
- 不要在没有新事实时强行修改高层理解；
- 不要自动修复发现的问题。

# 核心原则

> **Regression 从实现后的 Reality 出发，沿 Impl → Gate → Intent 逆向回归。**

> **不要假设原 Plan、Gate 或 Intent 必然正确；执行产生的新事实可以反过来修正它们。**

> **Regression 应尽可能在独立或重置后的上下文中执行。它不是 Execution 的继续，而是一次重新建模。**

> **目标不是证明任务完成，而是让下一轮建立在更接近现实的理解上。**
