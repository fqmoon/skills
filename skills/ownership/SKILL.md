---
name: ownership
version: 1
description: 将任务按责任边界拆成若干 ownership；只确定责任范围、主要写入边界与跨 ownership 的 contract 关系，不负责执行。
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

# 用途

用于判断一个任务应该如何按责任边界拆成若干 ownership。

本 Skill 是责任划分方法，不是执行协议。

它不要求先调用 `gate`。只要当前目标与约束已经足够明确，就可以直接使用；这些信息可以来自用户、已有文档、Gate 或其他上下文。

不要生成详细的 repository-wide 实施 Plan。

# 输入

至少需要能够判断：

- Goal：当前任务最终希望改变什么；
- Constraints：执行过程中不能违反的边界；
- 当前系统或代码中的责任边界。

不要把一般性的实现偏好伪装成硬约束。

# Ownership

将任务拆成若干可以独立负责的修改范围。

ownership 应优先按照代码责任边界划分，例如：

- package；
- subsystem；
- library；
- service；
- UI component family；
- storage layer；
- renderer；
- protocol layer。

不要为了增加 ownership 数量而人为切碎强耦合模块。

一个 ownership 应满足：

1. 有清晰的责任范围；
2. 有清晰的主要写入范围；
3. 即使不知道其他 ownership 的具体实现细节，也能独立形成有意义的局部修改。

这里要求的是局部自治，不是独立交付。

一个 ownership 不需要单独满足 repository-wide 编译、运行、测试或跨模块兼容。

# 写入边界

不同 ownership 的主要写入范围不得重叠。

读取范围可以重叠。

后续执行者可以读取 repository 中任何理解自己任务所需的代码，但主要修改应限制在自己的 ownership 范围。

如果两个任务必须同时修改同一个核心文件，默认认为它们不具有独立 ownership。

不要通过约定两个执行者修改同一文件的不同代码段来制造虚假的独立性。

# Contract Dependency

允许 ownership 之间存在 contract 依赖。

例如：

```text
A ownership
    ↓ exports API

B ownership
    ↓ consumes API
```

contract 尚未确定，也不自动阻止 ownership 拆分。

本阶段只需要明确：

- 已存在的 contract；
- 用户已经明确决定的新 contract；
- 哪些 contract 尚未确定。

不要为了形成 ownership 提前设计完整的跨模块 contract 或实现。

对于尚未确定的 contract，各 ownership 后续可以基于自己的局部需求：

- 提出自己对外提供的 contract；
- 提出自己需要其他 ownership 提供的 contract；
- 在必要时基于明确 assumptions 形成局部实现。

不同 ownership 最终形成的 contract 不一致，不代表 ownership 拆分失败。

这种不一致本身就是后续 Integration 的输入。

只有当一个 ownership 无法在脱离另一个 ownership 的具体实现细节时形成有意义的局部修改，才认为两者不适合独立划分。

# 输出

只输出责任划分结果，不执行。

建议包含：

```text
Goal:
<目标>

Constraints:
<约束>

Ownership A:
  Responsibility:
  Write Scope:
  Known Contracts:
  Unknown / Assumptions:

Ownership B:
  Responsibility:
  Write Scope:
  Known Contracts:
  Unknown / Assumptions:
```

Ownership 数量可以是一个或多个。

如果分析后只能形成一个有效 ownership，应直接输出一个，而不是为了并行执行强行继续拆分。

# 判断不适合继续拆分

以下情况应停止继续拆分：

- 多个修改强依赖同一个核心实现；
- ownership 的写入边界无法明确；
- 后续执行者必须频繁修改彼此负责的代码；
- 某个 ownership 无法在不知道另一 ownership 具体实现细节的情况下形成有意义的局部修改；
- 拆分本身比局部实现更复杂；
- 所谓多个 ownership 只是同一实现步骤的人为切片。

Contract 未确定、API 暂时不一致、repository-wide 暂时不能运行，本身都不是停止拆分的理由。

# 不负责

本 Skill 不负责：

- 创建 Git worktree；
- 启动 Subagent、Agent、Workflow 或 worker；
- 并行执行；
- 汇总执行结果；
- Integration。
