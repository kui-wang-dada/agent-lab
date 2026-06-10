# <<PROJECT_NAME>> — 项目级宪法（Claude 启动自动加载）

> 工程 OS 模板实例。在 `<<PROJECT_PATH>>` 根起 Claude Code 时本文件自动加载，
> AI / 派单人 / reviewer 都以此为项目级最高约束。
>
> **★单一变量源**：项目代号 / 栈 / 团队模型 / 业务域 / 路径等**实例值全在 [`../PROJECT.md`](../PROJECT.md)**。
> 本文件只**引用概念**（如"业务子树""字典权威源""第三方框架底座"），**绝不重复声明具体值**——改栈/改路径只动 PROJECT.md，杜绝 drift。

---

## 0. 这是什么 / 三段流水线定位

这个项目是**执行层**。它把 agent-lab（CEO/hub 层）的工程 OS 模板复制进来，按三段流水线跑：

```
Stage1 接料 → 设计     产出三件机器可验的 SSOT（schema / 组件+视觉锚定 / 验收 checkbox）
              ↓ GATE：三件齐 + 验收可机器验，才准派单进 Stage2
Stage2 执行 → 验证     按 ticket 三段式 spawn + review + 测试 + closing（review 带宽是吞吐天花板）
              ↓
Stage3 反哺 → 再生     事件驱动沉淀（当场沉一行 learnings + skill 候选，人拍板）+ 项目结束回写模板
```

**思考层 / 战略层 / 跨项目决策**回到 `~/Project/profile/project/agent-lab/`，不在本项目内处理。
（如"要不要换栈""客户预算变了怎么报价""这套 OS 本身怎么改"——回 hub。）

---

## 1. 派单边界（执行项目 ≠ CEO 层，不要 over-route）

> **本质区别**：agent-lab 主线程默认派单；**本项目主线程默认在 cwd 直接干活**（实施单个 ticket），
> 只有需要**切换视角**时才 `@` agent。over-route 会白烧 token + 拖慢节奏。

可用 agent 由 **project-os plugin** 提供（5 个：product/coder/qa/designer/curator，dev 类 3 个心智模式：想清楚做什么 → 写代码 → 找漏洞）。`/agents` 查看；未装 plugin 则按 README §3 装。

| 何时 | 动作 |
|---|---|
| ✅ 单 ticket 实施 | **主线程直接干**，不派 |
| ✅ 跨多模块大改 / 架构调整 / 复杂调试 / 需 spawn 并行 subagent | `@coder` |
| ✅ ticket 字段歧义 / 新 feature 评估 / ADR 草拟 | `@product`（除非要求 raise 到 `_open-issues.md` 集中处理） |
| ✅ 测试策略 / 失败用例分析 / E2E / 跑 testing-ai | `@qa` |
| ✅ 视觉拍板前（mockup / 客户视觉评审 / 真截图锚定） | `@designer`（设计期一等公民，见 Stage1） |
| ❌ 战略层问题（换栈 / 报价 / OS 本身） | 回 agent-lab，**不在本项目处理** |

> **为什么 designer 是上游一等公民**：复盘教训——视觉 ground-truth 缺位（prompt 用字段表而非真截图）是视觉偏差的根源。
> 共享组件清单 + design token + 真截图锚定必须在 Stage1 设计期定，不是 Stage2 边写边对。

---

## 2. 每天工作流（6 步日循环）

> **谁干什么**：按 [`../PROJECT.md`](../PROJECT.md) §2 `<<TEAM_MODEL>>` 落地。下图是**通用骨架**，
> 角色名（派单人 / reviewer / 内测）实例化时对应到真实的人。**AI 主体执行**（spawn、写码、写所有工件、跑 audit、整理次日）；
> **派单人做触发 + 终审**（开工 spawn、晚 review + merge 决策）；**reviewer 做决策点 + 感官测试**。

