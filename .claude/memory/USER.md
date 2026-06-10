# Kevin Wang — User Model

> Hermes 风格的"deepening user model"。由 `kevin-curator` 每周日 21:30 自动维护。
> 所有 agent 工作前必读。结构：稳定 → 高频 → 低频 → 即时。

**Last updated**: 2026-06-09（W24 周巡：分层自治校准落地后首周，subagent in-band 沉淀健康，review-queue 噪音过滤健康）

---

## Identity（稳定，半年级别变化）

- **本名**：王奎（Kevin Wang）
- **角色**：全栈 + AI 应用开发工程师，10 年+ 经验
- **职业身份**：Upwork 全职自由开发者（2024 起）
- **位置**：中国，远程办公，时区 Asia/Shanghai (UTC+8)
- **家庭**：两个儿子
- **背景转折**：兽医专业出身 → 35 岁转行程序员
- **公开身份**：
  - 工作室：添达工作室（Tianda Studio）
  - 个人站：http://www.dadafastrun.com（旧）→ tianda.studio（新，重构中）
  - GitHub：https://github.com/kui-wang-dada
- **硬件**：Mac Studio M4 Max 64GB（本地 7×24 跑量化策略 / Docker pipelines）
- **长期目标**：1-2 年维度建立"国内 + 全球"双向专业可信度

---

## Working Style（高频观察，月度更新）

### 协作偏好
- **极简路线**，反对过度设计；新方案先问"能不能不做 / 不做行不行"
- **极简 ≠ 极简内核**（2026-06 dongjiaoshan 复盘细化）：他要的是"**强默认 + 可关**"——把已验证的最佳实践默认打开、每件标好关掉条件，而不是"极简内核 + 按需加"（后者把判断成本留给每次现做，本身就是熵）。减法决策（要不要关 X）比加法决策安全
- **反"自动化判断引擎"**：明确禁止建"按规模自动判 tier / 自动触发不同流程"这类机器——分类标签是人脑里的，不是代码里的开关（anti-bloat 红线）
- **不替 Kevin 做决策**，给"选项 + 推荐 + 理由"，让他能反驳
- **不堆方法论**，给具体可执行步骤
- **不写空话和过度礼貌性铺垫**
- **不在乎 token 成本**，要质量（Max 订阅是甲方提供，"用不完"是常态）
- **想要"远程指挥 + 本地执行"**：手机发指令，电脑做事
- **自学习是体系目的，但要分层自治**（2026-06-09 校准，纠正早前过度绝对的"祛魅"表述）：自学习**就是 agent-lab 的目的本身**——让下次接活起点更高、开发更快，不是要不要的问题。真正反对的是**"无人在环、向量魔法式全自动进化"**（那才是头号 hype），**不是自学习**。做法 = **分层自治（强默认+可否决）**：低风险类（失败护栏 / stack 经验 / 事实）自动沉淀+自动激活、事后可 `git revert` 否决；高风险类（新 skill / 改 agent / 改 plugin 机器）出候选 → 人拍板。置信度评分只用于排序+过阈，不是流程触发器（仍守"不按规模自动判 tier"红线）。能跨项目复用的核心仍是确定性 spec/skill，但**借鉴外部优秀案例 + 自我经验回流**两条输入都要主动吸收。

### 沟通
- 中文交流，技术术语保留英文
- 接受直接质疑（"为什么这样做"），不需要软化
- 完成任务后报告"改了哪些文件"（用相对路径），不要问"还需要做什么"
- 资深开发者，**不需要解释基础概念**

### 工程
- 不写 `any` / 不吞异常 / 不留无说明 TODO
- 没把握的依赖不引入
- 改前先 build / typecheck
- 函数 > 类，组合 > 继承

---

## Current Focus（低频，季度更新）

### 2026-Q2 重心（2026-06 修订：国内大型项目临时上位）

