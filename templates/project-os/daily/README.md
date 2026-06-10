# daily/ —— 执行机（Stage2 执行→验证）

> 这是工程 OS 的**执行端**。设计端（SP1 三件 SSOT）齐了、GATE 过了，才进这里按 ticket 派单 + 执行 + 验证。
> 项目：`<<PROJECT_NAME>>`（`<<PROJECT_PATH>>`）。团队模型：`<<TEAM_MODEL>>`。
>
> **占位约定**：所有 `<<...>>` token 真值**只在 `PROJECT.md` 声明一次**（单一变量源）。本文件引用概念。栈特定命令去 `stacks/<<本栈>>-notes.md`。

---

## 0. 三层颗粒度（周 / 日 / 单 spawn）

执行机有三个嵌套颗粒度，**别混用**：

| 层 | 是什么 | 谁产出 | 文件 |
|---|---|---|---|
| **周（W&lt;N&gt;）** | 一批 ticket 的主题分组 + 锚点判定（不是 deadline）+ 跨周对齐笔记 | 设计期切好（SP1b 依赖图） | 本文件 §2 总览表 + `weekly/W<N>-review.md`（按需） |
| **日（D&lt;N&gt;）** | 当天要做的一组 ticket（按文件/模块边界保证可并行）+ 当天的测试/进度/closing | SP1b 从 ticket 全集 + 依赖图切 | `D<N>/`（结构见 §3） |
| **单 spawn（ticket）** | 一个 fresh-context subagent 干一个 ticket 的完整三段式 | 派单方用 `_templates/prompt-ticket.md` 实例化 | `D<N>/prompts/<TICKET-ID>.md` |

**细化滚动规则**：D1-D5 详细 prompt 先写全；D6+ 先骨架（README + ticket 清单），**closing 时 AI 自动 grep 次日 ticket**——prompt 是骨架/缺 → 主动 spawn 用 `_templates/prompt-ticket.md` 补完整版；SSOT 里该 ticket 段缺 → spawn 补；testing-human 缺 → 用模板生成。次日开工预检再 grep 一次兜底。
> **为什么**：复盘教训——次日开工前必须细化完，否则 AI §0 自检会卡住（prompt 字面与真实 SSOT 不一致）。

---

## 1. 怎么用

> **cwd**：在 `<<PROJECT_PATH>>` 根起 Claude Code（自动加载 `.claude/CLAUDE.md` 项目引导，AI 知道全部强约束）。

### 1.1 派单方（Kevin / 主线程）开工
1. 打开 `D<N>/README.md` 看今日目标 + ticket 清单。
2. 多 ticket 并发 → 先在 `D<N>/_inflight.md` 登记每个 ticket 的文件 zone（同 zone 串行，跨 zone 并行）。
3. 依次打开 `D<N>/prompts/<TICKET-ID>.md`，复制全文 → 在新 Claude Code 窗口 spawn subagent。

### 1.2 AI 跑（每 ticket 三段式 —— 必走，详 `_templates/prompt-ticket.md`）
1. **§0 状态自检**：读 SSOT + ADR + 前置验收契约 / 查上游 merge / grep 硬产物 / 编译健康 → 不过 STOP。
2. **§0.5 设计预检**：共享命名空间资源建前 grep → 未对齐 STOP。
3. **主任务**：写代码（只引用 SSOT，不重定义）。
4. **§N 完工报告**：贴 raw output + 验收对账 + 对下游提示 + **PR Contract**（点名 reviewer 看哪块）。
> 派单时**不要催 AI 跳过自检**——自检 30s-2min，挡住的是几小时返工。

### 1.3 review + 测试（每 ticket 完工立刻进，不攒批）
1. AI 主任务方先跑 `testing-ai.md` 该 ticket 段 → 全 ✅ 才解锁人感官测试。
2. 按 `<<TEAM_MODEL>>` 跑 `testing-human.md`（只跑当天主链路，精简；机器可断言项已在 testing-ai 跑过）：多人 → 三人独立同一份交叉验证；solo → §Solo 退化路径（自己跑一遍 + 截图自检）。
3. 发现问题：能当场修的当场交 AI fix → 重测闭环，不进 `_open-issues.md`；只有无法及时解决 / 需决策的才 append（重复 raise AI closing 去重）。

