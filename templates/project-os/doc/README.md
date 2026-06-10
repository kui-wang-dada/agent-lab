# &lt;&lt;PROJECT_NAME&gt;&gt; — 文档地图 & 路由

> 项目代号 / 栈 / 团队模型 / 业务域等**实例值**全在 [`../PROJECT.md`](../PROJECT.md)（单一变量源）。
> 本文件只管"**有哪些文档 + 谁在什么场景看哪份**"，不重复声明项目值。

---

## 我现在要…

### …今天开工，启 Claude Code 开干

→ 看当天 [`daily/D<N>/README.md`](../daily/)（任务 + DoD）→ Kevin 派单前写 `daily/D<N>/_inflight.md`（防撞车）。

### …第一次接触这个项目（了解背景）

→ [`00-brief.md`](00-brief.md) 一页概览 → [`../PROJECT.md`](../PROJECT.md) 项目宪法。

### …查需求 / AC（验收标准）

→ 需求拆解正文（**冻结只读**）搜 ticket-id → 任何变更先看 [`changes.md`](changes.md) 有没有覆盖本 ticket 的 CR（**以 CR 为准**）。

### …查技术架构决策 / "为什么这么选"

→ [`_adr/README.md`](_adr/README.md)（ADR 索引 + 何时引用决策表）。栈特定机制看 [`../stacks/`](../stacks/)。

### …看客户答了哪些澄清 / 还有哪些待答 / 需求改了什么

→ 阻塞问题客户答：`00-brief.md` §澄清 →
→ 残余待答（带 Fallback）：[`_oq.md`](_oq.md) →
→ 需求变更：[`changes.md`](changes.md)。

### …用三件 SSOT（schema / 组件 / 验收）

→ [`../authority/`](../authority/)（AI 只能引用不能自造，CI 漂移即报错）。指针在 `../PROJECT.md` §5。

### …第一次拉代码跑起来

→ 本地开发指南（`03-*.md`，实例化时按栈写）+ [`../stacks/`](../stacks/) 栈插件。

---

## 文档地图（NN 编号语义）

> **编号约定**：顶层 `.md` 用 `NN-` 两位数前缀，**语义按段分配**——
> 00 概览 / 01 上下文 / 02 需求 / 03-04 工程基建 / 05 架构 / 06 实现 / 07+ 客户问答。
> 跟踪表用 `_<name>.md`（无编号，表示"持续追加"而非"一次沉淀"）。

### 主线文档（NN- 编号）

| # | 文档 | 内容 | 性质 |
|---|---|---|---|
| 00 | [`00-brief.md`](00-brief.md) | 项目一页 brief（含 P0/P1/P2 澄清分档） | 启动后沉淀 |
| 01 | `01-context.md` | 历史 session / 沟通切片（实例化时建） | 已沉淀 |
| 02 | [`02-requirements-template.md`](02-requirements-template.md) | 冻结版需求拆解**模板骨架**（版本号 + 🔒声明 + 功能域 + 每域 AC + 与三件 SSOT 关系）；实例化时按本模板新建为 `02-需求拆解-vX.md` | 模板 |
| 02 | `02-需求拆解-vX.md` | ticket 全索引 + 每 ticket AC（**冻结只读**，按上行模板新建） | ✅ 当前正文 |
| 02 | [`changes.md`](changes.md) | **CR 变更记录**（append-only，不动 02 正文） | 持续追加 |
| 03 | `03-本地开发-*.md` | 环境 / 启动 / 调试（按栈写） | 已沉淀 |
| 05 | `05-架构-*.md` | 架构总览（实例化时建，栈细节进 stacks/） | ✅ 当前 |
| 06 | `06-实现描述.md` | 每 ticket 实现思路 + 关键骨架 | ✅ 当前 |
| 07+ | `07-客户问答.md` | 客户澄清答案 + 沟通话术 | ✅ 当前 |

