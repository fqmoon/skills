---
name: fork-subagent
version: 1
description: 指导 Agent 在执行已经明确的阶段时，使用能够继承当前会话上下文的 fork 型 subagent 隔离实现过程，减少主上下文污染；支持用户显式触发，也允许 Agent 在合适场景主动应用。
---

# Fork Subagent

`fork-subagent` 是一种 **subagent 工具使用策略**。

它不是任务拆分方法，不是 Workflow，不是并发协议，也不是一个必须由用户显式调用的执行命令。

它回答的问题是：

> **当前已经进入执行阶段时，这部分实现应该继续留在主上下文里，还是交给一个继承当前会话状态的 fork subagent？**

核心目标：

> **主上下文保留决策与阶段结果，把实现过程产生的大量局部上下文留在 fork 子会话中。**

# 触发方式

本 Skill 同时支持用户显式触发与 Agent 主动触发。

## 显式触发

当用户明确调用 `fork-subagent` 时，表示当前执行应优先采用 fork 型 subagent 隔离实现过程。

只要当前环境存在满足要求的 fork / inherited-context subagent 能力，就应按本 Skill 的策略使用它。

显式触发不代表必须重新拆分任务，也不代表必须并发。

## 主动触发

不要求用户显式指定本 Skill。

当 Agent 判断同时满足以下条件时，可以主动应用：

1. 当前任务已经进入 execution-ready 的实现阶段；
2. 当前会话已经包含后续执行需要的重要需求、设计、调查或实现决策；
3. 接下来的工作主要是代码阅读、搜索、修改、调试、试错或局部验证；
4. 这些执行过程本身对主上下文的长期价值较低；
5. 当前环境存在能够继承当前 conversation branch / session context 的 fork 型 subagent。

典型触发信号包括：

- “执行第一阶段”；
- “按刚才的方案实现”；
- “继续做下一阶段”；
- “现在开始改”；
- 已完成 Plan，接下来进入实现。

主动触发的目的不是增加 Subagent 使用率，而是在合适的执行阶段保护主上下文。

如果任务很小、仍需要频繁与用户决策、或 fork 成本明显高于执行成本，则直接在主上下文执行。

# 核心模型

推荐的状态分层：

```text
主上下文
    保存：
    - Goal
    - Constraints
    - 已确认的设计决策
    - 实现方案
    - 阶段划分
    - 各阶段最终结果
    - 会影响后续工作的关键新事实

fork 子上下文
    保存：
    - repository 搜索
    - 文件阅读
    - 局部实现推理
    - edit
    - debug
    - 试错
    - 临时假设
    - 局部验证
    - 当前阶段内部的执行细节

Artifact / Repository
    保存：
    - 实际代码
    - 配置
    - 测试
    - 文档
    - 其他真实系统状态
```

实现过程本身通常不是主上下文需要长期保存的知识。

真实 artifact 才是实现结果的 source of truth。

# 什么时候使用

当以下条件大体成立时，优先考虑使用 fork subagent：

1. 当前任务已经进入**执行阶段**；
2. 当前阶段的目标和主要实现方向已经足够明确；
3. 主上下文中已经积累了有价值的需求、设计或调查结果；
4. 当前实现预计会产生较多局部上下文，例如：
   - 多次代码搜索；
   - 阅读若干实现文件；
   - 修改代码；
   - 编译或运行；
   - 调试；
   - 局部试错；
   - 修复执行过程中暴露的问题；
5. 这些执行细节大部分不会影响后续高层决策；
6. 当前环境提供能够继承当前 conversation branch / session context 的 fork 型 subagent。

典型场景：

```text
需求已经明确
↓
调用链已经调查
↓
实现方法已经决定
↓
准备实现阶段 A
↓
fork subagent 执行阶段 A
```

# 不要为了使用而使用

以下情况通常不需要 fork subagent：

- 只是修改一个非常小的局部内容；
- 实现只需要一两个简单操作；
- 当前仍然在讨论需求或设计；
- 当前仍然需要主 Agent 与用户频繁交互决策；
- 执行结果本身会立刻改变整体方案；
- fork 的启动与上下文复制成本明显大于预计执行成本；
- 子 Agent 无法真正继承当前会话状态，只能 fresh start；
- 当前任务需要持续利用主 Agent 刚刚形成但尚未外显的判断，而 fork 后仍需要大量重新调查。

不要因为“存在 subagent 工具”就机械调用。

fork subagent 是上下文隔离手段，不是默认仪式。

# Fork 的要求

这里的 `fork` 指语义，而不是某个具体参数名。

可接受的机制包括：

- fork current conversation；
- clone current session branch；
- inherit parent context；
- seed child with current parent session；
- 其他等价机制。

关键要求是：

```text
fork point 之前的有效上下文
        ↓
      child
```

child 应能够直接利用当前已经形成的执行状态，而不是重新从任务摘要开始建立 mental model。

以下不等价：

```text
Main
↓
生成一段任务摘要
↓
Fresh Subagent
```

这仍然是 cold start，只是 prompt 写得更长。

# Fork 点

理想 fork 点通常位于：

```text
需求明确
↓
必要调查完成
↓
关键设计决策完成
↓
当前阶段已经 execution-ready
↓
----------- FORK -----------
↓
实现
```

不要过早 fork。

如果根因、方案或边界仍然没有确定，让 child 自己重新探索通常只会复制调查成本。

也不要过晚 fork。

如果主上下文已经完成了大部分实现和调试，fork 已经失去隔离执行噪音的意义。

# 子 Agent 的任务

fork 已经继承当前上下文，因此新的 task 应保持简洁。

