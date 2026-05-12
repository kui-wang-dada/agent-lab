# Kevin 的核心事实（kevin-assistant 视角）

> 本文件记录 agent 应该长期记住的关于 Kevin 的事实。
> Kevin 可以手动编辑添加；agent 在工作中观察到新事实时也会自动追加。

## 身份与背景

- **角色**：全栈 + AI 应用开发工程师，10 年+ 经验
- **当前业务**：Upwork 自由职业（2024 起），承接海外客户
- **位置**：中国（远程办公）
- **家庭**：有两个儿子

## 工作偏好

- 重视远程办公和时间自由度
- 偏好简洁方案，**默认极简路线**，反对过度设计
- 不在乎 token 成本，要质量
- 想要"远程指挥 + 本地执行"的工作模式（手机发指令、电脑做事）

## 业务现状（2026-05）

- Upwork 月均 $15k-$25k
- 目标：稳定收入 + 自媒体扩影响力
- 合规边界：**国内自媒体不展示海外网站**；海外业务（Upwork/GitHub/英文站）继续做

## 长期意图

- 想"把心里的故事讲出来"，源自《李献计》
- 创作路径：中短篇起步，不为商业、暂不为动画服务

## 项目仓库地图（跨项目导航用）

> **核心原则**：agent-lab 是 CEO/思考层，每个垂直项目是执行层。
> 跨项目任务 → assistant 拆分调度，不要替对应项目的 Claude Code 直接动它的代码。

### `~/Project/profile/project/`（个人项目区）

| 项目 | 用途 | 关键文件 |
|---|---|---|
| **agent-lab** | 本 agent 体系（CEO 层） | `.claude/CLAUDE.md` `.claude/agents/*` `.claude/memory/*` `.claude/hooks/*` |
| **media** | 自媒体执行（独立 Cowork） | `CLAUDE.md`（17KB） `inbox/ideas/wXX.md` `episodes/2026-WXX-*` `weekly-log/` |
| **upwork-hunter** | Upwork 投递工具 + 简历 + 策略 | `CLAUDE.md` `resume/profile.md` `data/strategy_notes.md` `data/seen_jobs.json` `data/submissions.json` |
| **kevin-hub** | 个人想法/规划/profile（已迁移核心，保留作历史归档） | `plans/business-plan.md` `ideas/*` `logs/weekly-*` |
| **website** | 个人站旧版（被 tianda-web 取代） | `frontend/` `backend/` |
| **indie-dev** | 宠物医疗 B 端探索 | `CLAUDE.md` `docs/product-research-2026-04.md` |
| **quant** | Crypto Sentinel v2（量化）| `CLAUDE.md` `README.md` `strategies/*` `config.yaml` `.env` |
| **docs** | 通用文档 | - |

### `~/Project/profile/code/`（公开开发项目区）

| 项目 | 用途 | 状态 |
|---|---|---|
| **tianda-web** | 个人品牌门户 V2 | Next.js 15 静态导出 + FastAPI + Vite admin，进行中 |
| 其他 | ... | （按需扫描） |

### `~/Project/work/`（客户项目区）

| 项目 | 客户 |
|---|---|
| **astriddao** | 21+ DeFi 子项目（历史） |
| **upwork-2025-4-6-rn-ai-* (Venus 系列)** | 韩国 AI 美妆 App（**当前主要客户**） |
| 其他 | （按需扫描） |

### Sibling 调用导航
- 涉及 media 选题 → 让 @kevin-media 读 `~/Project/profile/project/media/inbox/ideas/`
- 涉及 Upwork 简历 → 让 @kevin-upwork 读 `~/Project/profile/project/upwork-hunter/resume/`
- 涉及量化 → @kevin-research 读 `~/Project/profile/project/quant/strategies/`
- 涉及业务规划 → 直接引用 `.claude/memory/business-plan.md`（已迁移）

## Inbox 偏好（待 Kevin 补充）

<!-- agent 在工作中观察追加：
- 邮件回复时效偏好（24h 内 / 当天 / 下周）
- 微信不打扰原则
- 优先回复哪类客户
- 哪些消息可以批量回复 / 哪些必须个性化
-->


## 沟通风格偏好

- 中文交流，技术术语保留英文
- 不要堆方法论，给具体可执行步骤
- 给推荐时附理由，让 Kevin 能反驳
- 不写空话和过度礼貌性铺垫

---

<!-- agent 在此追加新观察到的事实，格式：
## YYYY-MM-DD — <主题>
<内容>
**适用场景**：<何时引用>
-->
