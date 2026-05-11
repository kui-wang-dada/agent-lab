---
name: weekly-review
description: 生成本周复盘文档。每周日或月底使用，整理 ideas/logs/plans 的变化。
domain: assistant
created: 2026-05-11
updated: 2026-05-11
---

# 周复盘流程

## 触发条件

- 用户说"做本周复盘""周报""week review"
- 周日自动触发（若有 cron / Routines）

## 输入

- `~/Project/profile/project/kevin-hub/ideas/` 全部文件
- `~/Project/profile/project/kevin-hub/logs/` 本周以来的文件
- `~/Project/profile/project/kevin-hub/plans/` 全部
- `~/.claude/skills/` 列表（看本周新增了什么）
- `~/.claude/memory/*/learnings.md`（看本周学到什么）

## 步骤

1. 找到本周时间窗口（周一到周日）
2. `git log --since="last monday"` 看 kevin-hub 这周的变化
3. 扫 ideas 目录：哪些状态变了、哪些是新增的、哪些被放弃
4. 扫 skills 目录：本周新增/修改了哪些 skill
5. 扫 memory：本周 agent 学到了什么
6. 按下方"输出格式"生成复盘
7. 写到 `~/Project/profile/project/kevin-hub/logs/week-<YYYY-WW>.md`

## 输出格式

```markdown
# Week <ISO 周号> 复盘 (<起止日期>)

## 本周进展
- 想法变化：<新增 X 个 / 落地 Y 个 / 放弃 Z 个>
- 业务：<Upwork 进展、客户事>
- 内容：<发了什么>
- 学习：<学到的新知识>

## Agent 体系成长
- 新增 skill：<列表>
- 新学到的事实：<列表>
- 新积累的经验：<列表>

## 待解决的事

## 下周重点（3 件事内）
```

## 已知陷阱

- 不要按"日期"列时间线（Kevin 嫌冗长）
- 按"主题"分组更有用
- 控制在一屏内（< 500 字）

## 更新日志

- 2026-05-11: 初版
