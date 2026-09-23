---
name: dispatch
version: 4
description: 将已经确定的 ownership 放入独立 Git worktree 与独立执行上下文中执行；支持在保留的 worktree 上继续 dispatch；等待全部完成后收集真实结果并自动调用 integration-review 收尾；若 review 不可调用则明确失败并报告原因，不自动集成。
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

# 用途

用于执行已经确定的 ownership。

本 Skill 是执行协议，不负责重新划分 ownership。

如果 ownership 已由用户、文档、`ownership` Skill 或其他上下文明确给出，可以直接执行。

如果当前没有足够明确的 ownership 边界，则停止并报告缺少执行前提；不要为了方便执行自行重新拆分任务。

本 Skill 不依赖特定 Subagent、Agent、Workflow 或编排插件。

# 执行前提

每个 ownership 至少应明确：

- Goal；
- Responsibility；
- 主要 Write Scope；
- Hard Constraints；
- 已知 contract；
- 必要的局部上下文。

Contract 可以尚未闭合。

API 暂时不一致、跨 ownership assumptions 尚未统一、repository-wide 暂时不能运行，都不自动阻止执行。

# Worker

本文统一使用 `worker` 表示一个独立执行单元。

worker 可以由以下能力实现：

- Subagent；
- 独立 Agent session；
- 独立 task context；
- 其他能够提供隔离上下文的执行机制。

名称不重要，必须满足隔离要求。

# 执行后端要求

一个执行后端只有同时满足以下条件时才可以使用：

1. 可以创建独立于主上下文的新模型 / Agent 执行上下文；
2. 不同 worker 的上下文彼此独立；
3. 可以让 worker 在指定 `worktree_path` 中工作；
4. 可以并行启动多个 worker，或至少让其作为独立任务并发执行；
5. 主上下文能够知道每个 worker 最终完成或失败。

普通 OS process 或 shell 本身不构成独立模型 / Agent 上下文。

如果当前环境存在多个满足要求的执行方式，可以选择最直接的一种。

不要因为 Skill 曾在某个具体插件上使用过，就强制依赖该插件。

# 不允许的降级

如果没有独立上下文执行能力：

```text
FAIL
```

并报告导致失败的具体原因。

不得：

- 在主上下文中轮流扮演多个 worker；
- 使用同一个上下文串行执行多个 ownership，再声称它们彼此独立；
- 只通过不同 prompt 模拟隔离；
- 让不同 worker 共用同一个工作目录。

这种降级会破坏本 Skill 最重要的隔离语义，因此不允许进行。

# Worktree

每个 worker 必须运行在独立 Git worktree 中。

主上下文负责：

- 确定共同的 base revision；
- 为每个 ownership 创建或确认独立 branch；
- 创建或确认对应 worktree；
- 将正确的 `worktree_path` 交给 worker；
- 保留所有 worktree 和 branch，直到人工决定后续处理。

首次 dispatch 时，所有 worker 应从同一个逻辑 base 开始，除非当前任务明确要求其他方式。

Continuation Dispatch 不要求重新回到共同 base；其执行起点按下节规则确定。

# Continuation Dispatch

如果用户在同一任务中再次显式调用 `dispatch`，且上一轮对应的 ownership、branch 与 worktree 仍然存在，则默认视为 **Continuation Dispatch**。

Continuation Dispatch 的默认语义是继续修改，而不是重新开始。

主上下文必须：

- 复用上一轮已经确定且仍然有效的 ownership；
- 复用各 ownership 原有的 branch 与 worktree；
- 以各 worktree 当前真实状态作为本轮执行起点，包括其中尚未集成的已有修改；
- 根据用户在上一轮之后提出的新要求、反馈或已经明确要处理的问题继续执行；
- 只重新派遣本轮需要继续修改的 ownership；未受影响的 ownership 保持原状；
- 本轮 worker 完成后重新执行 `integration-review`，使审查基于最新真实实现。

除非用户明确要求重新开始、重做或从某个 base 重新执行，否则不得：

- reset 到首次 dispatch 的 base；
- 删除并重建已有 worktree；
- 为相同 ownership 创建替代 branch；
- 丢弃上一轮有效修改；
- 把 Continuation Dispatch 当成一次全新的独立任务。

如果用户的新要求已经改变 ownership 边界，使原 ownership 不再成立，则 `dispatch` 不得自行重新划分；应停止并报告需要先重新确定 ownership。

如果用户再次调用 `dispatch`，但当前上下文中既没有新的可执行修改要求，也没有明确要继续处理的问题，则停止并报告缺少本轮执行增量，不要无目的地重复上一轮工作。

`Stop` 中禁止“自动重新派遣 worker”，只禁止 `dispatch` 在无人指示时自行开启下一轮；它不禁止用户显式再次调用 `dispatch` 形成 Continuation Dispatch。

# Worker 行为

每个 worker：

- 自己读取 ownership 内的真实代码；
- 自己调查必要的局部上下文；
- 自行决定局部实现；
- 只修改自己的 ownership；
- 优先保证本模块的静态语义、类型、API、ownership 和内部调用合理；
- 可以基于自己的局部需求提出 exported contract 与 required contract；
- contract 尚未确定时，可以基于明确 assumptions 完成局部实现；
- 不为了 repository-wide build 或 test 通过而越界修改其他模块；
- 不为了兼容尚未整合的其他 ownership 而增加无必要兼容层；
- 不提前与其他 worker 协调具体实现；
- 不解决尚未真实发生的跨模块冲突。

