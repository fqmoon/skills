# Agent Skills

这个仓库包含几类不同性质的 Skills：**Bookend Skills、协作 Modes、认知模型、执行式 Actions 和环境管理 Skills**。它们可以独立使用，也可以按当前任务需要组合；不构成一条固定 Workflow。

## Bookend Skills

Bookend 原意是“书挡”。

这里借它表示一种任务组织方法：重点放在执行的两端，而不是规定中间过程。

执行前，先提炼真正重要的目标、约束与实现边界；执行后，再根据实际结果重新检查这些重点是否仍然成立。

它不同于 Plan、Spec 或 TDD 这类更关注执行过程的组织方式。Agent 的实际执行往往具有探索性，真实代码、依赖、成本和问题会在实现过程中逐渐暴露。Bookend 不试图提前规定这些过程，而是负责让执行前后的注意力始终落在真正重要的事情上。

| Skill | 作用 |
|---|---|
| **intent** | 澄清为什么做、真正想保什么、什么更重要。 |
| **gate** | 定义所有可接受方案必须满足的条件。 |
| **impl** | 区分当前实现手段与真正的需求或约束。 |
| **regress** | 实现后从 Reality 出发，沿 Impl → Gate → Intent 反向回归。 |

## Modes

Modes 定义当前会话中持续生效的协作关系或工作目标。

| Skill | 作用 |
|---|---|
| **require** | 用户控制需求、方向和重要取舍；Agent 默认承担更多下层调查与实现判断。 |
| **drive** | 用户持续参与方向与关键 Implementation 判断，与 Agent 协作推进。 |
| **evolve** | 持续交互式地校对项目演化：从 ADR、Test、Code 与文档重建 Intent，主动提出建议，维护有效的长期约束并验证回归。 |

## Cognition

Cognition Skills 是可以贯穿任务持续使用的认知模型。

| Skill | 作用 |
|---|---|
| **debt** | 判断已知问题是否可以有意识地延迟处理。 |

## Actions

Actions 是针对当前问题执行的分析、转换、校正或状态同步动作。

| Skill | 作用 |
|---|---|
| **impact** | 调查拟议变化的传播路径，以及相关 ADR、Test 和项目契约可能受到的影响。 |
| **concretize** | 将高层需求、Intent、Gate 或 Impl 具体化为 Implementation Plan，并落盘到项目；默认位于 `docs/progress/`。 |
| **progress** | 主动或手动同步阶段进度与人工验收状态，原地更新现有 Execution Plan。 |
| **premise** | 恢复当前判断所需的最小共同前提。 |
| **up** | 将陷入细节的讨论提升到更合适的抽象层级。 |
| **bullshit** | 检查当前 mental model 中的错误前提、概念混淆与因果跳跃。 |

## Environment

环境管理 Skills 围绕用户意图与现场环境工作，不限定固定流程。

| Skill | 作用 |
|---|---|
| **[myenv](skills/myenv/SKILL.md)** | 调查软件版本与环境定制，比较差异，生成或维护环境快照，并按授权适配或还原个人环境。 |

## Installation

```bash
npx skills add fqmoon/skills -g
```

## Archive

`archive/` 保存已经停止使用、被替代或不再适合当前设计方向的旧 Skills。

这些内容保留作为实验和设计演化记录，但不属于当前推荐使用的 Skill 集合。