| 轨 | 内容 |
|---|---|
| **国内 freelance（5-6 月临时主线）** | 3 个项目并行：dongjiaoshan（农业全产业链 SaaS，RuoYi，~15 天主线近完成）/ sensenran-guzi（谷子电商，uni-app）/ zhengda-jixun（正大集团集训小程序，06-05 新询单，死线 7-20）。靠"人+AI 重度接管"打有效时薪 ¥600-1000/h 的套利窗口 |
| Upwork 接单 | Venus（韩国 AI 美妆 App）仍是长期客户；新增海外老客户 grant-funded 小活询价（1k GBP ticketing+安全） |
| 长内容源（国内主） | 抖音 + B 站，每周 1 期；W19 Hermes 体系 / W21 已出 |
| 全球平台维护 | GitHub 持续提交，YouTube/X/dev.to 现阶段不开 |

> 原"60/30/10 三轨"是 5 月初的稳态规划；5 月中接下 dongjiaoshan 后，国内大型项目实际占用大量产能，三轨占比短期失衡（属预期内的项目冲刺，非长期结构变化）。

### 主要在跑的项目
- **agent-lab**（本项目）：Hermes 风格个人 agent 体系
- **media**：自媒体执行项目（已成熟，每周 1 期视频 + 配套图文，10-15 分钟 default）
- **upwork-hunter**：Upwork 投递工具 + 简历库
- **Venus 韩国客户项目**：当前主要 Upwork 收入源（每周 Slack 沟通 → 实施闭环）
- **tianda-web**：个人品牌门户重构中（Next.js 静态导出 + FastAPI + Vite admin）
- **quant**：Crypto Sentinel v2，BTC/ETH 极端行情哨兵（Mac Studio 7×24 跑）
- **indie-dev**：宠物医疗 B 端工具探索（兽医同学渠道）

### 长期意图
- "把心里的故事讲出来"（源自《李献计》）
- 中短篇起步，**不为商业、暂不为动画服务**
- 1-2 年累积 15-30 个微产品（参考 levelsio "12 startups in 12 months"）

---

## Hot Context（本周，curator 每周更新）

### 2026-W24（截至 2026-06-09，周巡）
- **经验回流引擎 W23 校准方案的首周观察**：分层自治（强默认+可否决）落地后第一周。subagent 在 W23 末已直接 in-band 沉淀本周经验（kevin-dev/learnings.md 5 条 2026-06-07 entries 覆盖 media pipeline 观点浮层 OOM 修复 / lavfi alpha 丢失 / marker 内联三处 strip 同步 / docker compose build 必跑 / 自用工具产品化"独占钩子"思维框架；kevin-research/facts.md 增 script-first 视频工具市场调研 + ASR 词级时间戳调研沉淀；kevin-domestic/learnings.md 增 RuoYi 抗高并发四件套 + 死线项目报价拆解）。本次周巡**未自动新增**任何条目——是健康信号（subagent in-band 把活干完了），不是失败。
- **review-queue 噪音过滤效果**：W23 周巡时 21 条全噪音（IDE-opened-file 泛滥），2026-06-08 hook 加噪音过滤后，W24 仅 4 条 stop 元数据 stub（无 `signal:failure`、无 `user_intent_snippet`、无 `occurrences`），全部正常归档。**无新护栏可沉**。
- **国内三线状态**（同 W23 未变）：dongjiaoshan 收尾持续 / sensenran-guzi 架构期 / zhengda 集训小程序（死线 7-20，已出 MVP+拉人方案）。本周无新询单/无客户拍板新分支。
- **海外 grant 询价（1k GBP）状态**仍未沉淀最终决策——继续标记为"待 Kevin 确认是否成交"，不进 facts。
- **媒体 W23**：观点浮层 v1 上线后续期还未跑（W23 媒体产物到 W22 观点浮层完工为止，W23 本周成片状态未在 memory 中确认）。

