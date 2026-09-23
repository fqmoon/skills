---
name: integration-review
version: 2
description: 审查多个独立 ownership 的真实实现，识别阻止它们共同进入满足 Gate 的系统的 Conflict、Gap、Overlap 与 Gate Violation；通常由 dispatch 在执行收尾时调用，也可独立调用；只输出 INTEGRATION_REVIEW.md，不执行整合或修复。
metadata:
  opencode/autoinvoke: "false"
---

# 用途

用于多个 ownership 已经独立执行完成之后、真正 Integration 开始之前。

本 Skill 只负责 **Integration Review**：读取各 ownership 的真实实现，找出它们同时进入同一个系统时必须先处理的全局问题，并把审查结果写入文件。

本 Skill 通常由 `dispatch` 在所有 worker 完成后作为收尾步骤调用，也允许独立调用或重新调用。

本 Skill **不是 Integration 执行器**。

不要 merge、修改实现、解决冲突、设计统一方案或替用户做最终取舍。

# 输入

至少需要能够获得：

- Goal：本轮任务最终希望改变什么；
- Gate 或等价的必须满足条件；
- Ownership：各局部实现原本负责什么；
- 各 ownership 对应的 worktree、branch 或其他可读取的真实实现位置；
- 各 ownership 的实际修改。

如果存在 `WORKER_RESULT.md`，可以把它作为快速索引，但不能把它当作 source of truth。

如果缺少足够信息，无法读取某个关键 ownership 的真实实现，应在审查文件中标记输入不完整，不要根据摘要猜测其实现。

# Source of Truth

审查必须以真实修改为准。

优先读取：

1. 实际文件；
2. Git diff；
3. 接口定义；
4. commit；
5. 必要的调用关系。

`WORKER_RESULT.md`、worker 返回消息或其他摘要只用于定位信息。

如果摘要与真实修改不一致，以真实修改为准。

# 审查目标

只寻找一个问题：

> **什么会阻止这些局部实现同时存在于一个满足 Gate 的全局系统中？**

如果一个差异不需要在 Integration 中处理，就不要把它写成 Integration Issue。

局部实现彼此不同，本身不是问题。

# Issue 类型

只记录以下四类问题。

## Conflict

不同 ownership 的实现依赖互相不能同时成立的 contract、assumption 或系统语义。

例如：

- A 假设某状态由 Layer 持有，B 假设同一状态由 Renderer 持有；
- exported contract 与 required contract 的语义不一致；
- 两个 ownership 对同一对象的生命周期有互斥假设；
- 相同接口形状背后存在不同且不能同时成立的行为语义。

只有真正互斥时才算 Conflict。

## Gap

局部实现相遇后出现一项为了满足 Gate 必须存在、但没有任何 ownership 负责的责任。

例如：

- 新增持久化状态，但没有 ownership 负责旧数据迁移；
- producer 与 consumer 都已实现，但缺少二者之间必需的适配责任；
- Gate 要求某个全局行为，但所有 ownership 都只实现了其中局部部分。

不要因为“还能继续优化”就创建 Gap。

## Overlap

多个 ownership 实际上同时拥有了同一个全局责任，并且 Integration 后会产生重复实现、多个 source of truth 或职责归属不明确。

内部代码相似、命名相近或实现方式不同，不自动构成 Overlap。

只有职责真的重叠并且必须在 Integration 时消解时才记录。

## Gate Violation

某个真实局部实现如果进入全局系统，会直接违反 Gate、Hard Constraint 或不可丢失的外部语义。

不要把一般性的代码质量问题、风格问题或局部技术债写成 Gate Violation。

# 过滤规则

每个候选问题都必须通过下面的判断：

> 如果完全不处理这个问题，当前这些 ownership 的真实实现是否仍然可能共同组成一个满足 Gate 的一致系统？

- 如果答案是“不能”，记录；
- 如果答案是“可以”，不要记录。

因此，以下内容通常不属于 Integration Issue：

- 不同 ownership 使用不同内部抽象；
- 命名、格式或代码风格不同；
- 局部实现存在可改进之处；
- 一个 ownership 内部的普通 bug，且不会形成跨 ownership 或 Gate 问题；
- 不影响 contract 的重复代码；
- 尚未发生的理论风险；
- 为了“统一设计”而产生的偏好；
- 单纯因为 repository-wide build/test 尚未通过而推断存在 Integration 问题。

不要把 Integration Review 变成普通 Code Review。

# 审查方式

先独立读取每个 ownership 的真实修改，再比较它们之间的关系。

至少关注：

- exported contract；
- required contract；
- contract assumptions；
- 状态 ownership；
- 数据生命周期；
- 调用方向；
- 持久化语义；
- 同一全局责任是否被重复拥有；
- 是否出现没人负责但 Gate 必须要求的责任。

不要为了理解冲突而修改任何 worktree。

不要提前创建统一 contract。

不要因为看到一个明显修法就直接执行。

# 输出文件

审查结束后，在当前主工作目录根目录创建或覆盖：

```text
INTEGRATION_REVIEW.md
```

只写审查结果，不写详细调查过程。

建议格式：

```markdown
# Integration Review

## Status

CLEAN | ISSUES_FOUND | INCOMPLETE

## Scope

- Goal: <目标>
- Gate: <与本轮审查直接相关的 Gate>
- Ownerships: <参与审查的 ownership>

## Issues

### IR-1 <简短标题>

- Type: Conflict | Gap | Overlap | Gate Violation
- Affected: <ownership>
- Gate Impact: <受影响的 Gate / Constraint>
- Evidence:
  - <真实文件、接口、diff 或 commit 中的事实>
- Problem:
  - <为什么这些事实不能同时进入满足 Gate 的全局系统>

### IR-2 ...
```

如果没有 Integration Issue：

```markdown
## Issues

None.
```

如果关键输入无法读取，在 `Status` 使用 `INCOMPLETE`，并只记录缺失的输入事实；不要把未知内容伪装成 Conflict 或 Gap。

# 不输出方案

审查文件不得包含最终 Integration 方案。

不要写：

- Recommendation；
- Preferred Option；
- 建议采用哪个 ownership 的实现；
- 应该如何重构；
- 应该如何修改 API；
- merge / cherry-pick 顺序；
- 自动生成的修复 Plan。

可以准确描述“必须做出哪类全局决定”，但不要替用户做决定。

例如可以写：

```text
必须确定 BrushConfig 的唯一 source of truth。
```

但不要写：

```text
建议把 BrushConfig 移到 Layer。
```

# 修改边界

本 Skill 唯一允许产生的修改是：

```text
INTEGRATION_REVIEW.md
```

不得修改：

- 任一 ownership 的实现文件；
- 任一 worker worktree；
- branch；
- commit；
- 测试；
- 配置；
- 其他协调文档。

# Stop

写完 `INTEGRATION_REVIEW.md` 后立即停止。

不得：

- merge；
- cherry-pick；
- rebase；
- 自动修复；
- 自动统一 contract；
- 自动重新 dispatch；
- 自动进入 Integration；
- 因为所有问题看起来容易解决而跳过人工决策。

Integration Review 的产物是 **需要被讨论的事实集合**，不是已经完成的 Integration。