```
  ┌─[1] 开工：切分支 ────────────────────────────────────────┐
  │  派单人对每个 repo（见 PROJECT.md §4 业务子树所在仓库）：    │
  │    git checkout <主干> && git pull && git checkout -b feature/day<N> │
  │  打开 daily/D<N>/README.md → 看今日 ticket 清单            │
  │  多 ticket 并发 → 先在 D<N>/_inflight.md 登记文件 zone      │
  │  复制 prompts/<TICKET>.md 全文 → spawn AI                  │
  │  ⚠️ 不在 feature/day<N-1> 上累加干 D<N>（例外：明示 hotfix）│
  └────────────────────────────┬─────────────────────────────┘
                               ▼
  ┌─[2] AI 跑（每 ticket 三段式，详 _templates/prompt-ticket.md）┐
  │  §0 状态自检（必做）：读 SSOT + ADR + 前置验收契约 / 查上游 │
  │     merge / grep 当前分支与硬产物 / 编译健康 → 不过 STOP   │
  │  §0.5 设计预检：共享命名空间资源建前 grep → 未对齐 STOP    │
  │  主任务：写代码（只引用三件 SSOT，不自造、不重定义）        │
  │  §N 完工报告 → D<N>/reports/<TICKET>.md（每 ticket 独立文件 │
  │     避免并发写冲突）：raw output + 验收对账 + PR Contract  │
  │     （点名 reviewer 看哪块）+ 对下游提示                    │
  │  非阻塞 raise → D<N>/_open-issues.md（append，不当场改别处）│
  │  同步追加自己的 case 到 testing-ai.md + testing-human.md   │
  └────────────────────────────┬─────────────────────────────┘
                               ▼
  ┌─[3] 测试（顺序：AI → 人，每 ticket 完工就跑，不攒批）──────┐
  │  AI 主任务方跑 D<N>/testing-ai.md（机械验证：编译/单测/   │
  │     count/curl/runtime smoke 全 ✅ 才解锁人感官）          │
  │     ★跑完每条 case 旁标 ✅/❌ + 关键输出（留空 = 没测）   │
  │     ❌ → AI 自己 fix 重跑，不请示；仍 ❌ 才升级派单人      │
  │  按 <<TEAM_MODEL>> 跑 D<N>/testing-human.md（只跑当天   │
  │     主链路，精简；机器可断言项已在 testing-ai 跑过）：     │
  │     多人 → 各自独立跑同一份交叉验证（不分 case）           │
  │     solo → testing-human §Solo 退化路径                    │
  │     发现问题 → 能当场修的当场交 AI fix → 重测闭环；       │
  │     只有无法及时解决 / 需决策的才 append _open-issues.md   │
  └────────────────────────────┬─────────────────────────────┘
                               ▼
  ┌─[4] 日终 closing（AI 主导 + 人只填决策点）────────────────┐
  │  AI 跑 _templates/engineering-audit.md → audit-report.md  │
  │  AI 整合 reports/*.md → summary.md（按 PR Contract 排查    │
  │     优先级，重点提顶部）                                   │
  │  AI 维护 progress.md（状态 / merge 位）                    │
  │  AI 把 _open-issues.md 待决条目编号汇总 → 输出给 reviewer：│
  │     "条目 #N 已贴格式，请在文件里 **决策** 字段填 a/b/c/拒绝"│
  │  reviewer 在 _open-issues.md 里**原地**逐条填决策          │
  │  AI 检测到决策已填 → 按优先级批量执行（见 §3 落地优先级）  │
  │     → status 改 ✅ + 补"落地"链接                          │
  └────────────────────────────┬─────────────────────────────┘
                               ▼
  ┌─[5] closing 收尾 — AI 自动完善次日任务 ───────────────────┐
  │  grep D<N+1>/prompts/*.md：骨架/缺 → spawn 用              │
  │     _templates/prompt-ticket.md 写完整版                   │
  │  grep 三件 SSOT 里 D<N+1> ticket 段：缺 → spawn @product 补│
  │  testing-human 缺该 ticket → 用模板生成                    │
  │  有调整（顺序/范围）→ 更新次日 README                      │
  └────────────────────────────┬─────────────────────────────┘
                               ▼
  ┌─[6] ★事件驱动沉淀（Stage3 灵魂，不靠周巡）────────────────┐
  │  AI 当场沉一行 learnings + skill 候选到 .claude/memory/    │
  │     （SubagentStop hook 已自动轻量入队 + 去重；这里是 AI  │
  │      显式补一行人类可读的"为什么"）                        │
  │  ★分层自治：失败护栏/stack/事实可当场落（事后可否决）；   │
  │     新 skill/改机器出候选→人拍板（抽取门槛见 §3）          │
  │  AI 输出当日 closing 一段话 → 人看 summary + audit，       │
  │     无 S0/S1 残留则 merge feature/day<N>                   │
  └───────────────────────────────────────────────────────────┘
```

> **为什么 closing 是 merge 前最后一道关**：复盘教训——daily 在后期裂成返工螺旋（D09X/D10X/Y/Z/D-FIX）。
> 根因是没有"齐了才进下一步"的硬关。closing audit + 验收对账就是那道关。

---

## 3. 角色边界 + AI 落地优先级

### 3.1 谁碰哪一层（强约束）