### 1.4 closing（每天 merge 前最后一道关，AI 主导 + 人决策点）
1. AI 跑 `_templates/engineering-audit.md` → 写 `D<N>/audit-report.md`。
2. AI 整合 `reports/*.md` → 生成 `summary.md`（按各 report 的 PR Contract 给 reviewer 排查优先级）。
3. AI 把 `_open-issues.md` 待决条目编号汇总 → 人**原地**填决策（a/b/c/拒绝）。
4. AI 检测到决策已填 → 批量执行（doc / prompt / ADR / SSOT / 下游 prompt）→ status 改 ✅。
5. AI 跑 cross-ticket 联调确认契约。
6. **★事件驱动沉淀**（Stage3 灵魂，不靠周巡）：AI 当场沉一行 learnings + skill 候选到项目 `.claude/memory/`，**人拍板**是否采纳（自学习 agent 是 hype，只做事件驱动 + 人审）。
7. AI 输出当日 closing 一段话报告 → 人看 `summary.md` + `audit-report.md`，无 S0/S1 残留则 merge。

### 1.5 分支策略 + 并行跑多天（默认串行，可选并行 —— 按 `<<TEAM_MODEL>>` 填，参 `stacks/<<本栈>>-notes.md` §git）

**默认（串行）**：每天从 `<主干/集成分支 dev>` 切 `feature/day<N>`（**不在上一天分支上累加**，与 `.claude/CLAUDE.md` §2[1] 一致），当天 ticket commit；跑完测完 merge 回 dev，下一天从更新后的 dev 切。

**可选（并行跑多天）**：执行人当天有余力、且目标几天**彼此独立**时，可同时开跑——不必等 D1 测完才开 D2，这样能攒一批一起测、人不用每天等很久。**串行 / 并行 / 今天只跑一天，由执行人按当天状态自己定**（不自动调度）。

能不能并行，看 `D<N>/README.md` 顶部的 **`并行性`** 标记（SP1b 切天时按依赖图标好）：
- **`独立`**：本天 ticket 不依赖任何未合并天的产物 → 可与其他「独立」天同时跑。
- **`依赖 D<M>`**：必须 D<M> merge 后才能跑 → 不能与 D<M> 并行。
- **`含共享底座`**：本天动 common/基类/全局 seed（是别人的上游）→ **先单独做完合并，不并行**。

**怎么跑（三档执行，命令自动化，不手敲 git。由执行人按当天状态挑，不自动调度）**：

| 档 | 触发 | 跑几天 | 人 review/merge 落点 |
|---|---|---|---|
| **单个** | `/run-day <N>`（或说「执行 D<N>」） | 一天，当前会话 | 当天 closing 后 |
| **并行** | `/parallel-day <N>` ×N 窗口 | 独立的几天同时 | 攒批一起测 → `/integrate-day <N...>` 合 |
| **串行** | `/serial-day <A-B>`（或说「串行执行 D<A>-<B>」） | 依赖的多天链式跑完 | 挪到末尾批量厚验收 |

- **单个**：当前会话跑一天 6 步循环，稳、盯一天，人保留当天 merge。
- **并行**：开一个新 Claude Code 窗口 → `/parallel-day <N>` → 自动建/复用 worktree + 执行 D<N>。开 3 个窗口分别 `/parallel-day 1/2/3` 即三天并行；都完成后 `/integrate-day 1 2 3` 依次 merge 回 dev + 处理冲突 + 清理 worktree。
- **串行**：`/serial-day 1-10` 在一条集成分支上链式跑 D1..D10——每 ticket 真绿 gate + 决策落 `progress.md`、天边界对照 `doc/origin/` 原型对齐、**只在真卡住才熔断**、全部跑完末尾批量厚验收（回归 + `verify-tickets` workflow）；人只在末尾 review+merge。前提：SP1 三件 SSOT 齐 + prompt 已细化（串行档把判断压在 SP1，缺则 STOP）。
- 命令由 **project-os plugin** 提供（`/run-day`、`/parallel-day`、`/serial-day`、`/integrate-day`）；未装见 README §3。