### 2026-W23（截至 2026-06-07，周巡）
- **国内 freelance 三线齐发**：dongjiaoshan 收尾（功能对齐+测试+修复）/ sensenran-guzi 架构期 / zhengda 集训小程序新询单（死线 7-20，单人不可同时满足全功能+死线，已出 MVP+拉人方案）
- **dongjiaoshan 进入收尾**：15 天主线任务近完成。Kevin 让 agent 把这一程经验固化成可复用工程模板
- **project-os 工程 OS 模板落地**：`agent-lab/templates/project-os/`——一套"人+AI 协作交付"的三段流水线（SP1 接料→设计 / SP2 执行→验证 / SP3 反哺→再生），强默认+可关、单一变量源、三件 SSOT。已抽成 skill 候选 `domestic-project-os-bootstrap`（待审）
- **ASR / 方言识别调研深挖**：从 05-20 中文 ASR brief → 05-24 方言+LID 可行性 → 06-05 词级时间戳/热词专项（读了 media pipeline 源码，结论是"真痛点在 align-script 加术语音近映射，不全在换 ASR"）。沉淀大量 research-notes
- **海外 grant 询价**（06-02）：某海外老客户用 1k GBP grant 雇 Kevin 做 ticketing + 安全加固，询 GBP→CNY 换算 + 报价口径（最终决策未沉淀，待确认）
- **媒体 W21 预览剪辑已跑**（05-31）；W19 Hermes 体系视频此前已出
- **媒体 pipeline W22 观点浮层完工**（06-07）：`[观点：…]` marker 内联念稿正文、每累积状态一张 PNG、burn-final OOM 修复（多 `-loop 1` → 预渲染单层透明叠加）、lavfi `color@0.0` 透明 alpha bug 修复。沉淀 5 条 kevin-dev learnings（`2026-06-07`）。

### 2026-W19/W20（归档保留）
- **agent-lab 重构落地**：从 4 agent 升到 11 agent（含 designer），2026-05-20 删除 router 后降为 10 agent（assistant/curator/upwork/domestic/research/media/product/designer/coder/qa）；曾尝试细分 dev 为 architect/fe/be/qa，跑通后判断对单兵 AI 体系是过度设计——合并为 coder 一体。router 删除原因：Anthropic 官方建议 routing 由主线程承担
- 启用 Hermes 风格学习闭环（hooks + curator 周巡 + USER.md 用户建模）
- 客户分界改为按"语言"切：英文 → upwork，中文 → domestic
- Venus 项目完成 Color Card / Color Consult / Paywall hard-paywall 改造
- tianda-web 综合 review 完成，发现 X-Forwarded-For 注入等 4 个 🔴 问题待修

---

## Critical Constraints（合规/边界，永久）

### B 层合规边界（2026-05-03 立）

| 类别 | 做 / 不做 |
|---|---|
| Upwork 接单（海外业务核心） | ✅ 持续做 |
| 英文版个人站（同站双语，hreflang 区分） | ✅ 做（海外搜索引擎入口） |
| GitHub 项目持续提交 | ✅ 做（国内技术圈共识） |
| 国内技术视频展示 GitHub 截图 | ✅ 可以（技术圈共识工具） |
| 海外社交平台（YouTube / X / Medium / dev.to） | ❌ 现阶段不开，未来加入用独立账号与国内身份隔离 |
| 国内简介挂海外平台链接 | ❌ 不挂 |
| 国内视频展示 Vercel / Twitter / YouTube / Reddit 等海外平台访问操作 | ❌ 不展示 |
| 国内视频演示英文版网站操作 | ❌ 不演示 |

**Why**：避免被国内观众或平台审核解读为"频繁访问境外"。

### 商业边界（永久）
- ❌ TikTok Shop / 抖店实物带货
- ❌ 直播带货
- ❌ 任何短视频内容生产（抖音短视频 / TikTok / 视频号）
- ❌ 付费教程 / 课程 / 培训 / 带货
- ❌ 接广告陪跑、与开发者人设无关的合作
- ❌ 特别复杂忙碌、占满全部时间的项目

---