不同 worker 最终形成的 contract 不一致，不视为 worker 失败。

这些不一致应保留给 Integration Review 阶段判断。

允许执行不会导致 ownership 外溢的：

- 静态检查；
- 模块级检查；
- 局部测试。

# Worker Prompt

交给 worker 的任务至少应包含：

```text
Goal:
<当前目标>

Ownership:
<允许修改的范围>

Hard Constraints:
<必须遵守的约束>

Known Contracts:
<已知接口或 None>

Worktree:
<worktree_path>

Execution Rules:
- 只修改 Ownership 范围。
- 自行调查局部上下文并决定实现。
- Contract 未确定时，可以提出或假设局部所需 contract，并在结果中记录。
- 不为了 repository-wide build/test 越界修改。
- 不提前处理尚未发生的跨 ownership 冲突。
- 完成后写 WORKER_RESULT.md。
```

不需要把其他 worker 的完整任务传给它。

# Result File

每个 worker 完成后，在自己 worktree 根目录创建：

```text
WORKER_RESULT.md
```

内容保持简短：

```markdown
# Result

## Changed
- 修改范围，1～3 条

## Exported Contract
- 本 ownership 对外提供的 API / contract；没有则写 None

## Required Contract
- 本 ownership 需要其他 ownership 提供的 API / contract；没有则写 None

## Assumptions
- 为完成局部实现采用的跨 ownership 假设；没有则写 None

## Decisions
- 关键局部决策，最多 3 条

## Unresolved
- 已知未解决问题或可能的跨 ownership 影响；没有则写 None
```

该文件：

- 是临时协调文件；
- 不属于最终代码修改；
- 不参与 Integration；
- 不需要在不同 worktree 之间保持一致；
- 后续直接删除或忽略即可。

主上下文不审查其模板合规性。

# Worker Return

worker 的返回内容只作为状态信号。

成功：

```text
DONE
worktree: <path>
result: WORKER_RESULT.md
```

失败：

```text
FAILED
worktree: <path>
result: WORKER_RESULT.md
```

不要在返回消息中：

- 展开修改；
- 解释设计；
- 粘贴 diff；
- 总结代码；
- 输出详细过程或推理。

# Main Context Collection

等待本轮所有 worker 完成后，主上下文只负责确认每个 ownership 的真实结果位置，并收集后续 Integration Review 所需输入。

至少确认：

- `WORKER_RESULT.md`；
- worktree path；
- branch；
- worker 状态；
- Goal；
- Gate 或等价的必须满足条件；
- Ownership 定义。

不得把 worker 返回消息当成执行结果。

主上下文在这一阶段不要自行承担跨 ownership 的审查判断。

# Source of Truth

`WORKER_RESULT.md` 仅作为快速索引。

以下内容才是 source of truth：

1. 实际文件；
2. Git diff；
3. 接口定义；
4. commit。

如果 `WORKER_RESULT.md` 与真实修改不一致，以真实修改为准。

worker 的返回消息只代表执行状态，不代表执行结果。

# Integration Review 收尾

所有 worker 都已经完成或明确失败，且上述输入已经收集后，`dispatch` 必须调用 `integration-review` 作为本轮正常收尾步骤。

将本轮的：

- Goal；
- Gate 或等价的必须满足条件；
- Ownership；
- 各 ownership 的 worktree / branch；
- worker 状态；
- `WORKER_RESULT.md` 位置；

交给 `integration-review`。

跨 ownership 的 Conflict、Gap、Overlap、Gate Violation 由 `integration-review` 读取真实修改后判断。

`dispatch` 不重复做一份平行的 integration 汇总，不替代 `integration-review`，也不把 review 逻辑内嵌进自身。

即使部分 worker 失败，也应调用 `integration-review`。如果关键实现无法读取，由 `integration-review` 将状态记录为 `INCOMPLETE`。

`integration-review` 完成并写出 `INTEGRATION_REVIEW.md` 后，本轮 dispatch 才算完成。

## Integration Review 不可用或调用失败

如果当前环境中无法调用 `integration-review`，或调用过程中失败，则本轮 `dispatch` 必须失败。

```text
FAIL
reason: <integration-review 不可用或调用失败的具体原因>
```

必须把实际可观察到的失败原因报告给用户，例如：

- `integration-review` 未安装或不存在；
- 当前宿主不支持调用该 Skill；
- Skill 调用被禁用或权限不足；
- 调用发生错误；
- `integration-review` 未能完成其要求的输出。

如果无法进一步确定根因，应如实报告当前能够观察到的错误信息，不得猜测原因。

此时不得：

- 在 `dispatch` 内自行执行 Integration Review；
- 根据 `integration-review` 的描述模拟其行为；
- 自行创建或伪造 `INTEGRATION_REVIEW.md`；
- 跳过 Integration Review 并将本轮视为成功；
- 自动进入 Integration。

失败后保留已经完成的 worker worktree、branch 和结果文件，等待人工处理。

# Stop

`integration-review` 完成后，或其不可用 / 调用失败并已经报告原因后，立即停止。

不得：

- merge；
- cherry-pick；
- rebase；
- 自动修改其他 worktree；
- 自动解决跨 ownership 冲突；
- 自动重新派遣 worker；
- 自动进入 Integration；
- 自动执行 repository-wide 修复。

即使 `INTEGRATION_REVIEW.md` 为 `CLEAN`，也必须停止并等待人工介入。
