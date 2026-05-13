---
title: 用 Claude Code 原生能力复刻 Hermes 风格的自我成长 Agent 体系
author: Kevin Wang (王奎)
date: 2026-05-13
version: 1.0
abstract: 基于 Anthropic Claude Code 的 Agents / Skills / Hooks / MCP 原语，构建一套与 Nous Research 的 Hermes Agent 功能等价的个人多 Agent 系统，支持跨 session 长期记忆、自动 skill 抽取、用户建模周更新、跨子项目协调执行。本文记录设计动机、架构映射、实现细节与运行效果。
---

# 用 Claude Code 原生能力复刻 Hermes 风格的自我成长 Agent 体系

## Abstract

本文描述如何用 Anthropic Claude Code 的原生原语（Agents、Skills、Hooks、MCP）实现一套与 [Nous Research Hermes Agent](https://github.com/nousresearch/hermes-agent) 功能等价的个人多 Agent 系统。系统在项目级 `.claude/` 目录下定义 12 个职责分离的 Agent、3 个生命周期 hook、分层记忆体系（USER.md / MEMORY.md / per-agent facts.md / learnings.md / SKILLS_INDEX.md），以及一个由 launchd 周期触发的 curator agent，实现学习闭环。系统不依赖任何第三方 framework，部署成本接近零（仅需 Claude Code CLI 已安装），并保留了 Hermes 的核心特征：自动 skill 创建、跨 session 记忆、用户模型周期更新、agent-curated memory。

---

## 1. 背景与动机

### 1.1 单 Agent 的局限

使用 Claude Code 长期开发存在以下问题：

1. **上下文重复构建**：每次新 session 需重新告知用户偏好、项目位置、技术栈
2. **角色混淆**：单 Agent 同时扮演产品、前端、后端、测试，注意力切换成本高
3. **学习不持久**：上一次 session 学到的经验，下一次 session 已遗忘
4. **跨项目割裂**：自由职业者通常并行多项目（客户、自媒体、个人产品），各项目 Agent 互不知情

### 1.2 Hermes Agent 的启发

Nous Research 的 Hermes Agent 提出"自我学习闭环"作为内置能力，其核心特征为：

| 特征 | 描述 |
|---|---|
| Skills 闭环 | Agent 在使用中改进 skill，并在复杂任务后自动创建新 skill |
| Periodic nudges | Agent 自身定期触发记忆持久化 |
| User modeling | 维护一个不断深化的用户模型（USER.md） |
| Cross-session search | 可搜索自身过往对话 |
| Agent-curated memory | 记忆由 agent 整理而非用户手动写 |

### 1.3 为什么不直接使用 Hermes

1. **Provider 锁定问题**：Hermes 设计为 multi-provider；本文作者使用客户提供的 Anthropic Max 订阅，不需要跨 provider 抽象
2. **部署成本**：Hermes 需独立 Python 环境、自建 messaging gateway、独立状态存储
3. **能力重叠**：Claude Code 已原生提供 Agents、Skills、Hooks、MCP、跨 session 搜索、定时任务等核心原语

结论：用 Claude Code 原生能力实现等价系统，避免重复造轮子。

---

## 2. 设计目标

| # | 目标 | 优先级 |
|---|---|---|
| 1 | 12 个职责分离的 Agent，按"思考模式"而非"技术栈"切分 | P0 |
| 2 | 跨 Agent 共享的用户模型 + 经验池 | P0 |
| 3 | Agent 完成任务后自动触发记忆 / skill 候选评审 | P0 |
| 4 | 一个 curator agent 周期性整合记忆、抽 skill、更新用户模型 | P0 |
| 5 | Agent 可直接操作 sibling 项目（自媒体 pipeline、Upwork 投递、量化系统等），不需用户手动切换 cwd | P1 |
| 6 | 跨 session 记忆查询能力 | P1 |
| 7 | 路由层支持手机端短消息分发 | P2 |

---

## 3. 概念映射：Hermes → Claude Code

| Hermes 概念 | Claude Code 对应 | 实现状态 |
|---|---|---|
| Agent core / loop | Session | 原生 |
| 40+ tools | Bash + Read/Write + MCP servers | 原生 |
| Skills subsystem (自我改进) | Claude Code Skills | 原生 |
| Multi-provider | 仅 Anthropic | 不需要 |
| Messaging gateway (Slack/Telegram/...) | Slack MCP + RemoteTrigger | 部分原生 |
| Personality (SOUL.md) | 每个 agent 的 prompt frontmatter | 原生 |
| State (`hermes_state.py`) | session.jsonl + memory/ | 原生 |
| Cron scheduler | macOS launchd | 平台原生 |
| Parallel subagents | Agent tool | 原生 |
| Honcho dialectic (用户建模) | curator agent + USER.md | **自建** |
| FTS5 跨 session 搜索 | `mcp__ccd_session_mgmt__search_session_transcripts` | 原生 MCP |
| Skill 自动 nudge | SubagentStop hook | **自建** |
| MEMORY.md / USER.md | per-agent facts.md + 共享 USER.md | **自建** |

约 90% 能力由 Claude Code 原生提供，需自建的部分仅 4 项：

1. USER.md（共享用户模型）
2. MEMORY.md（跨 agent 经验池）
3. 三个 hook 脚本（SessionStart / Stop / SubagentStop）
4. curator agent（周巡）

---

## 4. 架构总览

```
┌─────────────────────────────────────────────────────────────┐
│             CEO 层 (agent-lab/.claude/)                     │
│                                                             │
│  Routing:                                                   │
│    kevin-router (sonnet)                                    │
│                                                             │
│  Generic:                                                   │
│    kevin-assistant (opus)  kevin-curator (opus)             │
│                                                             │
│  Business:                                                  │
│    kevin-upwork    kevin-domestic   kevin-research          │
│    kevin-media                                              │
│                                                             │
│  Engineering (shared kevin-dev/facts.md):                   │
│    kevin-product   kevin-architect                          │
│    kevin-frontend  kevin-backend    kevin-qa                │
│                                                             │
│  Memory: USER.md / MEMORY.md / SKILLS_INDEX.md +            │
│          per-agent {facts, learnings}.md                    │
│                                                             │
│  Hooks: SessionStart / Stop / SubagentStop                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ reads / writes
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         Sibling Projects Layer (执行层)                      │
│                                                             │
│  ~/Project/profile/project/                                 │
│    media/         ← Docker 剪辑流水线 + 6 skills             │
│    upwork-hunter/ ← 简历库 + 投递记录 + 策略                  │
│    quant/         ← Crypto Sentinel v2                      │
│    indie-dev/     ← 产品调研                                 │
│    kevin-hub/     ← 历史想法池                               │
│                                                             │
│  ~/Project/profile/code/                                    │
│    tianda-web/    ← 个人品牌门户 V2                          │
│                                                             │
│  ~/Project/work/                                            │
│    upwork-2025-*  ← 客户项目                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ schedules
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         macOS launchd                                        │
│                                                             │
│  com.kevin.agent-lab-curator.plist                          │
│  → 每周日 21:30 触发 kevin-curator 周巡                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Agent 编制

### 5.1 编制表

| Agent | 模型 | 职责 | 共享 facts |
|---|---|---|---|
| kevin-router | sonnet | 看消息派单（含 `@xxx` 前缀解析、客户语言判断） | 无 |
| kevin-assistant | opus | 杂事 catch-all：邮件、消息、日程、跨 session 查询、跨 agent 协调 | 独占 |
| kevin-curator | opus | 周巡：抽 skill 候选 / 整合 facts / 更新 USER.md / 刷新 SKILLS_INDEX.md | 独占 |
| kevin-upwork | opus | 所有英文客户全生命周期：Upwork 提案 + 邮件 + 合同 + 报价 (USD) | 独占 |
| kevin-domestic | opus | 所有中文客户全生命周期：朋友转介 + 报价 + 合同 + 工期 (CNY) | 独占 |
| kevin-research | opus | 多源情报、长期标的追踪、调研报告产出 | 独占 |
| kevin-media | opus | 自媒体执行：选题 + 文案 + 剪辑流水线 + 多平台图文 | 独占 |
| kevin-product | opus | 需求澄清、PRD、用户故事、MVP 切片 | shared (kevin-dev) |
| kevin-architect | opus | 系统拆分、API 契约、ADR、跨 fe+be 协调（触发严格） | shared (kevin-dev) |
| kevin-frontend | opus | Next.js / RN / Tailwind / 任何前端代码 | shared (kevin-dev) |
| kevin-backend | opus | FastAPI / Node / DB / API / 第三方集成 | shared (kevin-dev) |
| kevin-qa | sonnet | 测试、bug 复现、E2E、回归 | shared (kevin-dev) |

### 5.2 切分原则

- **按"职责"切而非按"技术栈"切**：`kevin-frontend` 同时负责 Next.js + RN + Tailwind，因为核心心智是"用户视角 + 组件思维"
- **业务层按"语言"切而非"sales/delivery"切**：英文客户与中文客户的文化、合规、报价、合同条款差异大于销售期与交付期的差异
- **dev 类 agent 共享 facts**：技术偏好（不写 `any`、不吞异常等）对 product/fe/be/qa 通用，无需重复维护

### 5.3 路由前缀

| 前缀 | 派给 |
|---|---|
| `@assistant` 或无前缀 | kevin-assistant |
| `@upwork` `@up` | kevin-upwork |
| `@domestic` `@dm` `@cn` | kevin-domestic |
| `@research` `@rs` | kevin-research |
| `@media` | kevin-media |
| `@product` | kevin-product |
| `@architect` `@arch` | kevin-architect |
| `@frontend` `@fe` | kevin-frontend |
| `@backend` `@be` | kevin-backend |
| `@qa` `@test` | kevin-qa |
| `@curator` | kevin-curator（手动触发周巡） |
| `@router` | kevin-router（不明确时由它二次决定） |

---

## 6. 记忆体系

### 6.1 文件结构

```
.claude/memory/
├── USER.md              # 跨 agent 共享的用户模型
├── MEMORY.md            # 跨 agent 通用经验池
├── SKILLS_INDEX.md      # skill 索引（项目级 + 用户级）
├── _review-queue/       # SubagentStop hook 写入，等 curator 周巡评审
├── business-plan.md     # 业务规划全文（从 sibling 项目迁入）
├── profile/             # 中英文简历
└── kevin-<agent>/
    ├── facts.md         # 该 agent 视角的事实积累
    └── learnings.md     # 该 agent 的经验教训
```

### 6.2 USER.md 结构

模仿 Hermes 的"deepening user model"概念，分 4 个区块：

| 区块 | 更新频率 | 内容 |
|---|---|---|
| Identity | 半年 | 角色、位置、家庭、长期目标、公开身份 |
| Working Style | 月 | 协作偏好、沟通风格、工程偏好 |
| Current Focus | 季度 | 在跑项目、当前主要矛盾、季度目标 |
| Hot Context | 周 | 本周在做什么、近期讨论 |

由 curator 自动维护。Change Log 段落记录每次更新 diff。

### 6.3 facts.md vs learnings.md

| 文件 | 内容 | 更新方式 |
|---|---|---|
| facts.md | 关于 Kevin 的稳定事实（偏好、报价档位、技术栈、客户类型）| Agent 在工作中观察后追加 |
| learnings.md | Agent 自己学到的工作经验（哪些方法有效/失败、踩过的坑）| Agent 在任务结束后追加 |

格式：

```markdown
## YYYY-MM-DD — <主题>
**情境**：什么场景
**经验**：什么有效 / 什么失败 / 为什么
**适用场景**：何时引用
```

### 6.4 SKILLS_INDEX.md

由 curator 周巡时刷新。包含项目级（`.claude/skills/`）和用户级（`~/.claude/skills/`）所有 skill，含 description、domain、上次使用时间。

domain 命名约定：`<agent-prefix>-<topic>.md`，例如 `upwork-cover-letter.md` / `fe-nextjs-component.md`。

---

## 7. 学习闭环：Hooks 实现

### 7.1 三个 hook

定义在 `.claude/settings.json`：

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh",
        "timeout": 10
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/stop.sh",
        "timeout": 10,
        "async": true
      }]
    }],
    "SubagentStop": [{
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/subagent-stop.sh",
        "timeout": 10,
        "async": true
      }]
    }]
  }
}
```

### 7.2 各 hook 职责

| Hook | 触发时机 | 动作 |
|---|---|---|
| `session-start.sh` | 每次 session 启动 | 输出 USER.md 摘要 + SKILLS_INDEX.md 给模型 context（通过 `hookSpecificOutput.additionalContext`） |
| `subagent-stop.sh` | 每个子 agent 任务结束 | 提取 session_id / agent_name / transcript_path / user_intent_snippet，写入 `_review-queue/<TS>-subagent.json` |
| `stop.sh` | 主 session 结束 | 写入 `_review-queue/<TS>-session.json`，含 `stop_hook_active` 防死循环检测 |

### 7.3 hook 设计要点

- 所有 hook 用 jq 解析 stdin JSON，缺字段时降级（避免 hook 失败阻塞 session）
- subagent-stop 用 `jq -rs` 解析 transcript JSONL（跨平台，避免 macOS 缺 `tac` 命令的问题）
- Stop / SubagentStop 设 `async: true`，不阻塞主对话流
- Stop hook 检测 `stop_hook_active` 字段，防止 hook 自身触发新的 stop 事件造成死循环

### 7.4 为什么用 hook 而非 agent 自检

第一版设计在每个 agent prompt 末尾加"任务后检查是否抽 skill"。实际运行半个月后 0 个 skill 被抽出来——LLM 总能找到理由跳过自检。

将自检从 prompt 移至 hook 后，触发由 Claude Code 强制保证，不再依赖 LLM 自觉。

---

## 8. Curator: 周期性整合机制

### 8.1 调度

由 macOS launchd 触发，配置文件 `~/Library/LaunchAgents/com.kevin.agent-lab-curator.plist`：

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key><integer>0</integer>
    <key>Hour</key><integer>21</integer>
    <key>Minute</key><integer>30</integer>
</dict>
<key>ProgramArguments</key>
<array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>cd /Users/wkui/Project/profile/project/agent-lab &amp;&amp; \
            /opt/homebrew/bin/claude -p "@kevin-curator 执行周巡 4 步流程" \
            --permission-mode acceptEdits</string>
</array>
```

每周日 21:30（Asia/Shanghai）自动触发。日志落 `agent-lab/logs/curator.{out,err}.log`。

### 8.2 周巡 4 步

| 步 | 动作 | 输出 |
|---|---|---|
| 1 | 读 `_review-queue/` 所有 metadata，找重复操作模式 | `.claude/memory/_skill-candidates-YYYY-WW.md`（候选 skill 清单，待 Kevin 审批） |
| 2 | 扫各 facts.md，合并语义重复条目，标记过时事实为 DEPRECATED | 修改 facts.md（不删过时条目，仅注释） |
| 3 | 读所有 facts + 最近 N 个 session（用 `search_session_transcripts`），合成 USER.md | USER.md 更新，diff 进 Change Log |
| 4 | `ls .claude/skills/` 提取 frontmatter，结合最近 30 session 的引用频次 | SKILLS_INDEX.md 刷新 |

### 8.3 设计原则

- **不直接修改 skill 文件**：抽出候选写入 `_skill-candidates-WW.md`，由 Kevin 周一审批后人工 commit
- **不删 facts**：过时条目仅标 `<!-- DEPRECATED YYYY-MM-DD -->`，保留历史可追溯
- **不修改 business-plan.md**：业务规划由 Kevin 自己维护

---

## 9. Sibling Project 执行模型

### 9.1 三层心智

```
CEO 层 (agent-lab)         Sibling 项目 (执行)         macOS launchd (调度)
────────────────────       ───────────────────         ─────────────────
思考、决策、记忆、协调  →   实际产出 + 行业 know-how   ←  周期性自动触发
```

### 9.2 Agent → 项目映射

每个 agent 在 prompt 中显式声明其主要操作目录、关键资产路径、可调用的 skill、标准命令、决策表（"用户说 X → 你做 Y"）。

例如 kevin-media 的映射段：

```
工作目录: ~/Project/profile/project/media/

关键资产:
  CLAUDE.md (17KB)
  inbox/ideas/wXX.md           当周选题
  inbox/trending/YYYY-MM-DD.md 周日 21:00 雷达任务自动写入
  episodes/2026-Wxx-<slug>/    每期工作目录
  docker-compose.yml + .env    剪辑入口

可调用 skills (在 media 项目里):
  script-polish    选题 + 粗稿 → brief + 文案
  video-pipeline   原材料 → 成片
  platform-posts   成片 → 多平台图文
  brand            维护 kevin-voice.md
  topic-radar      抓素材

标准命令:
  cd ~/Project/profile/project/media
  echo "EPISODE=2026-Wxx-<slug>" > .env
  docker compose run --rm pipeline             # 全片
  PREVIEW=60 docker compose run --rm pipeline  # 预览前 60s
```

### 9.3 工具配置

为支持 cd + 跑命令，6 个 thinking-layer agent（media / upwork / domestic / research / product / curator）prompt frontmatter 中加入 `Bash` 工具：

```yaml
tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch, WebSearch, mcp__ccd_session_mgmt__search_session_transcripts
```

---

## 10. 实现：关键文件清单

```
agent-lab/
├── .claude/
│   ├── CLAUDE.md                       # 总规则、路由表、心智模型
│   ├── settings.json                   # hooks 配置
│   ├── settings.local.json             # 本地覆盖（acceptEdits 等，gitignored）
│   ├── agents/                         # 12 个 agent prompt
│   │   ├── kevin-router.md             (sonnet)
│   │   ├── kevin-assistant.md          (opus)
│   │   ├── kevin-curator.md            (opus)
│   │   ├── kevin-upwork.md             (opus)
│   │   ├── kevin-domestic.md           (opus)
│   │   ├── kevin-research.md           (opus)
│   │   ├── kevin-media.md              (opus)
│   │   ├── kevin-product.md            (opus)
│   │   ├── kevin-architect.md          (opus)
│   │   ├── kevin-frontend.md           (opus)
│   │   ├── kevin-backend.md            (opus)
│   │   └── kevin-qa.md                 (sonnet)
│   ├── hooks/
│   │   ├── session-start.sh            # 注入 USER.md / SKILLS_INDEX
│   │   ├── stop.sh                     # 主 session 结束
│   │   └── subagent-stop.sh            # 子 agent 结束
│   ├── memory/
│   │   ├── USER.md                     # 用户模型，4 区块
│   │   ├── MEMORY.md                   # 跨 agent 经验池
│   │   ├── SKILLS_INDEX.md
│   │   ├── business-plan.md
│   │   ├── profile/
│   │   │   ├── kevin-fe-jd.md          # 中文简历
│   │   │   └── kevin-fe-jd-en.md       # 英文简历
│   │   ├── _review-queue/              # hook 写入目录
│   │   │   └── README.md
│   │   ├── research-notes/             # research agent 调研产出
│   │   │   └── README.md
│   │   └── kevin-<agent>/
│   │       ├── facts.md
│   │       └── learnings.md
│   └── skills/                         # 项目级可复用 skill 池
│       └── README.md
└── docs/
    └── hermes-clone-with-claude-code.md  # 本文
```

外部文件：

```
~/Library/LaunchAgents/
└── com.kevin.agent-lab-curator.plist   # 周日 21:30 触发 curator
```

---

## 11. 运行结果

### 11.1 跨域路由测试

测试用例：在主 session 发送 `@kevin-frontend 我想给某项目加用户头像上传功能（含后端存储）。先告诉我你打算怎么处理这个任务，不要直接动手。`

预期：frontend agent 应识别此为跨边界任务（同时涉及 fe 和 be），停手并路由到 architect。

实际响应（节选）：

> 我目前能确定的：**这任务应该走 architect 而不是 frontend**（理由：跨 fe+be，符合你 CLAUDE.md 里 architect 的触发条件①）。
>
> 但在 dispatch 任何 agent 之前，我需要你补三件事...

agent 主动引用 CLAUDE.md 的触发条件，符合设计预期。

### 11.2 Curator 首次运行反馈系统缺陷

通过 `launchctl kickstart` 手动触发 curator。运行 ~30 秒，输出 2279 字节报告，其中包含 self-discovered 系统缺陷：

> ⚠️ **关键阻塞：sandbox 拦截**
>
> `.claude/memory/` 整目录受 sandbox 保护，curator **无法直接写入**。3 处变更已转为待审 patch：
>
> 1. `kevin-assistant/facts.md` — 把过时的"项目仓库 kevin-hub"段标 DEPRECATED
> 2. `USER.md` — Last updated 时间戳 + Hot Context 追加 + Change Log
> 3. `SKILLS_INDEX.md` — 时间戳 + 项目级表刷新 + 用户级 4 行描述补全
>
> Curator 建议固化成 patch 输出模式——更安全，也符合原设计意图（不让 agent 自动改记忆）。

实现细节：curator 首次运行即识别出权限边界问题，并主动给出 A/B/C 三个解决方案，符合"agent-curated memory + periodic nudges"的设计目标。

### 11.3 三 Agent 并行 Code Review

任务：让 architect / frontend / backend 三个 agent 并行 review tianda-web 项目（Next.js 静态导出 + FastAPI + Vite admin）。

执行时间：~15 分钟（3 agent 并行）。

产出（节选）：

| 严重度 | 数量 | 代表问题 |
|---|---|---|
| 🔴 严重 | 4 | X-Forwarded-For 头部注入（slowapi 限速可绕过 + ip_hash 可污染）；OTP 暴力破解（10⁶ 组合 + 限速 10/h，~15h 可穷举）；ADMIN_TOKEN 静态后门残留；CORS 默认值缺生产域 |
| 🟡 架构债务 | 5 | 类型契约 fe/admin/be 三处独立定义；CommentOut.target_type 无 Literal 约束；章节页 SSG 与原 CSR 约定相反 |
| 🟢 代码质量 | 6 | ProTable total 全表 load；末章 link 无判断；异步操作无 try/catch |

X-Forwarded-For 注入是真实存在的 0day 级安全漏洞，非 LLM 幻觉。

---

## 12. 限制与未来工作

### 12.1 当前已知限制

1. **Sandbox 拦截 `.claude/memory/` 写入**：curator 通过 `claude -p` 调用时受 sandbox 限制，无法直接写记忆文件。临时方案是改 prompt 让 curator 输出 patch 到 `_curator-pending/` 目录，由人工 apply
2. **Token 成本高**：12 个 agent 中 11 个为 opus，复杂任务可能并行调用 5-10 个子 agent。在 API key 计费模式下成本可观；订阅模式下不构成约束
3. **冷启动空记忆**：新建系统的 facts/learnings 为模板状态，需运行 4-8 周才积累出有意义的 agent 个性
4. **跨 cwd 限制**：项目级 agent 仅在 `agent-lab` cwd 下生效，其他项目目录无法直接 `@kevin-frontend`。可通过 user-level 部署解决，但会失去项目隔离
5. **Hook 验证依赖真实 subagent 触发**：当前测试均以主 session 直接响应完成，SubagentStop hook 实际触发频次有限，需更多真实 subagent 任务后才能验证

### 12.2 未来工作

| 优先级 | 工作项 |
|---|---|
| P0 | 修 sandbox 拦截，让 curator 改 patch-output 模式 |
| P1 | 集成 Slack MCP / Gmail MCP，让 assistant 真正接 inbox |
| P1 | 加 OpenAPI 类型生成脚本（fe/admin/be 类型契约自动同步） |
| P2 | 评估 user-level 部署可行性（vs 项目级） |
| P2 | 为 architect 加 ADR 模板自动化 |
| P3 | 引入 PostCompact hook，压缩后注入近期决策摘要 |

---

## 13. 参考资料

1. Nous Research, "Hermes Agent" — https://github.com/nousresearch/hermes-agent
2. Anthropic, "Claude Code Documentation" — https://docs.claude.com/en/docs/claude-code
3. Anthropic, "Claude Code Hooks Reference"
4. Anthropic, "Agent Skills (agentskills.io)" 标准

---

## Appendix A: 核心代码清单

### A.1 SubagentStop Hook

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
QUEUE="$ROOT/.claude/memory/_review-queue"
mkdir -p "$QUEUE"

PAYLOAD="$(cat)"
SESSION_ID="$(echo "$PAYLOAD" | jq -r '.session_id // "unknown"')"
TRANSCRIPT="$(echo "$PAYLOAD" | jq -r '.transcript_path // ""')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TS_FILE="$(date +%Y-%m-%d-%H%M%S)"

AGENT="unknown"
[[ "$TRANSCRIPT" == *subagents* ]] && AGENT="$(basename "$TRANSCRIPT" .jsonl)"

USER_INTENT=""
if [ -f "$TRANSCRIPT" ]; then
  USER_INTENT="$(jq -rs '
    [.[] | select(.role? == "user" or .type? == "user")][0]
    | (.message.content // .content // "")
    | if type == "array" then map(.text // "") | join(" ") else tostring end
  ' "$TRANSCRIPT" 2>/dev/null | head -c 200 || true)"
fi

jq -n \
  --arg ts "$TS" --arg session "$SESSION_ID" --arg agent "$AGENT" \
  --arg transcript "$TRANSCRIPT" --arg intent "$USER_INTENT" \
  '{type:"subagent", timestamp:$ts, session_id:$session, agent:$agent,
    transcript_path:$transcript, user_intent_snippet:$intent}' \
  > "$QUEUE/$TS_FILE-subagent.json"

echo '{}'
```

### A.2 SessionStart Hook（注入 USER.md 摘要）

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
USER_MD="$ROOT/.claude/memory/USER.md"
SKILLS_IDX="$ROOT/.claude/memory/SKILLS_INDEX.md"

cat > /dev/null 2>&1 || true  # 吞 stdin

{
  echo "## 自动注入：用户模型摘要"
  awk '/^## (Identity|Working Style|Current Focus|Hot Context|Critical Constraints)/{p=1} /^---$/{p=0} p' \
    "$USER_MD" 2>/dev/null | head -80
  echo
  echo "## 自动注入：Skill 索引"
  head -40 "$SKILLS_IDX" 2>/dev/null
} > /tmp/agent-lab-session-start-context.txt

jq -Rs '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: .
  }
}' < /tmp/agent-lab-session-start-context.txt
```

---

## Appendix B: 路由决策表（kevin-router）

| 消息特征 | 派给 |
|---|---|
| 含"client / proposal / Upwork / quote / contract" + 语言英文 | kevin-upwork |
| 含"甲方 / 朋友 / 国内项目 / 报价 / 合同 / 工期 / 介绍" + 语言中文 | kevin-domestic |
| 含"调研 / 最新 / X 代币 / 热点 / 趋势 / 新闻 / research" | kevin-research |
| 含"视频 / 选题 / 公众号 / 抖音 / B站 / 文案 / 自媒体" | kevin-media |
| 含"PRD / 需求 / 用户故事 / 产品定义 / 我想做一个" | kevin-product |
| 含"架构 / 接口契约 / ADR / 技术选型 / 系统拆分 / 跨服务" | kevin-architect |
| 含"前端 / Next.js / React / Tailwind / 组件 / RN" | kevin-frontend |
| 含"后端 / API / 数据库 / FastAPI / Node / Prisma" | kevin-backend |
| 含"测试 / bug 复现 / E2E / Playwright / 失败用例" | kevin-qa |
| 含"邮件 / 消息 / inbox / 微信 / Slack / 日程 / 提醒" | kevin-assistant |
| 都不像 / 含糊 | kevin-assistant（默认） |

引用客户原文时按客户语言决定派单；Kevin 用中文描述任务时按客户身份决定。

---

*文档结束。完整代码见 `agent-lab/` 项目仓库。*
