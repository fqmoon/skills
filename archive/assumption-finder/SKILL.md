---
name: assumption-finder
description: 识别问题或观点中会实质影响结论的隐藏前提。
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

流程
1. 读取用户的问题或观点，不直接回答
2. 找出未经明确说明、但结论依赖的前提
3. 只保留改变后会实质影响答案的前提
4. 输出
- 列出所有找到的前提，以表格形式
- 总结哪些前提很重要

细节
- 区分：
  - 事实前提
  - 因果前提
  - 概念前提
  - 价值前提
  - 约束前提
- 对每个前提说明：
  - 原问题如何依赖它
  - 若不成立，问题如何变化