下面是 `/parallel-day` **底层做的事**（透明，便于排查；正常不用手敲）：

```bash
# 对每个要并行的「独立」天 D<N>：
git worktree add ../<<PROJECT_NAME>>-d<N> -b feature/day<N> dev
#   → 在该 worktree 目录起一个独立 Claude Code，按 D<N>/ 跑（§0 自检照走）
#   → 每个 worktree 独立 build（装依赖/编译，见 stacks/）+ dev server 端口错开（防撞端口）
# 都跑完 + 各自 testing-ai ✅ → 依次 merge feature/day<N> → dev（或 staging）→ 一起人测
git worktree remove ../<<PROJECT_NAME>>-d<N>     # 测完清理，别留一堆
```

约束（别盲目堆并行）：
- **review 带宽是天花板**：并行 N 天写完，人 review/测试不过来就白并。最优同时 ~3-7 个量级，按「每 review·小时能吃多少 diff」实测再调。
- **碰共享底座的天不并行**（先做完合并，它是别人的上游）。
- **每 worktree 独立 build + 错开端口有 setup 成本**；< 15 分钟的小活并行是负 ROI。
- **合并冲突仍人工**：所以并行的天必须文件/模块不重叠（靠依赖图 + `并行性` 标记保证）。

**合并回 dev（怎么合 + 冲突从哪来）**：都跑完后，在 dev 那个目录里**依次** merge（不是三个同时），每合一个就编译/smoke 一次：

```bash
git checkout dev && git pull
git merge feature/day1     # 第一个一定干净
# 编译 + smoke ✅ 再合下一个（冲突早暴露、范围小）
git merge feature/day2     # 只在"和 day1 改了同一处"时才冲突
git merge feature/day3
```

- **真·独立的天（标对 `独立`）→ 基本不冲突**——这就是 `并行性` 标记的意义：并行前就保证文件/模块不重叠。
- **冲突只在「共享接缝」**：① **追加型登记表**（路由/菜单 seed/i18n/DI 注册——两天各加一行，行挨着了，语义不冲突）；② **迁移版本号**（经典 Flyway 撞号——靠 `stacks/<<本栈>>-notes.md` 里"版本号按天预分段"避免）；③ 共享配置（依赖清单/全局 yml）。
- **残余冲突处理**：①③ 多是 trivial「两行都留」→ 在 dev 窗口让 Claude Code 当场解 + 跑编译；想更稳，后跑完的天 merge 前先 `git rebase dev` 把冲突在自己分支消化掉再合。
- 合完清理：`git worktree remove ../<<PROJECT_NAME>>-d<N>`。

> **为什么给「可选」不给「自动」**：dongjiaoshan 串行慢，但盲目并行会撞共享底座（如 common 工具类）+ 压垮 review。给执行人按 `并行性` 标记自己拍——不建自动调度器（反 bloat）。
>
> **冲突的根在设计不在 git**：冲突多不多 = 这几天独不独立。把共享资源在 SP1 冻结（schema/字典/ID/菜单段）、把 `含共享底座` 的天拎出来先做，剩下 `独立` 的天并行 merge 基本干净。

---

## 2. 每日分组总览（锚点判定，不是 deadline）

> 起跑参考日是 informational，不是 deadline。某天没干完推下一天，没有"软目标"也没有"延误"。
> 状态：✅ 完成 / 🚧 进行中 / ⏸ 阻塞 / ⏳ 未开始

| Day | 起跑参考 | 主题 | ticket 数 | 并行性 | 关键 ticket | 状态 |
|---|---|---|---|---|---|---|
| **W1：<主题>（D1-D5）** |||||||
| [D01](./D01/README.md) | <date> | <主题> | <n> | 独立 | <关键 ticket> | ⏳ |
| ... | | | | | | |

> **并行性**（SP1b 按依赖图标，供执行人决定能否「并行跑多天」见 §1.5）：`独立`=可与其他独立天并行 / `依赖 D<M>`=须 D<M> merge 后才能跑 / `含共享底座`=先单独做完合并、不并行。

