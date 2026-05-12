# MEMORY.md — 跨 agent 通用经验池

> Hermes 风格的 MEMORY.md：跨 domain 的通用经验，不属于任何单一 agent 的 learnings。
> 任何 agent 在工作中如果观察到"这条经验对所有 agent 都有用"，追加到这里。
> 由 `kevin-curator` 周巡时合并 / 整理。

---

## 格式

```markdown
## YYYY-MM-DD — <一句话主题>
**情境**：什么场景下学到的
**经验**：具体的"做 X 而不是 Y，因为 Z"
**适用范围**：哪些 agent / 哪类任务
```

---

## Entries

<!-- 第一条示例（Kevin 或 curator 验证后保留 / 删除）：

## 2026-05-11 — Hermes 学习闭环靠 hook 才能跑起来
**情境**：4 agent 旧版把"完成任务后强制检查"写在 prompt 里，半个月没积累任何 facts/learnings
**经验**：依赖 LLM 自觉的成长机制必然失效；要用 SubagentStop / Stop hook 强制触发
**适用范围**：所有 agent；架构层面

-->
