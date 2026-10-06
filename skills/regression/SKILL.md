---
name: regression
version: 1
description: 在实现完成或基本完成后，从最终 Reality 盲重建其实际体现的 Intent / Gate / Impl，再由保留原始上下文的主 Agent 与原始理解进行回归比对；当实际实现复杂、影响面广、跨越多个结构边界，或执行后可能发生语义漂移时主动调用。
---

# Regression

Regression 是一次性的 **back-bookend action**。

它不负责证明代码“正确”，也不是回归测试、普通 Review、验收清单或测试执行器。

它回答的是：

> 如果一个不知道原始 Intent 的独立观察者只看到最终结果，会认为这个实现到底在解决什么问题、保护什么边界、体现什么优先级？它重建出来的理解，和最初的 Intent / Gate 是否还是同一件事？

Front bookend 将高层语义逐步压到可以执行：

```text
Intent
  ↓
Gate
  ↓
Impl
  ↓
Execution
  ↓
Reality
```

Regression 做一次语义 round-trip：

```text
Original Intent / Gate
        │
        │ kept by Main Agent
        ▼
      Execution
        ↓
      Reality
        │
        │ blind reconstruction
        ▼
Reconstructed Intent / Gate / Impl
        │
        ▼
Main Agent compares both sides
```

重点不是“检查有没有按原计划做完”，而是检查：

> 经过真实实现以后，原来的高层语义是否仍然能从结果中被读回来。

# 为什么需要 Regression

实现过程会产生路径依赖。

Agent 在执行时会逐渐接受：

- 局部实现选择；
- workaround；
- 新增假设；
- 结构妥协；
- 为了推进任务形成的临时解释；
- 对自己 Implementation 的合理化。

这些东西可能都很合理，但累计起来以后，最终实现可能已经服务于另一个问题。

普通 Verify 通常沿着：

```text
Requirement / Gate
        ↓
Implementation
```

检查实现是否满足已知要求。

Regression 故意反过来：

```text
Implementation / Reality
        ↓
Reconstructed Intent
        ↓
compare with
        ↓
Original Intent
```

如果最终实现真的保留了原始重点，那么在不知道原答案的情况下，也应该能够从 Reality 中大致重建出来。

反之：

- 原始重点消失；
- 优先级被倒置；
- 某个约束变成实现手段；
- 某个实现手段反而变成核心目标；
- 新增目标悄悄取代原目标；

都属于值得报告的 regression。

# 核心原则：Blind Reconstruction

Regression 的独立 evaluator **不应知道原始 Intent、Gate、Plan 或 Requirement discussion**。

这不是信息缺失，而是测量方法的一部分。

独立 evaluator 的任务不是：

> 猜开发者原来想做什么。

而是：

> 只根据最终 Reality，描述这个系统现在实际体现了什么 Intent、约束、优先级和边界。

因此：

```text
Unknown original intent
        +
Final artifact / behavior
        ↓
Reconstructed semantic model
```

然后由仍然保留原始上下文的 Main Agent 做真正的 Regression。

# 1. Reality

独立 evaluator 先恢复当前真实结果，而不是相信执行过程中的解释。

优先依据：

- 当前 repository；
- 当前真实行为；
- 当前架构与数据流；
- 已有运行结果；
- 必要的测试结果；
- benchmark、截图、日志或其他直接证据；
- 必要时的 diff。

重点不是无边界重建整个项目，而是理解：

> 最终结果实际上在做什么？

只恢复足以重建 Intent / Gate / Impl 的 Reality。

# 2. Reconstruct Impl

先回答最终实现采取了什么主要结构和机制。

只保留会影响高层语义的内容，例如：

- ownership；
- lifecycle；
- data flow；
- state propagation；
- contract；
- 主要结构边界；
- 关键 trade-off。

不要把 Regression 退化成代码 Review。

这里的目标不是评价实现质量，而是建立后续语义重建所需的最小技术模型。

# 3. Reconstruct Gate

