---
title: 用 Claude Code 复刻 Hermes 风格：自我成长的个人 AI 员工体系
author: Kevin Wang
date: 2026-05-13
status: draft（视频源文档，待 media/.claude/skills/script-polish 提炼成视频脚本）
target: 周六（2026-05-16）视频选题候选
platforms: 抖音 + B 站（国内合规）
estimated_video_length: 12-15 分钟
---

# 用 Claude Code 复刻 Hermes 风格：自我成长的个人 AI 员工体系

> 本文是技术源文档。视频脚本由此提炼，时长压到 1000-1500 字口播稿。
> 文中带 `📹` 的段落是建议视频化讲解的高密度节点；带 `🖼️` 是适合截图/录屏演示。

## TL;DR

我接了一年多 Upwork，每天用 Claude Code 写代码。但我一直觉得自己用 AI 的方式太"古法编程"——还把它当某一个环节的助手，没把整个工作流梳理通。最近看到 Nous Research 的 Hermes Agent，它把"自我学习闭环"做成了 agent 的内置能力，让我想清楚自己想要什么。

但我不想装 Hermes——我的 Max 订阅是甲方提供的，跨 provider 那套用不上。所以我用 **Claude Code 原生的 Agents + Skills + Hooks + MCP**，3 天搭出了一套**等价系统**：12 个不同维度的 AI 员工，能跨项目协作，有长期记忆，会自己抽 skill，每周自我巡检。

效果：现在我说"@kevin-frontend 我想加个用户头像上传"，它自己会发现这事跨前后端，停手调 architect 先定契约；说"@kevin-media 帮我剪 W19 那期"，它自动 cd 到 media 项目改 .env 跑 docker compose。**不需要我再喂上下文。**

---

## 1. 起源：Vibe Coding 的卡点

📹 **建议视频化讲解：本节最适合做开场钩子**

最近我在做韩国客户的活（Venus，AI 美妆 App）。每天的工作流大概是这样：

1. 早晨去 Slack 看新需求 + 沟通记录
2. **下载 Slack 里的图片**（Slack MCP 不支持下图，每天手动 2-3 分钟）
3. 把记录 + 图贴给 Claude
4. 它给计划，我 review，开始干
5. 真机测试，反复改

这套流程不慢——但**我越用越觉得自己思路不对**。我把 Claude 当成"某个环节的执行器"，而不是把所有环节都让它接管。

🖼️ **截图建议**：贴个 Slack 沟通截图（脱敏处理，只保留时间轴），说"每天就这一个动作我自己做了一年"

我之前的方案：在当前项目里建一个 `.claude/agents/` 目录，放 4 个角色（pm / fe / be / qa）。但这玩意儿是项目级的，**每个项目要复制一份**。而且我 Upwork 接的活、自媒体、量化策略、个人站重构——四个项目并行，agent 互不知道对方学到什么。

唏嘘的是，我用了一年 Claude Code，竟然没意识到这套体系可以共用记忆。

---

## 2. Hermes 给了我灵感（但我没装）

📹 **建议视频化讲解：本节适合穿插 GitHub 截图**