> **强默认**：02 需求正文一旦冻结**只读**；所有后续变更走 `changes.md` CR。
> **关掉条件**：纯一次性 2 小时级 bugfix / 机械改，不写需求正文也不开 ticket——直接给 task + 权威 context（见 `_adr/README.md` "不要为 X 起 ADR"）。

### 跟踪表（_ 前缀 = 持续追加）

| 文件 | 用途 | 必带 |
|---|---|---|
| [`_oq.md`](_oq.md) | 开放问题（待客户/待决） | **每条必带 Fallback**，状态机 ⏳→🟢→✅ |
| [`changes.md`](changes.md) | CR 变更记录 | 提出人 / 影响 ticket / before-after / 签字 |
| [`_adr/README.md`](_adr/README.md) | ADR 索引 + 何时引用决策表 | — |

### 原始资料（只读归档 + 加锁）

| 子目录 | 内容 | 锁 |
|---|---|---|
| [`origin/`](origin/) | 客户原始材料（SRS / 原型 / DB / 聊天 / 录音） | **只读**；md5 基线见 [`../scripts/snapshot.sh`](../scripts/snapshot.sh)，偷改 → 触发 CR |
| [`origin/_analysis/`](origin/_analysis/) | 对原始材料的**衍生品梳理**（二手） | [`origin/_analysis/WARNING.md`](origin/_analysis/WARNING.md) 逐文件标可信度 |

### Daily 执行（D&lt;N&gt;，挂到 PROJECT.md 的 M 锚点下）

> daily/ 由另一条 lane 维护；这里只放路由指针，文件清单见 [`../daily/README.md`](../daily/README.md)。

---

## 角色 × 场景速查

> 角色名按 `../PROJECT.md` §2 `<<TEAM_MODEL>>` 实例化。下表是**通用场景骨架**。

### 派单人 / 终审（如 Kevin）

| 场景 | 看 / 写 |
|---|---|
| 每天开工 | `daily/D<N>/README.md` |
| 派单前 | 写 `daily/D<N>/_inflight.md`（防 AI 撞同一文件 zone） |
| 跟客户对话前 | `07-客户问答.md` + [`_oq.md`](_oq.md) |
| 客户改需求 | 进 [`changes.md`](changes.md) 走 CR（**不动需求正文**） |
| 重大架构决策 | 进 [`_adr/`](_adr/) |

### Reviewer / 全栈（review + 测试）

| 场景 | 看 / 写 |
|---|---|
| 第一天 onboarding | `00-brief.md` + `03-本地开发-*.md` + [`../stacks/`](../stacks/) |
| 每天 review | `daily/D<N>/testing-*.md` + AI 的 `reports/<TICKET>.md` |
| 不熟某 ticket 业务 | 需求拆解正文搜 ticket-id（先确认无覆盖 CR） |
| 不熟某 ticket 技术 | `06-实现描述.md` 搜 ticket-id + 对应 ADR |

### 内测人员（如有）

| 场景 | 看 / 写 |
|---|---|
| 第一次上手 | 等 M3 前交付的"操作手册"（2-3 页 + 截图） |
| 提 bug | 统一入口（多维表 / issue），必填：复现 / 期望 / 实际 / 截图 |

### AI subagent（cwd 启动自动加载）

| 场景 | 加载 |
|---|---|
| 项目背景 + 强约束 | `<<PROJECT_PATH>>/.claude/CLAUDE.md`（自动） + [`../PROJECT.md`](../PROJECT.md) |
| §0 自检必读 | [`changes.md`](changes.md)（扫覆盖本 ticket 的 CR）+ [`../authority/`](../authority/)（三件 SSOT） |
| 当前 ticket | `daily/D<N>/prompts/<TICKET>.md`（派单人粘贴给 AI） |

---

## 维护约定

- 顶层 `.md` 用 `NN-` 编号；跟踪表用 `_<name>.md`。
- 每天 `daily/D<N>/` 独立文件夹。
- 任何需求变更走 [`changes.md`](changes.md)，**不动需求正文**。
- **实例值只在 `../PROJECT.md` 改一处**——本文件及其他文件只引用概念。
