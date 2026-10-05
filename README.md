# Agent Skills

一组用于 Human–Agent 协作的软件工程 Skills。

这个仓库包含几类不同性质的 Skills：协作模式、认知模型、一次性动作，以及已经停止使用的旧实验。

当前主要的设计方向是 **Bookend-Oriented**。

## Bookend-Oriented Design

Bookend 原意是“书挡”。

这里借它表示一种任务组织方法：重点放在执行的两端，而不是规定中间过程。

执行前，先提炼真正重要的目标、约束与实现边界；执行后，再根据实际结果重新检查这些重点是否仍然成立。

它不是 Workflow。

Workflow 更关注“接下来按什么步骤做”；Bookend 更关注“开始前和结束后分别应该看什么”。

相比预先把任务固定成 Plan、Spec 或 TDD 流程，这种方式更适合 Agent 的探索式执行：中间过程可以根据真实代码、依赖、成本和新发现自由调整，而两端负责持续抓住重点。

当前主要通过 Intent、Gate、Impl 等 Skills 建立前端 bookend，通过 Regression 从 Reality 沿 Impl → Gate → Intent 反向回归，形成后端 bookend。

## Modes

| Skill | 作用 |
|---|---|
| **require** | 用户控制需求、方向和重要取舍；Agent 默认承担更多下层调查与实现判断。 |
| **drive** | 用户持续参与方向与关键 Implementation 判断，与 Agent 协作推进。 |

## Cognition

| Skill | 作用 |
|---|---|
| **intent** | 澄清为什么做、真正想保什么、什么更重要。 |
| **gate** | 定义所有可接受方案必须满足的条件。 |
| **impl** | 区分当前实现手段与真正的需求或约束。 |
| **debt** | 判断已知问题是否可以有意识地延迟处理。 |

## Actions

| Skill | 作用 |
|---|---|
| **impact** | 调查拟议变化的真实影响范围与传播路径。 |
| **concretize** | 将高层需求、Intent、Gate 或 Impl 具体化为 Implementation Plan。 |
| **regression** | 实现后从 Reality 出发，沿 Impl → Gate → Intent 反向回归。 |
| **premise** | 恢复当前判断所需的最小共同前提。 |
| **up** | 将陷入细节的讨论提升到更合适的抽象层级。 |
| **bullshit** | 检查当前 mental model 中的错误前提、概念混淆与因果跳跃。 |

## Installation

```bash
npx skills add fqmoon/skills -g
```

## Archive

`archive/` 保存已经停止使用、被替代或不再适合当前设计方向的旧 Skills。

这些内容保留作为实验和设计演化记录，但不属于当前推荐使用的 Skill 集合。
