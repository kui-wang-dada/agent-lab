# Kevin Wang — User Model

> Hermes 风格的"deepening user model"。由 `kevin-curator` 每周日 21:30 自动维护。
> 所有 agent 工作前必读。结构：稳定 → 高频 → 低频 → 即时。

**Last updated**: 2026-05-12（手动从 sibling projects 同步全量事实）

---

## Identity（稳定，半年级别变化）

- **本名**：王奎（Kevin Wang）
- **角色**：全栈 + AI 应用开发工程师，10 年+ 经验
- **职业身份**：Upwork 全职自由开发者（2024 起）
- **位置**：中国，远程办公，时区 Asia/Shanghai (UTC+8)
- **家庭**：两个儿子
- **背景转折**：兽医专业出身 → 35 岁转行程序员
- **公开身份**：
  - 工作室：天大工作室（Tianda Studio）
  - 个人站：http://www.dadafastrun.com（旧）→ tianda.studio（新，重构中）
  - GitHub：https://github.com/kui-wang-dada
- **硬件**：Mac Studio M4 Max 64GB（本地 7×24 跑量化策略 / Docker pipelines）
- **长期目标**：1-2 年维度建立"国内 + 全球"双向专业可信度

---

## Working Style（高频观察，月度更新）

### 协作偏好
- **极简路线**，反对过度设计；新方案先问"能不能不做 / 不做行不行"
- **不替 Kevin 做决策**，给"选项 + 推荐 + 理由"，让他能反驳
- **不堆方法论**，给具体可执行步骤
- **不写空话和过度礼貌性铺垫**
- **不在乎 token 成本**，要质量（Max 订阅是甲方提供，"用不完"是常态）
- **想要"远程指挥 + 本地执行"**：手机发指令，电脑做事

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

### 2026-Q2 三轨并行

| 轨 | 占比 | 内容 |
|---|---|---|
| Upwork 接单 | 60% / 18-21h/周 | Venus（韩国 AI 美妆 App）是当前长期客户 |
| 长内容源（国内主） | 30% / 9-10h/周 | 抖音 + B 站，每 2 周 1 视频 |
| 全球平台维护 | 10% / 3-4h/周 | GitHub 持续提交，YouTube/X/dev.to 现阶段不开 |

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

### 2026-W19/W20
- **agent-lab 重构落地**：从 4 agent 升到 12 agent（router/assistant/curator/upwork/domestic/research/media/product/architect/frontend/backend/qa）
- 启用 Hermes 风格学习闭环（hooks + curator 周巡 + USER.md 用户建模）
- 客户分界改为按"语言"切：英文 → upwork，中文 → domestic
- Venus 项目本周完成 Color Card / Color Consult / Paywall hard-paywall 改造
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