[Nous Research 的 Hermes Agent](https://github.com/nousresearch/hermes-agent) 是个开源项目。他们自己的标语很狂——"**The only agent with a built-in learning loop**"：

> creates skills from experience, improves them during use, nudges itself to persist knowledge, searches its own past conversations, and builds a deepening model of who you are.

翻译成大白话，5 个能力：

1. **学习闭环**：用 skill → 改进 skill → 持久化
2. **agent-curated memory + 周期性 nudges**：不是用户主动写，agent 自己整理后定期提醒
3. **deepening model of who you are**：USER.md 越来越准
4. **search its own past conversations**：跨 session 记忆
5. **autonomous skill creation**：复杂任务后自动抽 skill

我看完想：这就是我想要的"成长性员工"。每次跟新前端 agent 说一遍我的偏好太累，应该让他**自己记住**。

🖼️ **截图建议**：Hermes Agent 的 GitHub README 顶部（技术圈共识工具，国内合规可露）

**但我没装。三个原因**：

1. **订阅冲突**：Hermes 设计成 multi-provider，我用的 Max 订阅是甲方提供的，跨 provider 用不上
2. **重新部署成本**：装一套独立的 agent 框架 + 接 messaging gateway，工时太大
3. **Claude Code 已经有 80% 的能力**：Agents、Skills、Hooks、MCP——这些原语已经够拼出 Hermes 的核心

所以我决定：**用 Claude Code 原生能力复刻一个等价系统**。

---

## 3. 概念映射：Hermes 的每个能力 → Claude Code 对应物

📹 **建议视频化讲解：本节做架构图最合适**

```
Hermes 概念                Claude Code 等价物         状态
─────────────────────────────────────────────────────────
Agent core / loop      →   Session                  ✅ 原生
40+ tools              →   Bash + Read + MCP         ✅ 已有
Skills subsystem       →   Claude Code Skills        ✅ 完美对应
Multi-provider         →   仅 Anthropic              ⚠️ 我只用 Max
Messaging gateway      →   Slack MCP + RemoteTrigger ✅ 部分
Personality (SOUL.md)  →   每个 agent 的 prompt       ✅
State management       →   session.jsonl + memory/   ✅
Cron scheduler         →   schedule skill            ✅
Parallel subagents     →   Agent tool                ✅
跨 session 搜索         →   ccd_session_mgmt MCP      ✅ 已装
Honcho 用户建模         →   curator agent + USER.md   🆕 自建
Skills 自动 nudge       →   SubagentStop hook         🆕 自建
```

90% 能力 Claude Code 已经有。**真正要补的只有 4 件事**：

1. USER.md（共享用户模型）
2. MEMORY.md（跨 agent 经验池）
3. 三个 hook 脚本（SessionStart / Stop / SubagentStop）
4. curator agent（周巡）

---

## 4. 12 个 agent 编制（按职责拆，不按技能拆）

🖼️ **截图建议**：架构图 + 编制表

```
路由层
  kevin-router      sonnet    看消息派单（前缀 @xxx）

通用层
  kevin-assistant   opus      杂事 catch-all：邮件、消息、日程、inbox
  kevin-curator     opus      Hermes 灵魂：周巡整合记忆 + 抽 skill

业务层（按"语言"切，不按"sales/delivery"切）
  kevin-upwork      opus      所有英文客户：Upwork 提案 + 邮件 + 合同 (USD)
  kevin-domestic    opus      所有中文客户：朋友转介 + 报价 + 合同 (CNY)
  kevin-research    opus      多源情报、代币/项目研究、热点梳理
  kevin-media       opus      自媒体执行：选题 + 文案 + 剪辑流水线

研发层（共享 dev/facts.md）
  kevin-product     opus      PRD / 用户故事 / MVP 切片
  kevin-architect   opus      系统拆分 / API 契约 / ADR（触发严格）
  kevin-frontend    opus      Next.js / RN / Tailwind
  kevin-backend     opus      FastAPI / Node / DB / API
  kevin-qa          sonnet    测试 / 回归 / bug 复现
```

📹 **关键决策瞬间 1**：**为什么按"职责"拆，不按"技能"拆**

第一版我按"技能"分：前端、后端、AI、Web3...每个 agent 一个技术栈。但用了 3 天就发现问题——**我自己同时是前端 + 后端 + AI**，跨技能任务（"做个用户头像上传"）每次都要切 3 个 agent，反而比单 agent 慢。

第二版按"职责"分：产品、架构、前端、后端、测试。每个 agent 负责一种**思考模式**，不是一种工具栈。前端 agent 既能写 Next.js 也能写 RN，因为他的核心是"用户视角 + 组件思维"。

📹 **关键决策瞬间 2**：**业务层为什么按"语言"切**

最早我把 biz agent 设计成"所有商务沟通"。后来发现 Upwork 客户和国内朋友转介的客户**心智模型完全相反**：

- 海外：直接、不寒暄、问澄清问题被视为专业、平等顾问口吻
- 国内：朋友转介有人情、不能太冷也不能太热、底价守住但要给象征性折扣、必签合同

写一个 prompt 里塞两套规则，agent 经常用错。**直接按语言分成两个 agent，prompt 各自集中，错配率立刻降为 0**。

---

## 5. 学习闭环：让系统真正"成长"

📹 **本节是 Hermes 灵魂，必讲**

这是整套系统的核心。让 agent **自己**记住事实、积累经验、抽 skill——不靠我每次手动喂上下文。

### 三个 hooks 触发自检

```json
// .claude/settings.json
{
  "hooks": {
    "SessionStart": [...],   // 注入 USER.md + SKILLS_INDEX
    "Stop": [...],           // 主 session 结束记录
    "SubagentStop": [...]    // 每个子 agent 完成后写 metadata
  }
}
```

🖼️ **截图建议**：settings.json + 三个 hook 脚本目录树

### Memory 文件分层

```
.claude/memory/
├── USER.md              ← 用户模型，4 区块（Identity/Style/Focus/Hot）
├── MEMORY.md            ← 跨 agent 通用经验池
├── SKILLS_INDEX.md      ← skill 索引（自动维护）
├── _review-queue/       ← SubagentStop hook 写入，等 curator 评审
├── business-plan.md     ← 业务规划全文
├── profile/             ← 简历（中英文）
└── kevin-<agent>/
    ├── facts.md         ← 该 agent 视角的事实积累
    └── learnings.md     ← 该 agent 的经验教训
```

📹 **关键决策瞬间 3**：**为什么不靠 LLM 自觉而要用 hook**

第一版我在每个 agent prompt 末尾写"完成任务后强制检查是否抽 skill"。结果半个月跑下来，**0 个 skill 被抽出来**。LLM 总能找到理由跳过自检。

第二版我把它从 prompt 移到 **SubagentStop hook**——一个 bash 脚本，agent 跑完了 Claude Code 必然触发它，没有跳过空间。然后 curator 每周日 21:30 批量评估，**事实从"agent 自觉"变成"系统强制"**。

🖼️ **录屏建议**：演示 curator 第一次跑出来的报告（2279 字节真实输出）

```bash
# 周日 21:30 launchd 自动跑
launchctl print gui/$(id -u)/com.kevin.agent-lab-curator
```

---

## 6. agent → sibling 项目映射（执行层）

📹 **本节是"系统能干活"的关键证明**

每个 agent 都知道自己**主要操作哪个项目**：

| Agent | 主要 sibling 项目 | 典型动作 |
|---|---|---|
| kevin-media | `media/` | 跑 docker compose pipeline、改 episode 文案 |
| kevin-upwork | `upwork-hunter/` | 读 strategy_notes + 写 cover letter |
| kevin-research | 输出到 `research-notes/`，引用 `quant/` | 多源调研 |
| kevin-domestic | 引用 `indie-dev/docs/` | 起草报价合同 |
| kevin-product | 必扫 `kevin-hub/ideas/` 防重复调研 | PRD / MVP 切片 |
| kevin-fe / be / qa | 当前 cwd 的代码项目 | 写代码 / 测试 |

举个具体的：我说**"@kevin-media 帮我剪 W19 那期视频"**，它自动：

```bash
cd ~/Project/profile/project/media
echo "EPISODE=2026-W19-xxx" > .env
docker compose run --rm pipeline
```

不需要我再说一句"去 media 项目跑 pipeline"。

---

## 7. 实际效果（系统自己反馈的）

📹 **本节是 case study 的"可验证结果"，必讲**

### 7.1 跨域路由测试

我用 plan 模式发了：

> @kevin-frontend 我想给某项目加用户头像上传功能（含后端存储）

它的回复：

> 好，那不用问卷。回到文字。
>
> 我目前能确定的：**这任务应该走 architect 而不是 frontend**（理由：跨 fe+be，符合你 CLAUDE.md 里 architect 的触发条件①）。
>
> 但在 dispatch 任何 agent 之前，我需要你补三件事...

🖼️ **截图建议**：完整对话截图

它**主动引用 CLAUDE.md 第①条触发条件**，决定路由到 architect，并按规范先问澄清问题——**没有按字面意思动手**。

### 7.2 Curator 第一次跑就反馈出系统缺陷

我手动触发 curator 跑了一次。它的报告里有一段：

> ⚠️ **关键阻塞：sandbox 拦截**
>
> `.claude/memory/` 整目录受 sandbox 保护，curator **无法直接写入**。3 处变更已转为待审 patch：...
>
> Curator 建议固化成 patch 输出模式——更安全，也符合原设计意图（不让 agent 自动改记忆）。

**系统第一次跑就发现了自己的设计缺陷**，并给出方案 A/B/C 让我选。这就是 Hermes 那种"agent-curated memory + periodic nudges"的实战效果。

### 7.3 真实代码 review 跑通

我让 architect / frontend / backend 三个 agent 并行 review 了我的 tianda-web 项目（个人品牌门户）。15 分钟出了完整报告：

- 🔴 4 个严重问题（X-Forwarded-For 头部注入、OTP 暴力破解可接管账户、ADMIN_TOKEN 静态后门残留、生产 CORS 默认值缺）
- 🟡 5 个架构债务
- 🟢 6 个代码质量

**最关键的安全漏洞——任意人伪造 X-Forwarded-For 即可绕过 slowapi 限速 + 污染存储 IP——我自己写代码时根本没意识到。**

🖼️ **录屏建议**：演示一次跨 agent review（实操，不要造假数据）

---

## 8. 自我打脸 / 边界

📹 **kevin-voice 必带：评点 + 自我打脸**

这套系统不是银弹。**已知的成本和限制**：

1. **Token 成本高**：12 个 agent 全 opus，一次复杂任务可能跑 5-10 个子 agent。我用 Max 不在乎，但 API key 模式的人慎重
2. **维护成本**：每个 agent 的 prompt + facts/learnings 一开始要写好。我光 USER.md + 7 个 facts.md 写了 1000 行
3. **冷启动空**：新建的 agent facts/learnings 都是空的，要跑一段时间才积累出真正的"个性"
4. **不适合频繁切换 IDE 的人**：所有 agent 路径写死，cwd 不对就找不到 sibling 项目
5. **sandbox 拦写**：curator 现在还不能直接改 .claude/memory/——这个我还没修

**也可能是我以偏概全，大家辩证的看哈。**

### 适合谁

- 单兵作战、长期接活、客户和项目多样的自由职业者
- 想"远程指挥本地执行"的人（手机发指令，电脑做事）
- Max / 类似订阅吃不完的人
- 愿意花 2-3 天搭骨架的人

### 不适合谁

- 在公司团队里写代码的人（团队共享 agent 是另一套问题）
- 只用一两个项目、上下文从来不跨项目的人
- 想"开箱即用"的人——这玩意儿是个 framework 不是 product

---

## 9. 我自己怎么用（每天的工作流变化）

📹 **建议视频化讲解：对比"以前 vs 现在"最直观**

**以前的一天**：

1. 上午开 Slack 看 Venus 客户消息
2. 手动下载图片
3. 贴到 Claude Code，告诉它项目位置 + 上下文
4. 看它写代码
5. 切到自媒体目录，告诉它本周想做什么
6. 中午要决定要不要接一个朋友的私单，切到另一个对话框
7. 下午想调研一下某个新出的 AI 工具，又开一个 session...
8. 每个 session 都重新喂一遍我是谁、偏好啥

**现在的一天**：

1. 上午一句 `@kevin-frontend Venus 的 Color Card 改造` → 它知道 Venus 在哪、客户偏好啥
2. 路上手机一句 `@kevin-media 帮我看看 W20 的选题方向` → 它读 inbox/ideas/w20.md + 给出 3 个候选
3. 一句 `@kevin-domestic 朋友 X 想做 Y，帮我起个报价` → 它读 indie-dev 的产品调研 + 套国内合同模板
4. 一句 `@kevin-research 最近 Hermes Agent 有啥更新` → 它先扫 research-notes/ 看有没有上次记的，再多源调研

**最大的变化**：上下文不再每次重建。

---

## 10. 想看代码

📹 **结尾建议：留 GitHub 钩子**

agent-lab 这套 framework 我会整理后开源。**这周末（2026-05-16）跑通这条视频后，下周开源到 GitHub**。

关键路径速查：

```
agent-lab/
├── .claude/
│   ├── CLAUDE.md              ← 总规则
│   ├── settings.json          ← hooks 配置
│   ├── agents/                ← 12 个 agent prompt
│   ├── hooks/                 ← 3 个 hook 脚本
│   ├── memory/
│   │   ├── USER.md            ← 用户模型
│   │   ├── MEMORY.md          ← 跨 agent 经验池
│   │   ├── SKILLS_INDEX.md
│   │   └── kevin-<agent>/
│   └── skills/                ← 可复用 skill 池
└── docs/
    └── hermes-clone-with-claude-code.md  ← 本文
```

---

## 11. 结尾彩蛋

📹 **kevin-voice 必带：结尾彩蛋拉回普通人姿态**

最后说一句：我搭这个的时候，curator 第一次跑完跟我说"sandbox 拦了我，建议你 A/B/C 三个方案选一个"。

那一刻我突然觉得这玩意儿真的像个员工了——比我还知道分寸，比我还会汇报。

接下来我准备让它接管周末早晨剪视频的活——我录完跑去吃早餐，剪辑让 curator 远程触发，回来直接发抖音。

**T0 级别的解放就在眼前。** 有人想一起搭一套的话评论区扯。

我准备去玩血魔了。

---

## 12. 视频化建议（给 media/script-polish 用）

### 时长分配（参考）

| 段落 | 时长 | 类型 |
|---|---|---|
| 第 1 节（Vibe Coding 卡点）| 90s | 开场钩子 + 痛点共鸣 |
| 第 2 节（Hermes 灵感）| 60s | 引入 + GitHub 截图 |
| 第 3 节（概念映射）| 90s | 架构图，快速过 |
| 第 4 节（12 agent 编制）| 120s | 决策瞬间 1 + 2 |
| 第 5 节（学习闭环）| 120s | 决策瞬间 3 + curator 演示 |
| 第 6 节（执行层映射）| 60s | "@kevin-media 剪 W19" 演示 |
| 第 7 节（实际效果）| 150s | 三个 case 演示 |
| 第 8 节（自我打脸）| 60s | 限制 + 适合谁 |
| 第 9 节（对比工作流）| 90s | 以前 vs 现在 |
| 第 10-11 节（开源 + 彩蛋）| 30s | CTA |

**总计**: ~13 分钟，符合 10-15 分钟默认档。

### 录屏 vs 口播比例

- 录屏：30%（演示对话、curator 报告、目录结构）
- 口播：50%（决策瞬间、自我打脸、彩蛋）
- 架构图/截图静帧：20%

### 关键合规检查

- ✅ Hermes 的 GitHub 截图可以露（技术圈共识工具）
- ✅ agent-lab 自己代码截图随便
- ❌ 不要露 anthropic.com / claude.ai 的截图
- ❌ 不要展示 Slack 的英文界面（要露就国产化模糊处理）
- ⚠️ Venus 客户细节脱敏（只说"韩国 AI 美妆 App"，不露公司名 / 截图）

### kevin-voice 检查清单

按 media/.claude/skills/brand/kevin-voice.md 的 v2 4 条指纹：

- [x] 技术稿按时间线推进（不堆架构层）—— ✅ 第 1 节就是
- [x] 工具名锚点（不字典式介绍）—— ✅ "Hermes 给了我灵感"、"@kevin-media 剪 W19"
- [x] 评点 + 自我打脸尾巴 —— ✅ 第 8 节
- [x] 结尾彩蛋拉回普通人 —— ✅ "去玩血魔" + "T0 级别的解放"
- [x] 高频词命中：唏嘘 / 古法编程 / T0 级别 / 内卷暗喻

### 候选标题（让 Kevin 拍板）

1. **《我用 Claude Code 复刻了 Hermes，3 天搭出 12 个 AI 员工》** — 直白 + 数字
2. **《我把 Claude Code 改造成 AI 员工团队，从此不用每次喂上下文》** — 痛点导向
3. **《为什么我没装 Hermes Agent，而是用 Claude Code 复刻了一个》** — 问题钩子
4. **《一个人服务 4 个项目，我让 AI 帮我记住每件事》** — 故事导向
5. **《Vibe Coding 用了一年，我才发现自己用 AI 太古法了》** — kevin-voice 高频词

---

## 13. 落地后追加（待 Kevin 实际录完后回填）

- [ ] 录屏文件 → episodes/2026-Wxx-<slug>/02-raw/
- [ ] 实际口播稿 → 01-script.md
- [ ] 发布数据 → 05-publish.md
- [ ] 一周后回访收藏率 / 完播率，沉淀到 kevin-media/learnings.md
