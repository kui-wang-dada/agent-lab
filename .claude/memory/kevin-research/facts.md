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

## 2026-05-18 — 阿里云首屏特价不可全信，规格需到购买页确认
查证东角山项目采购清单时发现：Kevin 截图标的 u2a 2C4G ¥1438.68/年 和 c9i 4C8G ¥3459.90/年 在多个 developer.aliyun 文档里找不到对应价格档位——实际 u2a 2C4G 1-5M 档是 504.6-810.6/年，c9i 4C8G 1-5M 档是 3136.81-4177.21/年。首屏的促销价可能对应特定 SKU 组合（如 3M + 40G + 包年）但**购买页才是唯一可信源**。其他价格确认：RDS HA 2C4G 50G ¥3888/年 可信，OSS 500G 资源包 ¥118.99/年 可信，OSS 公网下行流量 100G/年 ¥441，SMS 0.045 元/条。Redis 1G 双副本控制台询价（首屏不展示）。

**适用场景**：未来给客户做阿里云 / 腾讯云 / 华为云采购清单时，**禁止**只用截图首屏数字 + 二手 developer 文章估算。必须打开"立即购买"控制台拿真实 SKU 配置，或在文档里明确标"以控制台报价为准"。

## 2026-05-21 — 中文 ASR 调研沉淀（Kevin media pipeline 强相关）

**关键结论**：2025 年中文 ASR 国产开源全面反超 Whisper。中英混合场景按"集成成本/精度"排序：
1. Whisper-large-v3-turbo + initial_prompt 灌技术术语（零改造，立刻可做）
2. SenseVoice-Small + 外挂 FSMN-VAD 出 srt（中英混合 MER 6.71%，CS-Dialogue 数据集 SOTA 之一）
3. FireRedASR2-LLM 8B+（真实场景 CER 4.32%，M4 Max 64GB 可跑）

**Belle-whisper-large-v3-zh 的陷阱**：纯中文 fine-tune，AISHELL 数据好看（-24~65% CER），但**会把英文术语强转成同音中文**（React → 瑞克特），对 Kevin 这种技术内容反而更差——选模型时不能只看单语 benchmark。

**SenseVoice 时间戳是已知短板**：官方不原生输出 srt，需外挂 VAD 预切+对齐；社区方案见 pyVideoTrans。

**新增可信信源**（ASR / 语音技术调研）：
- ✅ Ruoqi Jin ASR 综述（ruoqijin.com/blog/asr-deep-dive-2025-2026）— 综合性数据 + 价格 + 显存
- ✅ Whisper Notes blog（whispernotes.app）— Mac 实测 benchmark
- ✅ FireRedTeam HF 仓库 — 工业级开源中文 ASR 一手
- ✅ FunAudioLLM/SenseVoice GitHub + arxiv 2407.04051 — 阿里 SenseVoice 一手
- ✅ Brass Transcripts（API 真实定价分析，比官方页面更准）
- ⚠️ Medium 上的"I Tested X on Mac M4"类博客（数据点零散，慎用）

**适用场景**：未来给 media/freelance 选 ASR / TTS / 语音模型时，第一手参考此 brief，再补本期数据。同主题增量调研可直接 diff `chinese-asr-2026-05-20.md`。

## 2026-05-24 — 中国方言 ASR + LID 调研沉淀（产品可行性地基）

**核心数字**：
- 主流云商用 API 实际可稳定识别方言约 **20-30 种**（阿里 18-22 / 腾讯 23 / 电信 TeleSpeech 40 / 百度 9）
- 讯飞宣称"202 方言"是营销话术（含"地方音变"），**不要在客户文档引用**
- 少数民族语言（藏维蒙）**无独立商用 API**——只有 Qwen3-ASR 在 52 语种里疑似覆盖，需独立验证
- 长尾方言（温州话、闽东话、潮汕、客家细分）只有 TeleSpeech 和 Qwen3-ASR 覆盖

**LID 自动判断技术路线**：2024 后主流厂商全部转向"端到端统一模型直接出转写"（路线 B），不再用"先 LID 再 ASR"。准确率：跨语种 F1 0.93+，普通话+5 方言 0.85-0.92，扩到 20+ 方言降到 0.7-0.8。

**最佳性价比商用 API**：阿里云百炼 Qwen3-ASR-Flash ¥0.00033/秒 = **¥1.19/小时**（境内），同时给"方言 ASR + 自动 LID + 接 LLM"三件事。讯飞 ¥2-5/小时贵 2-4× 但方言长尾覆盖最广。

**适用场景**：未来甲方需求含"方言识别 / 多方言 / 全国方言 / 自动判断口音"任一关键词时，直接引用此 brief；产品助手做可行性评估时第一手参考。同主题增量调研可 diff `dialect-asr-2026-05-24.md`。

**信源补充**：
- ✅ 中国电信 TeleSpeech-ASR GitHub —— 国产长尾方言唯一开源标杆
- ✅ 阿里百炼 Qwen3-ASR 官方文档 —— 当前 SOTA 商用方言 API
- ✅ 讯飞 dia_model 页面 —— 国内方言覆盖最全（但数字虚高需谨慎）
- ⚠️ 厂商"支持 N 种方言"宣传数字需打折——实际可商用稳定的约为宣称值的 50-70%