- **AI（主体）**：所有工件 + 代码 + audit + 次日整理，全权干。测试 ❌ 自己 fix 重跑不请示。
- **派单人 / 终审**：开工 spawn + 晚 review `summary.md`/`audit-report.md` + merge 决策。**不参与工件填写**。
- **reviewer / 全栈**：`_open-issues.md` 原地填决策点（一行 a/b/c/拒绝）+ 感官测试。**不做管家活**（不逐条翻文件再自己改 doc）。
- 核心原则：**AI 既是 raise 方又是执行方，人只在中间插一个决策环节。**

### 3.2 AI 执行修改的落地优先级（关键 —— 修源头，别一个 bug 一个 skill）

| 优先级 | 改什么 | 适用 | 预期占比 |
|---|---|---|---|
| 🥇 第一 | 三件 SSOT（`../doc/authority/` schema / 组件 / 验收 checkbox） | 字段名 / 字典 key / UI 偏离 — 修源头 | ~60% |
| 🥈 第二 | `daily/_templates/prompt-*.md` + 下游 ticket prompt | 实施流程经验（必查清单 / 反模式） | ~30% |
| 🥉 第三 | `doc/` 决策文档 / `../PROJECT.md` / 新 ADR | 项目级决策 / 横切约束 | ~10% |
| 第四（极少） | `.claude/skills/<topic>.md` | **同时满足 3 条**：横跨 ≥ 3 ticket + 修 prompt 不够 + 方法论可复用 | ≤ 10%（一周 ≤ 2 个） |

> **skill 抽取严格门槛**：单 ticket 修复 → 改 prompt；横切 2 ticket → 改 prompt 模板"必查清单"；
> 横切 ≥ 3 ticket 且方法论级 → 才考虑 skill。**不要"一个 bug 一个 skill"**——skill 多了稀释，没人读。
> 栈特定机制不进通用 skill，进 [`../stacks/<<本栈>>-notes.md`](../stacks/)。

---

## 4. §0 自检 / §N 总结规约（指针，不在此重述细则）

每个 ticket prompt 由 [`../daily/_templates/prompt-ticket.md`](../daily/_templates/prompt-ticket.md) 实例化，强制含：

- **§0 状态自检（实现前）**：以 [`../PROJECT.md`](../PROJECT.md) 为项目值之准 → 查 git 分支 / 上游 merge / 关键类·表·API 硬产物 / 编译健康 + 读三件 SSOT（[`../doc/authority/`](../doc/authority/)）+ 关联 ADR（[`../doc/_adr/README.md`](../doc/_adr/README.md)）+ 扫 [`../doc/changes.md`](../doc/changes.md) 有无覆盖本 ticket 的 CR。**不通过 → STOP 报派单人，不要自行开始。**
- **§0.5 设计预检（建共享命名空间资源前）**：grep 已占用段 → 未对齐 STOP（防共享资源撞车）。
- **§N 完工总结（实现后）**：写 `D<N>/reports/<TICKET>.md` —— git diff --stat / 新增关键产物 / 自测情况 / 验收对账 / **PR Contract（点名 reviewer 看哪块）** / 对下游提示 / 已知 issue。

> **为什么 §0 自检不可省**：复盘救场记录——§0 现场自检挡住过"漏建表 / 字段列类型错 / 分支切错"等返工源。
> 自检 30s-2min，挡住的是几小时返工。派单时**不要催 AI 跳过自检**。

---

## 5. 强约束（AI 违反直接打回）

> 通用机制在此；**栈特定约束**（框架 service 基类 / 迁移命名 / 菜单 seed 分段 / install-restart 流程等）
> 一律落在 [`../stacks/<<本栈>>-notes.md`](../stacks/)，**不进**本宪法。

