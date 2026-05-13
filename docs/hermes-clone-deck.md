---
title: 用 Claude Code 复刻 Hermes
subtitle: 我的 10 人 AI 团队
author: Kevin Wang (王奎)
date: 2026-05-13
type: 5 张幻灯片演讲源
ref: 完整技术细节见 hermes-clone-with-claude-code.md
---

<!-- ============ Slide 1 / 5 — 封面 ============ -->

# 用 Claude Code 复刻 Hermes

## 我的 10 人 AI 团队

王奎 (Kevin Wang) · 2026-05

---

<!-- ============ Slide 2 / 5 — 问题 + 灵感 ============ -->

# 为什么要做这个

## 单 Agent 用了一年，4 个痛点

- 每次新对话都要**重喂上下文**（我是谁、做什么、口味）
- 单 Agent 同时演产品/写代码/测试，**注意力切换累**
- 上次学到的经验，下次 session **已遗忘**
- 4 个并行项目（客户/自媒体/产品/量化）的 AI **互不通气**

## 灵感：Hermes Agent (Nous Research)

> "内置学习闭环的 AI Agent — 创建技能 / 改进 / 自我提醒 / 搜过往对话 / 对你的认识越来越深"

不直接装（部署成本 + 与 Claude Code 重叠 90%）→ **借思路自己拼**

---

<!-- ============ Slide 3 / 5 — 文件结构（核心）============ -->

# 文件结构：一目了然

```
.claude/
├── CLAUDE.md         公司规则书（所有员工启动必读）
├── settings.json     自动化触发器配置
├── agents/           10 个员工的工作描述（见下表）
├── hooks/            3 个自动化脚本（员工不知不觉触发）
├── memory/           公司共享知识库
│   ├── USER.md            关于"老板"的画像
│   ├── MEMORY.md          跨员工通用经验池
│   ├── SKILLS_INDEX.md    可复用工作流程清单
│   ├── business-plan.md   业务规划
│   ├── profile/           简历（中英文）
│   ├── _review-queue/     Hook 写入的待审笔记
│   ├── research-notes/    情报员的调研报告
│   └── kevin-<员工>/      每员工独立: facts.md + learnings.md
└── skills/           可复用技能库
```

## 10 个员工（agents/ 下）

| 部门 | 员工 | 职责 |
|---|---|---|
| 路由 | router | 看消息派单 |
| 通用 | assistant · curator | 杂事 / 周自动整理知识库 |
| 业务 | upwork · domestic | 英文客户 / 中文客户 |
| 业务 | research · media | 多源调研 / 自媒体执行 |
| 研发 | product · coder · qa | PRD / 全栈实现 / 测试 |

> **coder 一体化**：架构 + 前端 + 后端合并。AI 没有"一个人不可能精通所有"的人类约束，复杂任务现派 subagent。

---

<!-- ============ Slide 4 / 5 — 一个例子 ============ -->

# 一个例子：复杂任务自己拆，并行干

**👤 输入**：`@kevin-coder` 帮我审一下 tianda-web 项目（前端 + 后端 + 后台 3 个子项目）

**🤖 coder 的回复**（要点）：

- 这是大型 review，单 session 撑不住，**我拆 3 个并行 subagent**：
  1. spawn architect 视角的 reviewer：审跨边界契约、ADR 缺失
  2. spawn frontend 视角的 reviewer：审 UI、i18n、静态导出违规
  3. spawn backend 视角的 reviewer：审 API、安全、限流、密钥
- 三个并行跑，15 分钟后聚合

**🔍 真实结果**

- 找出 **4 个 🔴 严重安全漏洞**（含 X-Forwarded-For 注入这种真 0day）
- 5 个🟡 架构债务（含 fe/admin/be 类型契约 3 处独立定义）
- 6 个🟢 代码质量问题

→ 一个 coder + spawn 并行 subagent ＝ 既不预设细分员工，又能多视角覆盖。

---

<!-- ============ Slide 5 / 5 — 总结 + GitHub ============ -->

# 总结

## 一句话

**用 Claude Code 自己的零件 + 4 个自建组件，3 天搭出与 Hermes 等价的个人 AI 团队。**

## 现实约束

- 不是开箱即用（要花 2-3 天搭骨架 + 写各员工的工作描述）
- 冷启动空（4-8 周才积累出真正"懂你"的状态）
- Token 高（订阅模式无感，按 API 计费的人慎重）

## 接下来

- **一周内开源到 GitHub**
- github.com/kui-wang-dada
- tianda.studio

---

谢谢。