根据 Reality 反推出这个实现实际上在保护什么条件。

例如：

- 哪些行为明显被当作必须保持；
- 哪些边界被结构性保护；
- 哪些失败被明确避免；
- 哪些条件只是次要考虑；
- 哪些原本可能重要的条件在最终结果中几乎看不出来。

不要引用原始 Gate。

独立 evaluator 应只报告：

> 从结果来看，这个实现似乎把什么当成“不能错”的东西？

# 4. Reconstruct Intent

继续向上重建最终结果体现的 Intent。

核心问题：

> 如果只看到现在这个结果，它最像是在解决什么问题？

应尽量给出：

```text
Primary intent
Important constraints
Apparent priorities
Likely non-goals
Ambiguities
```

保持抽象和简短。

不要因为看到某段代码，就发明一个宏大的产品哲学。

不要从 commit message、原始需求、历史对话或 Plan 中偷看答案。

# Context Isolation

Regression **强烈建议使用独立 Subagent、新会话、fresh context、context reset 或等价机制执行 blind reconstruction**。

这里的隔离不是为了制造“第二人格”，也不只是为了减少 implementation history 的噪声。

更重要的原因是：

> **不知道原始 Intent，本身就是 Regression 的测量条件。**

如果 evaluator 已经知道原始 Intent，它很容易围绕已知答案解释最终实现，Regression 就会退化成普通确认。

## 给独立 evaluator 的输入

应提供：

- 当前 repository / final artifact；
- 当前真实行为；
- 必要的运行证据；
- 必要时的 diff；
- 为理解最终状态所必需的环境事实。

默认不要提供：

- 原始 Intent；
- 原始 Gate；
- Require 对话；
- approved Plan；
- handoff 中的目标描述；
- commit message 中的目标说明；
- 完整 implementation history；
- 执行过程中的自我解释。

最终文档如果直接陈述“本功能旨在……”，也应谨慎使用，因为它可能把原始 Intent 重新注入 evaluator。

## 无法隔离上下文时

如果当前环境不支持 Subagent、context reset 或新会话，可以在当前 Agent 中执行降级版 Regression。

但必须显式分离两个阶段：

1. 暂时忽略原始 Intent / Gate，仅从 Reality 重建当前语义；
2. 完成重建后，再恢复原始上下文做比对。

如果做不到真正的信息隔离，应承认这是较弱的 Regression，而不是假装 blind reconstruction 没有被污染。

# 5. Main-Agent Regression

真正的 Regression 在 Main Agent 中发生。

Main Agent 同时拥有：

```text
Original Intent / Gate
        +
Reconstructed Intent / Gate / Impl
```

然后做语义比对。

重点分类：

```text
Preserved
Lost
Mutated
Added
Ambiguous
```

## Preserved

原始重点仍然能从最终结果中清楚读出。

## Lost

原始 Intent / Gate 中的重要内容，在重建结果中消失。

这通常意味着它没有真正进入最终 artifact，或者已经弱化到不可见。

## Mutated

某个原始概念仍然存在，但意义、优先级或作用发生变化。

例如：

```text
Original:
独立视图是核心，同步只是便利能力

Reconstructed:
统一同步是核心，独立视图只是例外
```

这种 drift 往往比完全遗漏更危险。

## Added

最终实现体现了原始 Intent 中不存在的新目标或新约束。

Added 不自动等于错误。

它可能是执行后发现的合理新事实，也可能是实现路径反客为主。

## Ambiguous

Reality 无法稳定支持某个高层判断。

不要为了让报告完整而强行判定。

# 主动调用

Agent **可以主动调用** `regression`，但只在执行后存在语义漂移风险时。

典型场景：

- 实际实现复杂、影响面广；
- 跨越多个结构边界；
- 实现过程经历了较多局部决策或 workaround；
- 最终结果虽然工作，但已经很难一句话说明它服务的原目标；
- Gate 看似全部满足，但整体感觉“不对”；
- 某个方案只有做出来之后才能判断；
- 执行后出现了会改变原判断的新事实；
- 需要判断下一轮应该修 Impl、Gate 还是 Intent。