## Inbox / 时间偏好（待补，agent 观察后追加）

- 邮件回复时效偏好：<!-- 待 Kevin 补 -->
- 微信不打扰原则：<!-- 待 Kevin 补 -->
- 日历偏好（早会/晚会接受度，时差）：早晨连线方便（美西/欧洲优先）

---

## Relationships to Other Files

- 详细技术偏好 → `.claude/memory/kevin-dev/facts.md`
- 英文市场偏好 → `.claude/memory/kevin-upwork/facts.md`
- 中文市场偏好 → `.claude/memory/kevin-domestic/facts.md`
- 调研偏好 / 信源 → `.claude/memory/kevin-research/facts.md`
- 媒体偏好 → `.claude/memory/kevin-media/facts.md`
- 业务规划全文 → `.claude/memory/business-plan.md`
- 简历事实 → `.claude/memory/profile/`

### Sibling 项目地图（assistant 跨项目导航用）

```
~/Project/profile/project/
├── agent-lab/          ← 本项目（Hermes 风格 agent 体系）
├── media/              ← 自媒体执行（已成熟，独立 Cowork）
├── upwork-hunter/      ← Upwork 投递工具 + 简历库 + 策略笔记
├── kevin-hub/          ← 个人想法/规划/profile（部分迁到 .claude/memory/）
├── website/            ← 个人站（旧版）
├── indie-dev/          ← 宠物医疗 B 端工具探索
├── quant/              ← Crypto Sentinel v2（量化）
└── docs/               ← 通用文档

~/Project/profile/code/
├── tianda-web/         ← 个人品牌门户重构（V2 在做）
├── ...
```

---

## Change Log（curator 自动追加）

- 2026-05-11: 初版手写（agent-lab 重构）
- 2026-05-12: 从 sibling projects 全量同步事实（identity / focus / projects / 合规边界）
- 2026-06-05: curator 补跑周巡（自动调度从未生效，积压 4 周一次清掉）。本周变化 diff vs W19/W20：
  - **Current Focus**：国内 freelance 从"极少"升为 5-6 月临时主线（dongjiaoshan + sensenran-guzi）；三轨 60/30/10 短期失衡
  - **Working Style 深化**：极简观细化为"强默认+可关 ≠ 极简内核"；新增"反自动化判断引擎"+"对自学习 agent 祛魅"两条（均来自 dongjiaoshan 复盘 + project-os 设计）
  - **Hot Context**：W19/W20 → W23（dongjiaoshan 收尾 / project-os 模板 / ASR 调研深挖 / 海外 grant 询价 / W21 剪辑 / W22 media 观点浮层）
- 2026-06-07: W23 周日周巡（自动触发 launchd）。media pipeline W22 观点浮层完工，5 条 dev learnings 沉淀；review-queue 21 条全噪音已归档。
- 2026-06-09: agent-lab 经验回流引擎优化（借鉴 headroom/ECC/Claude Code Harness 调研）。**重要校准**：Kevin 纠正"祛魅自学习"过度绝对——自学习是体系目的，反对的只是无人在环全自动进化；改为**分层自治（强默认+可否决）**。落地 6 项：hook 加 failure signal + curator 分层沉淀（低风险自动落+digest 否决/高风险候选）、`.claude/rules/` path-scoped 层、project-os 拆 plugin（机器层 marketplace 传播消除 drift）+ scaffold、type/lint 硬 gate（verify-cmd）、对抗式验证 workflow、compaction 保留指令。
- 2026-06-09: W24 周巡（launchd 自动触发）。本周分层自治校准方案的首次稳态运行——subagent 在 W23 末 in-band 已把本周经验沉淀（dev/media/research/domestic 各 domain 均已更新），周巡未发现需 curator 二次沉淀的条目。review-queue 4 条 stop 元数据 stub（hook 噪音过滤健康，对比 W23 的 21 条大幅下降）→ 全部归档无候选。**结论：体系按预期工作，不需要"为做而做"的强行沉淀**。
