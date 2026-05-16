# Kevin 的调研偏好（kevin-research 视角）

> **数据源**：quant/CLAUDE.md、quant/README.md、business-plan.md、kevin-hub/ideas/、media weekly logs（2026-04~05）

## 关注主题（长期追踪）

### A. AI Agent / 大模型应用工程（**当前最热**）
- **Anthropic Claude / Code / Skills / Hooks / MCP / Agent SDK** 进展（Kevin 用 Claude Code 是主要工具链）
- 多 agent 协作框架（**Hermes / OpenClaw / wshobson/agents / MetaGPT / ComposioHQ**）—— Kevin 在搭自己的 12 agent 体系，参考过这几个
- Cursor / Claude Code 工作流对比
- MCP server 生态（特别是 Slack MCP 抓图问题、Figma MCP 调用限制是已知痛点）
- Anthropic Max 订阅功能演进（Kevin 用的是甲方提供的 Max）

### B. 加密货币 / Web3（**长期追踪 + 量化在做**）
- **BTC / ETH** 价格 + 链上指标（恐贪指数、资金费率、ATH 回撤、市占率）
- 极端行情信号（Kevin 的 Crypto Sentinel v2 监控 6 项买入 + 6 项卖出指标）
- DeFi 生态（Kevin 在 AstridDAO 做了 21+ 项目，对 CDP / AMM / Lending / Liquid Staking / NFT 熟）
- 多链动态：Ethereum / Astar / Solana / CKB
- 交易所 API 政策（Binance / OKX）

### C. Upwork / 自由职业市场
- Upwork 政策、客户结构变化
- Cover letter 模式 / 算法
- 海外 remote 公司招聘趋势
- AI 工具加速交付对单价的影响

### D. 自媒体 / 内容平台规则
- 抖音算法（特别是 2026-03 后的"长视频流量池"逻辑）
- B 站、公众号、视频号规则变化
- 国内备案站 SEO 实践
- levelsio / Pieter Levels 的 indie hacker 工艺

### E. Indie Hacker / 微产品
- 国内外独立开发者动态
- 微产品矩阵案例（参考 levelsio "12 startups in 12 months"）
- 宠物医疗 / 兽医 B 端 SaaS（Kevin 兽医背景 + indie-dev 项目方向）

---

## 可信信源（按主题分类）

### AI / 大模型
- ✅ Anthropic 官方 blog / docs
- ✅ OpenAI / Google AI 官方
- ✅ The Information（付费，深度）
- ✅ arxiv（一手论文）
- ✅ Hacker News 评论区（社区口碑）
- ✅ swyx 系列 newsletter（趋势）
- ⚠️ medium 上的 "X 项目 changed everything" 类长文（多数标题党）
- ⚠️ 国内"AI 教父" 类公众号（情绪 > 信息）

### 加密 / Web3
- ✅ 项目官方 docs / blog / Twitter
- ✅ CoinDesk / The Block / Decrypt
- ✅ Etherscan / 链上数据
- ✅ alternative.me（恐贪指数 API）
- ✅ CoinGecko API（市占率）
- ✅ ccxt（交易所统一 API，Kevin 量化用）
- ⚠️ 国内"币圈大 V" 微博 / 公众号（情绪偏激）

### 国内科技
- ✅ 36kr / 虎嗅 / 钛媒体 / 极客公园
- ✅ 公司官方公众号
- ⚠️ 自媒体二手汇编（信息延迟 + 失真）

### Upwork / 自由职业
- ✅ Upwork 官方 blog（政策变化）
- ✅ r/Upwork subreddit（一手吐槽）
- ⚠️ 国内"接单赚美金" 类教程（多数已过时）

### 自媒体 / 内容平台
- ✅ 平台官方公告（抖音 / B 站 / 公众号 创作者中心）
- ✅ levelsio.com（indie hacker 一手）
- ✅ 国内创作者社区（如即刻、少数派）
- ⚠️ 标题党"X 平台算法揭秘" 类内容

---

## 信息质量模式

### 高质量信号
- 原文链接 + 时间戳 + 第一方引用
- 链上 / 数据库可验证
- 作者有 track record（不是匿名转述）
- 多源印证

### 低质量信号
- 标题含 "震惊 / 改变一切 / 必看 / 颠覆"
- 无来源链接
- 纯情绪化语言
- 单一来源 + 推断为主

### 过时信号
- 依赖 6+ 月前数据做"现状"分析
- 引用已死链接
- 提到的产品已下线 / 公司已倒闭

---

## 输出深度偏好

- **默认**：速览（约 500 字 + 关键事实表 + 来源全列表）
- **深度调研** 触发条件：用户明说 "完整报告" / "深度" / "1 页"
- **超级速报**：用户说"快速给我一个状态" → 3 句话内 + 1 个最高可信度来源

---

## 长期跟踪标的（agent 每次调研后追加）

<!-- 由 agent 自动维护，例如：

## BTC（Bitcoin）
- 上次调研：YYYY-MM-DD
- 关键状态：恐贪指数 = X，价格 = $Y
- 量化系统状态：last signal = ..., 最后一次买入 = ...
- 下次重点关注：...

## Anthropic Claude Code
- 上次调研：YYYY-MM-DD
- 已知最新版本：X
- 即将发布：...
- Kevin 用的功能演进：hooks → skills → agents → ...

-->

---

## Kevin 的"调研→输出"路径

调研结果通常会变成下列产物之一：
- **业务报价依据**（@kevin-upwork / @kevin-domestic 调用）
- **产品方向决策**（@kevin-product 调用）
- **自媒体选题素材**（@kevin-media 调用，写到 `media/inbox/ideas/wXX.md`）
- **量化策略调整**（手动改 `~/Project/profile/project/quant/strategies/*`）
- **个人决策**（要不要 buy/sell，要不要切技术栈，要不要做某个产品）

调研报告**默认落到** `.claude/memory/research-notes/<topic>-<YYYY-MM-DD>.md`，方便后续 diff + 引用。

---

<!-- agent 追加新观察 -->

## 2026-05-17 — Taro vs uni-app 调研沉淀

**插件市场量级**：DCloud 插件市场 19,473 个（ext.dcloud.net.cn 首页计数）vs Taro 物料市场仅几百量级。"uni-app 生态远胜 Taro"在插件数量维度属实。

**但 Taro 没被淘汰**：京东 APP 鸿蒙原生版（首页/搜索/详情/购物车）全部 Taro on Harmony 实现，2025-09 上线，华为 S 级认证。Taro 最新 v4.2.0 (2026-04-13) 仍活跃。

**issue 关闭率**：Taro 88% > uni-app 53%（近 6 月新建 issue 解决率）。Taro 工程质量更可控但社区规模小（Taro 200 人群 vs uni-app 2000 人群）。

**调研可信信源新增**：
- ✅ v2ex 技术选型讨论帖 — 一线开发者真实选型理由，无利益相关
- ✅ DCloud / Taro 官方插件市场 — 一手计数
- ✅ GitHub REST API (`/repos/X/Y`, `/search/issues`) — 仓库活跃度硬数据
- ⚠️ 知乎技术问题页 — 403 频繁，靠 WebSearch 摘要而非 WebFetch

**适用场景**：未来调研其他前端/移动框架选型（React Native vs Flutter、Vite vs Webpack 等）可复用同样的"GitHub API + 插件市场计数 + v2ex/知乎 + 大厂案例"四源交叉法。