1. **不动第三方框架底座** `<<FRAMEWORK_BASE_PATHS>>`（settings.json deny 写入；只读参考，升级走单独流程）。所有业务代码落 `<<BUSINESS_MODULE_PATHS>>`。
2. **三件 SSOT 只能引用不能自造**：enum / 字典 / ID 命名 / 表结构以 [`../doc/authority/`](../doc/authority/) 为准；偏离即 raise CR，不私自改。
3. **多租户 / 权限 / 支付字段按权威源**（B 端 security 是 Stage2 一等公民，不是上线前补）；UNIQUE 约束含租户维度（具体字段见栈插件）。
4. **DB 迁移落 `<<MIGRATION_DIR>>`**，命名规约见栈插件 / ADR；公共审计字段不漏（漏列 INSERT 即报错）。
5. **不写 `any`（TS）/ 不吞异常 / 不写无说明 TODO / 不留注释掉的旧代码**。
6. **不引未澄清的新依赖**（必须派单人批准）—— 优先用栈底座已有的。
7. **i18n / 文案**按 `<<TEAM_MODEL>>` 与客户语言定（见栈插件；默认不混 emoji）。
8. **实现前必做 §0 自检 + 必读关联 ADR**（prompt 模板强制）—— 不通过 STOP。
9. **开工前必切 `feature/day<N>`**（不在该分支 → §0 自检 STOP）；不默认在 `day<N-1>` 上累加干 D<N>（复盘教训：多 agent 全在前一天分支累加 → review/merge 边界模糊）。
10. **testing-ai / testing-human 必填**：实施时同步追加自己的 case 段；**留空等于没测**，closing audit 会查每个完工 ticket 是否都有对应 case。AI 跑完 testing-ai 必在每条旁标 ✅/❌ + 关键输出。
11. **长进程跑完主动关**（防端口冲突）：AI 起的 `dev server` / `runtime` 等长进程，任务结束前主动 kill 自己起的端口；**共享基础设施容器不关**（长期跑）。完工汇报必须明示进程状态：✅ 已关 / 🟡 留给谁用 / 绝不沉默退出留着。
12. **不记录中间态 / 不留变更历史**：doc / SQL / 配置直接写最终值，不写"曾经是 X 现在改成 Y"、不留 `// removed`、不在正文反复引用 CR/ADR 编号（决策原因进 git commit + PR description；唯一例外是 ADR 本身）。评判标准：**5 个月后入职的新人能不能只看这一份 doc 直接干活。**

---

## 6. 不在此处做的事（AI 自觉别越界）

- **不重新设计架构** —— 用 [`../doc/_adr/`](../doc/_adr/) 已定的，有疑问回 agent-lab 找 Kevin。
- **不动第三方框架底座代码** —— 参考用法即可，不优化、不重构。
- **不加未列入 ticket 全集的新功能** —— 任何新 feature 走 ADR / CR 流程。
- **不跑迁移之外的破坏性 SQL**（DROP / TRUNCATE / 大量 DELETE）—— 先报派单人。
- **不动其他 sibling 项目** —— agent-lab、其他客户项目都是独立项目，**只读不写**。
- **不建大量文档基建** —— 极简路线，strong-default 的几件模板就够（可关的标了关掉条件）。

---

## 7. 学习闭环（经验回流引擎 · 分层自治）

> **立场（2026-06 校准）**：自学习**是目的本身**——让下次接活起点更高。要反对的是**"无人在环、向量魔法式全自动进化"**（那是 hype），不是自学习。做法是**分层自治**：低风险类（失败护栏 / stack 经验 / 事实）自动落、Kevin 事后可否决；高风险类（新 skill / 改 agent / 改 plugin 机器）出候选、人拍板。本 OS 做两件确定的事：

1. **SubagentStop / Stop hook**（由 **project-os plugin** 提供）：子 agent / 主对话完成时**当场轻量入队 + 去重 + 标记 + 打 `signal`（failure/normal）**到 `.claude/memory/_review-queue/`（不攒队列等周巡；失败信号最该沉淀成护栏）。
2. **AI closing 当场沉一行**：每天 closing 第 6 步，AI 补一行人类可读的 learnings + skill 候选。**分层自治**：失败护栏 / stack 经验 / 事实属低风险，可当场落；新 skill / 改机器属高风险，出候选 → **人拍板**。

memory 结构（实例化时从 agent-lab 同步 USER.md，本项目只读）：

```
.claude/memory/
├── USER.md              Kevin 用户模型（从 agent-lab 同步，本项目只读）
├── SKILLS_INDEX.md      可复用 skill 索引
├── <domain>/{facts,learnings}.md   按 <<TEAM_MODEL>> 的 domain 切
└── _review-queue/       SubagentStop hook 当场入队，closing/反哺时消费
```

**项目结束反哺**（Stage3 再生，一次性）：经验 → agent-lab 经验池；通用机制 → 回写 `templates/project-os/` 模板（副本与 hub 的 drift 在此收敛）。栈特定教训进 `stacks/<<本栈>>-notes.md`。

---

## 8. 输出风格（项目内）

- 中文交流，技术术语保留英文。
- 不堆方法论，给可执行步骤。
- 完成后报告"改了哪些文件"（路径保持一致）。
- 不写空话和过度礼貌性铺垫；不写"基于以上分析"这类废话开头。
- 给推荐附理由，让 Kevin 能反驳；不替 Kevin 做"是否要做某事"的决策——给选项 + 推荐 + 理由。

