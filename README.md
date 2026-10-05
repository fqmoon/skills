# skills

一组用于 Human–Agent 协作的软件工程 Skills。

设计上主要采用 **bookend skills**：

- 执行前，用认知类 Skills 对齐目标、约束与实现边界；
- 执行中，允许 Agent 自由探索、实现和承担局部技术判断；
- 执行后，用 Regression 从真实结果反向检查原来的 Impl、Gate 和 Intent 是否仍然成立。

它们不是一条固定 Workflow，而是一组可以按需组合、主动调用或显式调用的认知、动作与协作模式。

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

`archive/` 保存已经废弃或不再主动维护的旧 Skills。