不要重新复制大量背景。

推荐表达：

```text
执行当前已经确定的阶段：

<当前阶段>

直接基于继承的当前上下文执行。

不要重新做完整 Plan，也不要无理由重新调查已经确认的前提、根因或实现方案。

完成当前阶段所需的代码阅读、搜索、修改、调试、试错和局部验证。

只完成当前阶段，不提前执行后续阶段，不做无关重构。

如果真实 artifact 与继承上下文明显冲突，可以调查必要范围并调整实现。

完成后只返回会影响主上下文和后续阶段的最小必要信息。
```

具体宿主如果提供专门的 fork 参数，应使用其原生 fork / inherited-context 能力。

# 子 Agent 应保留什么

以下信息默认留在 child，不带回 Main：

- 搜索命令；
- read / grep / find 过程；
- 调用链探索过程；
- 中间猜测；
- 被否掉的局部实现；
- 编译错误的完整输出；
- 调试过程；
- 临时日志；
- 大量 diff 描述；
- 与后续无关的局部决策；
- 已经存在于主上下文中的背景复述。

这些内容可以帮助 child 完成任务，但通常不值得永久占据 Main context。

# 子 Agent 应返回什么

默认只返回会影响后续工作的最小必要结果。

推荐结构：

```text
STATUS
完成 / 部分完成 / 阻塞

CHANGES
关键修改，以及主要涉及的 artifact

DEVIATIONS
是否偏离既定方案，以及必要原因
没有则写 None

NEXT
后续阶段必须知道的新事实、约束、接口变化或风险
没有则写 None
```

不要默认返回：

- 完整执行过程；
- 完整 diff；
- 每个修改点的解释；
- “首先我做了……然后我发现……”式流水账；
- 已确认方案的重复总结。

# Main 收到结果后

Main 应把 child 返回视为**阶段结果摘要**，而不是实现事实本身。

后续判断优先依据：

1. 实际 artifact；
2. Git diff；
3. 接口定义；
4. 测试或验证结果；
5. child 的结果摘要。

如果 child 声称完成，但真实 artifact 不支持这一结论，以 artifact 为准。

Main 不需要为了“同步上下文”重新读取并复述 child 的完整执行过程。

只有当需要做 Verification、Review 或后续设计决策时，才读取相应的真实代码或 diff。

# 连续阶段

如果任务已经被拆成连续阶段：

```text
Stage 1
↓
Stage 2
↓
Stage 3
```

推荐：

```text
Main
↓
fork Stage 1
↓
最小结果返回 Main
↓
fork Stage 2
↓
最小结果返回 Main
↓
fork Stage 3
↓
最小结果返回 Main
```

每个阶段都基于当前最新 artifact 状态执行。

后续阶段不需要继承前一阶段 child 的完整 conversation。

它只需要：

```text
最新 repository state
+
Main 中保留下来的必要阶段结果
```

这样主上下文的增长更接近：

```text
C_main
≈
初始决策上下文
+
Σ 阶段必要结果
```

而不是：

```text
C_main
≈
初始上下文
+
Σ 完整执行轨迹
```

# 与并发无关

`fork-subagent` 不要求 fanout，也不要求并发。

单个阶段串行 fork 是完全正常、甚至通常更适合的使用方式。

不要自动把：

```text
使用 fork subagent
```

理解为：

```text
拆成多个 subagent 并行
```

是否并发是独立的调度问题。

只有当多个任务本身适合并发时，才考虑 fanout。

# 与任务拆分无关

本 Skill 不负责把一个大任务拆成多个阶段。

如果用户已经给出了：

```text
Stage A
Stage B
Stage C
```

直接使用这些阶段。

如果阶段尚未明确，不要为了调用 fork subagent 而强行制造阶段。

任务拆分、Ownership、Plan 与 fork 执行是不同问题。

# 与 Workflow 的区别

Workflow 解决的是：

- 多步骤编排；
- 条件分支；
- 多 Agent 协调；
- 动态调度；
- 失败恢复；
- 复杂控制流。

`fork-subagent` 解决的是：

> **一个已经知道怎么做的执行阶段，是否应该放进独立的继承上下文中执行。**

如果流程本身已经是：

```text
Stage 1 → Stage 2 → Stage 3
```

而用户只是希望隔离每个 Stage 的执行噪音，不要为了这个目的额外引入 Workflow。

# Fresh Subagent 与 Fork Subagent

Fresh subagent 更适合：

- 独立调查；
- 独立 Review；
- 需要刻意避免 Parent bias；
- 子任务本身不依赖 Main 已建立的上下文；
- 需要完全独立视角。

Fork subagent 更适合：

- Main 已经完成大量调查；
- 当前已有明确 execution-ready state；
- 子任务依赖前面的设计决策；
- 不希望 child 重复 repository archaeology；
- 希望执行噪音留在分支中。

不要把两者混为一种“Subagent”。

# 失败与退化

本 Skill 是工具选择指导，不是强制执行协议。

如果当前环境没有 fork 型 subagent：

- 不要伪装成 fork；
- 不要声称 fresh subagent 继承了 Parent context；
- 根据任务规模选择普通 Main 执行或其他合适机制。

缺少 fork 能力不代表任务必须失败。

关键是明确当前实际使用的执行模型。

# 原则

优先遵守以下原则：

> **主线保存决策，分支承担施工，artifact 保存事实。**

以及：

> **只有会影响后续决策的信息，才值得从执行分支带回主上下文。**

`fork-subagent` 的目标不是减少所有 token，也不是让任务自动并行。

它主要优化的是：

> **Main context 的长期质量与增长速度。**