---

## 8.5 Compaction 保留（长日 session 适用）

压缩对话时（`/compact` 或自动），**务必保留**：当前 `feature/day<N>` 分支 + 活跃 ticket ID、改动文件清单、三件 SSOT（`doc/authority/`）的已定决策、testing-ai/human 跑到哪、待 merge 状态。

> best-effort（v2.1.152），非强制。强保证靠落盘——`daily/D<N>/progress.md` + `summary.md` 是项目态的权威源，compaction 丢了也能从这两份重建。

---

## 9. 关键文档索引

| 路径 | 用途 |
|---|---|
| [`../PROJECT.md`](../PROJECT.md) | ★单一变量源 / 项目宪法（所有实例值） |
| [`../doc/README.md`](../doc/README.md) | 文档地图 + 角色×场景路由 |
| [`../doc/00-brief.md`](../doc/00-brief.md) | 项目一页 brief + 澄清分档 |
| [`../doc/_adr/README.md`](../doc/_adr/README.md) | ADR 索引 + 何时引用决策表 |
| [`../doc/changes.md`](../doc/changes.md) | CR 变更记录（append-only） |
| [`../doc/_oq.md`](../doc/_oq.md) | 开放问题（每条带 Fallback） |
| [`../doc/authority/`](../doc/authority/) | 三件 SSOT（schema / 组件 / 验收 checkbox） |
| [`../daily/README.md`](../daily/README.md) | 执行机：周/日/单 spawn 三层 + 单一估时权威源 |
| [`../stacks/`](../stacks/) | 按栈插件（框架特定机制全在这里） |
| project-os plugin | 机器层：5 个 agent（`/agents`）+ 三档执行命令（`/run-day`、`/parallel-day`、`/serial-day`、`/integrate-day`，见 §10）+ hooks。装法见 README §3 |
| [`rules/`](rules/) | path-scoped 规则（碰对应栈文件才加载，如 `ruoyi.md`）—— 经验回流引擎低风险类落点 |

---

## 10. 执行多天：单 / 并行 / 串行 三档（命令驱动，不手敲 git）

> 同一套 6 步日循环（§2），三种触发方式，**差别只在"跑几天"和"人 review/merge 落在哪"**。由执行人按当天状态自己挑，**不自动调度**。命令由 **project-os plugin** 提供（未装见 README §3）。

| 档 | 触发 | 跑几天 | 人 review/merge | 何时用 |
|---|---|---|---|---|
| **单个** | 「执行 D\<N\>」= `/run-day <N>` | 一天，当前会话 | 当天 closing 后 | 要稳、要盯一天；或只剩一天 |
| **并行** | 「并行执行 D\<N\>」= `/parallel-day <N>` ×N 窗口 | 独立的几天同时 | 攒批一起测，`/integrate-day` 合 | 几天标 `独立` 且当天有余力 |
| **串行** | 「串行执行 D\<A\>-\<B\>」= `/serial-day <A-B>` | 依赖的多天链式跑完 | 挪到末尾批量厚验收 | 多天依赖、想基本无人值守 |

- **`/run-day <N>`**：当前会话跑一天，人保留当天 merge 决策。也可直接说「执行 D\<N\>」。
- **`/parallel-day <N>`**：自动建/复用 git worktree（`../<项目>-d<N>`，从 dev 切 `feature/day<N>`）+ 在里面执行 D\<N\>。开 N 个窗口各跑一天 = N 天并行。约束：`依赖 D<M>` / `含共享底座` 的天不并行；迁移号守各天预占段（[`../stacks/`](../stacks/) §2）；review 带宽是并发天花板。
- **`/integrate-day <N...>`**：并行的天都完成后依次 merge 回 dev（+ 冲突处理 + 清理 worktree）。
- **`/serial-day <A-B>`**：一条集成分支上链式跑 D\<A\>..D\<B\>——每 ticket 真绿 gate + 关键决策落 `progress.md`、天边界对照 `doc/origin/` 原型对齐、**只在真卡住（`BLOCKED`）才熔断**、全部跑完末尾批量厚验收（回归 + 对抗式 workflow）。**人只在末尾 review+merge，不自动 merge 到 dev**。前提：SP1 三件 SSOT 齐 + prompt 已细化（串行档把判断压在 SP1 质量上，缺则 STOP）。

> **三档全程不手敲 git**；都不 force push / reset --hard（settings.json 已 deny）。串行档是 §9「不在 day\<N-1\> 累加」的显式例外（单一顺序执行体，review 边界 = 链末尾）。
