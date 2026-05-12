# Kevin 的英文市场偏好（kevin-upwork 视角）

> 覆盖所有英文客户（Upwork 主战场 + LinkedIn / 邮件 / 海外朋友转介）。
> **数据源**：upwork-hunter/data/strategy_notes.md、upwork-hunter/CLAUDE.md、upwork-hunter/resume/profile.md（2026-04 同步）

## 业务定位

- 月收入：¥15k-¥25k（折合约 $2k-3.5k）
- 主战场：Upwork
- 当前客户结构：**1 个长期客户**（Venus 韩国 AI 美妆 App，主要产能），主动选择不持续投标
- 时区：Asia/Shanghai (UTC+8)
- 工时偏好：远程，时差容忍但优先美西/欧洲（早晨连线方便）
- 货币：USD

## 报价策略（硬性规定）

| 类型 | 规则 |
|---|---|
| **时薪** | 固定 **$25/hr**，不议价 |
| **固定价格** | 报客户预算的 **80%** |
| **信任建立** | 主动提供 **1-3 天免费开发** |
| **目标阶梯** | 当前 $25 → 中期 $50 → 长期 $80-120/h |

> 当前阶段策略保守，依赖个人品牌 + GitHub 矩阵积累后再阶梯提价。

## Cover Letter 规则（严格遵守）

- **100-200 词**，**纯文本**（绝对不要 Markdown）
- **首行必须是洞察 / 解决方案**，禁止 "I am writing to apply..." 套话
- **必含元素**：
  - 1-3 天免费开发承诺（信任建立）
  - 提到 AI 工具加速交付（Claude Code / Cursor）
  - profile + GitHub 链接结尾
- **调性**：平等的顾问口吻，不是卑微求职者
- **开头要轮换**（避免模板感）：
  - 痛点式："[Problem statement] — I've built exactly this..."
  - 问句式
  - 数据式 / 数字开头

### 项目引用优先级（按客户需求类型）

| 客户需求类型 | 引用项目 | 必带 |
|---|---|---|
| AI / 移动 / 全栈 / 订阅 | **Venus Skincare** | App Store 链接 |
| IoT / 工具 / 监控 | **Obico**（3D 打印监控）| App Store 链接 |
| Web3 / DeFi | **AstridDAO**（21+ 项目集合）| GitHub |
| 通用全栈 | tianda-web / dadafastrun.com | URL |

## 竞争权重（投不投的快筛）

| 提案数 | 处理 |
|---|---|
| 0-10 | **满权重**（最佳机会，5-10 是甜区）|
| 10-20 | 略降权 |
| 20-50 | 大幅降权 |
| 50+ | **跳过**（除非完美匹配） |

## 必避项目类型

| 类型 | 原因 |
|---|---|
| 提案数 50+ 的岗位 | 命中率太低 |
| budget < $100 | 不值得花时间 |
| unverified clients / 无支付方式 | 高风险骗稿 |
| client rating < 4.0 | 难合作 |
| C++ / 原生 Swift / 原生 Kotlin | 不擅长 |
| 游戏开发 | 不擅长 |
| WordPress / PHP | 不接 |
| GIS 专业要求 | 不擅长 |

## 推荐搜索关键词（按 ROI 排序）

1. **react native** — 核心强项，比 "react" 竞争小
2. **python fastapi** — 后端差异化
3. **full stack developer** — 广匹配
4. **vue.js** — 强技能、中等竞争
5. **next.js react** — 现代栈，预算好

## 文化基线（海外客户）

- **直接 + 简洁**，不寒暄
- 问澄清问题被视为**专业**，不是不懂
- 报价时给区间 + 计算逻辑 > 单一数字（可信度高）
- **承诺技术细节谨慎**（"3 天内做完"留给 Kevin 自己评估）
- 不要 "hope this finds you well" / "I look forward to hearing from you" 之类客套

## Upwork 平台特异性

- 提案有字数 / 连接点限制——优先质量不堆字
- 客户分级（Star / Plus / Top Rated）影响接单策略
- 平台保护：争议走平台仲裁优于走法律

## Kevin 的差异化武器（写提案时强调）

1. **真实在线产品集**：Venus（App Store）+ Obico（App Store）+ 21 个 DeFi 项目
2. **AI 工具加速交付**（Claude Code + Cursor 工作流，比纯人写快 2-3x）
3. **全栈覆盖**（Web + Mobile + Web3 + AI + DevOps）
4. **个人站 + GitHub** 可验证：dadafastrun.com / github.com/kui-wang-dada
5. **跨域整合能力**（兽医背景 → 程序员，可做垂直行业的医疗 / 宠物相关产品）

## 数据文件位置（投递追踪）

- `~/Project/profile/project/upwork-hunter/data/seen_jobs.json` — 去重
- `~/Project/profile/project/upwork-hunter/data/submissions.json` — 投递记录
- `~/Project/profile/project/upwork-hunter/data/strategy_notes.md` — 策略笔记（每次周报后更新）
- `~/Project/profile/project/upwork-hunter/reports/` — 周报历史

## 当前 Venus 客户工作流（参考，2026-W19）

- 沟通入口：Slack
- 流程：Slack 需求提炼 → 计划 → 实施 → 真机测试 → 反复改
- 痛点：Slack MCP 抓不到图片，每次手动下载贴给 Claude（高频痛点）
- 已落地任务：Color Card / Color Consult、Onboarding 流程 + Amplitude 埋点、Paywall hard-paywall 改造、RevenueCat 老用户逻辑

---

<!-- agent 追加新观察 -->