对于明确、局部、机械、低不确定性的修改，不要机械调用。

# 与测试 / Verify 的关系

Regression 不是测试 Skill。

测试、类型检查、运行验证、benchmark 等都可以作为 Reality 的证据来源，但它们不是 Regression 的目标。

Verify 更接近：

```text
Known requirement
      ↓
Does implementation satisfy it?
```

Regression 更接近：

```text
Final implementation
      ↓
What requirement does it appear to embody?
      ↓
Is that still the original one?
```

因此：

```text
tests pass
≠
Gate preserved
≠
Intent preserved
```

# 与 Impact 的关系

`impact` 和 `regression` 分别位于执行的两侧。

```text
Impact
= 执行前，调查变化可能怎样传播

Regression
= 执行后，从最终结果重建语义，再与原始语义比对
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
    ↓
Blind reconstruction
    ↓
Reconstructed Intent / Gate
    ↓
Compare with original
```

两者不是固定 Workflow，也不要求每个任务都成对调用。

# 与 Premise / Bullshit 的关系

`premise` 负责恢复当前判断需要的最小共同前提。

`bullshit` 负责检查一个当前 mental model 是否站得住脚。

`regression` 则专门处理：

> 最终 artifact 还能不能重新表达最初真正想解决的问题。

Regression 可以借用类似的判断方式，但不要退化成普通 premise recovery 或 mental-model review。

# 输出

独立 evaluator 默认只输出重建结果，不做原始目标比对：

```markdown
# Reconstructed Intent

## Primary Intent
...

## Important Constraints
- ...

## Apparent Priorities
1. ...

## Likely Non-goals
- ...

## Ambiguities
- ...
```

Main Agent 再输出 Regression：

```markdown
# Regression

## Preserved
- ...

## Lost
- ...

## Mutated
- ...

## Added
- ...

## Ambiguous
- ...

## Convergence
下一轮应该保持现状、修 Impl、修 Gate，还是重新对齐 Intent。
```

不要求机械输出完整结构。

如果两边基本一致，可以非常简短：

> 最终 Reality 可以较稳定地重建出原始 Intent / Gate，没有发现重要语义漂移。

# 不自动修复

Regression 默认只负责重新判断，不直接进入下一轮修改。

它可以指出：

- 哪些语义被保留；
- 哪些内容丢失；
- 哪些重点发生变形；
- 哪些新目标是执行后新增的；
- 下一轮应该从 Impl、Gate 还是 Intent 重新开始。

但不要因为发现问题就：

- 自动修改代码；
- 自动重写 Intent；
- 自动更新 Gate；
- 自动扩大任务范围；
- 自动进入新的 Implementation Plan。

Back bookend 的职责，是重新建立正确的高层理解。

后续是否继续修改，由用户或其他 Skill 决定。

# 不要做什么

- 不要把 Regression 做成 regression testing；
- 不要把测试通过当作完成条件；
- 不要把原始 Intent / Gate 提供给 blind evaluator；
- 不要让 evaluator 根据已知答案解释实现；
- 不要把 Regression 做成普通 code review；
- 不要只检查实现是否偏离 Plan；
- 不要为了完整而重新审计整个项目；
- 不要为了制造“独立意见”而进行没有意义的多 Agent 辩论；
- 不要把所有 Implementation 细节都上升为 Gate 或 Intent；
- 不要在没有 drift 时强行制造差异；
- 不要自动修复发现的问题。

# 核心原则

> **Regression 是一次语义 round-trip：Intent → Implementation → Reconstructed Intent。**

> **独立 evaluator 必须尽量不知道原始 Intent；信息不对称不是缺陷，而是测量机制。**

> **Subagent 负责从 Reality 重建 Intent；Main Agent 负责拿它与原始 Intent / Gate 比对。**

> **目标不是证明任务完成，而是判断实现之后，最初真正重要的东西是否还留在最终结果里。**