**ticket 全集数**：`<<本项目 ticket 全集数>>`（来自 SP1 ticket 全集 SSOT）。

### 完成判定锚点（不是工期）
| 锚点 | 判定标准 |
|---|---|
| M1 <底座完成> | <可机器/人验的达成标准> |
| ... | ... |

### 关键依赖图（不可颠倒）
```
<上游 ticket> ──► <下游 ticket 群>
```
上游没 merge → 下游 prompt 写"假设上游已 merge" + 引用方式；派单前核对集成分支状态。

---

## 3. 文件夹结构

```
daily/
├── README.md                  ← 你在这里（周/日/单 spawn 三层 + 本文件 = 单一估时权威源）
├── _templates/                ← 复用模板（D6+ 用 + AI fallback 引用）
│   ├── prompt-ticket.md       ← ★三段式 spawn prompt（§0 自检 + §0.5 预检 + 主任务 + §N + PR Contract）
│   ├── _open-issues.md        ← 非阻塞 raise 决策队列
│   ├── inflight.md            ← 当日并发 zone 表
│   ├── engineering-audit.md   ← 日终工程 audit（A/C/E/F/J generic + B/D/G/H/I 按栈）
│   ├── testing-ai.md          ← AI 机械验证（§0 前置验收契约 = 轻量 TDD + 强制 raw output）
│   └── testing-human.md       ← 人感官验证（含 §Solo 退化路径）
├── D01/
│   ├── README.md              ← 今日目标 + ticket 清单 + 锚点
│   ├── prompts/<TICKET-ID>.md ← 完整 prompt（可直接 spawn）
│   ├── testing-ai.md          ← 本日 AI 机械验证（含 §0 各 ticket 前置验收契约）
│   ├── testing-human.md       ← 本日人感官验证
│   ├── _inflight.md           ← 本日并发 zone 表
│   ├── _open-issues.md        ← 本日非阻塞 raise
│   ├── reports/<TICKET-ID>.md ← AI 每 ticket 完工报告（含 PR Contract）
│   ├── progress.md            ← ticket 状态表（AI closing 维护）
│   ├── summary.md             ← 文字总结 + reports 汇总（AI closing 生成）
│   └── audit-report.md        ← 日终 audit 结果（如有 issue）
└── D02/ - D<N>/               ← 同 D01 结构（D6+ 当天补 prompt 内容）
```

---

## 4. ★单一估时权威源约定（强默认 · 不可破）

**本文件 §2 总览表是唯一估时/计划权威源，且只标 ticket 数，不估时、不写人日、不排时间表。**

- ✅ 看本表：ticket 总量 / 子模块边界 / 上下游依赖 / 锚点。
- ❌ 全忽略：任何"人日 / 工时 / S·M·L size / 09:00 spawn / X ticket/天 / 容量够不够 / 进度好坏怎么调整"。
- 其他文档（需求拆解 / 实现描述 / prompt）若残留"人日"字样，视为**历史遗留**，AI 一律忽略并优先按本表执行。**不批量删**（避免 diff 噪音），AI 自觉跳过即可。
- audit 的 J.1 会 grep `_templates/` + 当日 `prompts/` 里残留的"人日/工期"并打回。

**为什么**：`<<TEAM_MODEL>>` 的节奏靠两个事实驱动——"上游 merge → 下游解锁"和"AI 跑完 → review → merge"，**不需要钟点**。把估时收敛到一处，杜绝多文档各报一套互相打架。

---

## 5. 不做的事（执行端约束）
- ❌ 不给 ticket 估时 / 不写派单时间表 / 不写"软目标·工期紧·可拖到 X"。
- ❌ 不算"X ticket/天 / 容量够不够 / 进度好差怎么调整"。
- ❌ 不在执行端建大量文档基建（极简路线：strong-default 的几件模板就够，可关的标了关掉条件）。
- ❌ 不在 daily 里直接动 `<<FRAMEWORK_BASE_PATHS>>`（第三方框架底座只读）。
