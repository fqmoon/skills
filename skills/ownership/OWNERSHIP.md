# Ownership Planning

本阶段只负责把当前任务拆成可以独立执行的 ownership。

不要生成详细的 repository-wide 实施 Plan。

# 输出目标

只确定四类信息：

## Goal

当前任务最终希望改变什么。

只描述目标状态，不展开具体实现步骤。

## Hard Constraints

执行过程中不能违反的边界。

包括但不限于：

- 用户明确要求；
- 兼容性要求；
- 已确定的架构约束；
- 禁止修改的区域；
- 明确的 API 或行为要求。

不要把一般性的实现偏好伪装成硬约束。

## Ownership

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

不要为了提高并行数量而人为切碎强耦合模块。

一个 ownership 应满足：

1. 有清晰的责任范围；
2. 有清晰的主要写入范围；
3. 即使不知道其他 ownership 的具体实现细节，也能独立形成有意义的局部修改。

这里要求的是局部自治，不是独立交付。

一个 ownership 不需要单独满足 repository-wide 编译、运行、测试或跨模块兼容。

# 写入边界

不同 ownership 的主要写入范围不得重叠。

读取范围可以重叠。

worker 可以读取 repository 中任何理解自己任务所需的代码，但只能修改自己的 ownership 范围。

如果两个任务必须同时修改同一个核心文件，默认认为它们不具有独立 ownership。

不要通过约定两个 worker 修改同一文件的不同代码段来制造虚假的独立性。

# Contract Dependency

允许 ownership 之间存在 contract 依赖。

例如：

```text
A ownership
    ↓ exports API

B ownership
    ↓ consumes API
```

contract 尚未确定，也不自动阻止 ownership 拆分或并行执行。

规划阶段只需要明确：

- 已存在的 contract；
- 用户已经明确决定的新 contract；
- 哪些 contract 尚未确定。

不要为了并行执行提前设计完整的跨模块 contract 或实现。

对于尚未确定的 contract，worker 可以基于自己的 ownership：

- 提出自己对外提供的 contract；
- 提出自己需要其他 ownership 提供的 contract；
- 在必要时基于明确假设完成局部实现。

这些 exported contract、required contract 和 assumptions 都应作为 worker 的执行结果记录下来，供后续 Integration 判断。

不同 worker 独立形成的 contract 不一致，不代表 ownership 拆分失败，也不代表 worker 执行失败。

这种不一致本身就是 Integration 的输入。

只有当一个 worker 无法在脱离另一个 ownership 的具体实现细节时形成有意义的局部修改，才认为两者不适合独立执行。

# Worker Scope

每个 worker 的任务描述只包含：

- Goal；
- Ownership；
- Hard Constraints；
- 已知 contract；
- 必要的局部上下文。

不要包含：

- repository-wide 实施 Plan；
- 其他 worker 的具体实现方案；
- 猜测性的冲突解决方式；
- 为 Integration 提前准备的兼容层设计。

# 判断不适合并行

以下情况应停止拆分：

- 只能形成一个有效 ownership；
- 多个修改强依赖同一个核心实现；
- ownership 的写入边界无法明确；
- worker 必须频繁修改彼此负责的代码；
- 某个 worker 无法在不知道另一 ownership 具体实现细节的情况下形成有意义的局部修改；
- 拆分本身比局部实现更复杂；
- 所谓并行任务只是同一实现步骤的人为切片。

Contract 未确定、API 暂时不一致、repository-wide 暂时不能运行，本身都不是停止拆分的理由。

宁可报告“不适合并行”，也不要为了使用本 Skill 强行制造多个 worker。
