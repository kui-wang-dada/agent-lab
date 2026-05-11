# Kevin 的共享 Skill 库

> 所有 subagent 共享的可复用经验。skill 是"做某类任务的标准操作流程"。

## 写作规范（agentskills.io 标准）

每个 skill 一个 markdown 文件，文件名用短横线分隔：`<domain>-<topic>.md`

例：
- `biz-upwork-proposal.md`
- `dev-fastapi-error-handling.md`
- `content-xhs-note-format.md`
- `assistant-weekly-review.md`

## 文件结构

```markdown
---
name: <skill-name>
description: 一句话说清这个 skill 是干什么的，何时使用
domain: biz | dev | content | assistant | general
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# <Skill 标题>

## 触发条件
什么类型的任务应该用这个 skill

## 输入
完成这个任务需要哪些信息/文件

## 步骤
1. ...
2. ...
3. ...

## 输出格式
最终产出长什么样

## 已知陷阱
踩过的坑，避免重复

## 更新日志
- YYYY-MM-DD: 初版
- YYYY-MM-DD: <改进点>
```

## 创建规则（agents 必须遵守）

- 任务可泛化（适用 2+ 次类似场景）才写 skill
- 一次性任务不写 skill（避免库膨胀）
- 同主题已有 skill 优先更新而非新建
- 每个 skill 控制在 100 行内（长了拆分）

## 检索方式

agent 工作前可以 `ls ~/.claude/skills/ | grep <domain>` 看是否有相关 skill 可复用。
