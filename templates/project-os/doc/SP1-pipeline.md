# <<PROJECT_NAME>> — SP1 流水线：接料 → 设计（工序说明）

<!-- SP1 是三段流水线的第一段（Stage1 接料→设计）。其产出 = 三件机器可验的 SSOT，直接成为 Stage2 的 gate。-->
<!-- 设计权威：docs/superpowers/specs/2026-06-03-human-ai-engineering-os-design.md §3。-->
<!-- 核心形态（Kevin 拍板）：SP1 产出不是传统设计文档，而是三件机器可验的 SSOT（schema / 组件视觉 / 验收 checkbox）。-->
<!-- AI 只能引用这三件、不能自造；GATE 通过才准进 SP1b 派单。 -->
<!-- 强默认 ON：大型核心业务走全套 SP1。关掉条件见 §5 颗粒度判定（小改不写 spec）。 -->

> 本项目所有实例变量（项目路径、团队模型、技术栈、业务域等）的**唯一声明源**是 `PROJECT.md`。
> 本文件只引用概念（`<<PROJECT_NAME>>` / `<<DOMAINS>>` / `<<TEAM_MODEL>>` 等），不重复声明值（anti-drift）。

---

## 0. SP1 总览

```
甲方资料（需求 doc / 原型 / 表设计 / 聊天记录 / 录音 ...）
│
├─ Step0 接料加锁 ──── origin/ 只读 + snapshot 存 md5（偷改触发 CR） + 标衍生品可信度
│
├─ Step1 需求澄清 ──── AI 跨域列疑点 P0/P1/P2（机器可勾选）→ 客户答 P0 → 需求拆解(冻结) + OQ(带 Fallback)
│
├─ Step2 架构 + ★全局资源台账 ── ADR(先决策后 prompt) + enum/字典/ID命名/编号规则 定权威
│
├─ Step3 ★三件 SSOT 落地
│   ① schema-ssot.md          冻结 schema(enum/字典/ID/表结构) → repo + CI 漂移即报错   [治 dict 撞墙 + 列类型错]
│   ② components-ssot.md       共享组件 + design token + 真截图锚定(★designer 上场)       [治 视觉偏差]
│   ③ acceptance-checkboxes.md ticket 全集 + 每 ticket 机器可验收(含验收 SQL)              [治 双字段 + Verification Gap]
│
├─ ★GATE ──── 三件 SSOT 齐 + 验收 checkbox 可机器验 → 才准进 SP1b（硬门槛）
│
└─ SP1b 每日任务生成 ── 从三件 SSOT + 依赖图切 D<N>（按文件/模块边界保证可并行），不再边写边拆
```

**三个关键决定（设计文档 §3.1）**：
1. **designer 升为上游一等公民**——视觉 ground-truth 在 SP1 就钉死（治"视觉偏差根源 = 设计阶段没有视觉权威"）。
2. **GATE 是硬门槛**——design 完成 = 三件 SSOT 齐 + 验收可机器验，才准派单（SP1→SP2 的齿轮）。
3. **原则 + 按栈插件 + 颗粒度判定**——通用机制走全套，栈细节进 `stacks/`，小改不写 spec（§5）。

---

## 1. Step0 接料加锁

<!-- 为什么加锁：dongjiaoshan 验证有效——客户原始料是衍生一切的源头，被人/工具偷改会让下游全部失真且无人察觉。 -->

- **origin/ 只读**：所有客户原始料放 `origin/`，置只读；任何衍生/清洗产物放别处，不污染原件。
- **snapshot 存 md5**：对 `origin/` 全量算 md5 存档。后续若 md5 变 = 原始料被改 → 自动触发一条 CR（变更请求），逼人确认"是不是客户真改了需求"。
- **标衍生品可信度**：对二手梳理/分析料标 🥇/🟡/❌（与 `components-ssot.md §1` 分级一致），并写一份 WARNING 标明"哪些料的哪部分不可信"。

**产出**：`origin/`（只读）+ snapshot + 衍生品可信度标注。

---

## 2. Step1 需求澄清

<!-- 为什么先澄清再设计：需求不冻结就开 schema/组件，等于在流沙上盖楼。-->
<!-- P0/P1/P2 分级 + 机器可勾选 + OQ 带 Fallback 是 dongjiaoshan 验证的有效模式（CR·OQ 双轨）。 -->

1. **AI 跨域列疑点**：扫全部料，跨业务域列出所有矛盾/缺失/模糊点，按阻塞性分级：
   - **P0** = 不答就开不了工（如核心状态枚举、隔离模型）→ 必须客户答。
   - **P1** = 影响实现但可先按推荐默认走 → 列推荐值 + 标 ⏳ 待客户确认。
   - **P2** = 边角，后续版本再说。
2. **机器可勾选问题**：疑点写成"问题 + 选项 + 推荐 + 影响 ticket"的可勾选清单，客户/Kevin 逐条拍板。
3. **客户答 P0** → **需求拆解（冻结）**：拆解版定稿后冻结，后续改动走 CR。
4. **OQ（Open Question）带 Fallback**：没答完的开放问题登记 OQ，每条**必须带 Fallback**（没答时按哪个默认走），保证启动不被阻塞。

**产出**：疑点清单（P0/P1/P2）+ 冻结的需求拆解 + OQ 清单（带 Fallback）。

> **与字典待问联动**：`schema-ssot.md §3` 的"待问客户清单"与本步 P0/OQ 是同一批问题的不同视图——字典缺失多数是 P0/P1。

---

## 3. Step2 架构 + 全局资源台账

<!-- 为什么先决策后 prompt：dongjiaoshan 教训——架构决策没先定，就在每个 ticket prompt 里临时拍，导致跨 ticket 不一致。-->
<!-- 全局资源（字典/ID命名/编号规则/菜单段等）必须在派单前定权威，否则每个 subagent 自造一套 → dict 撞墙。 -->

- **ADR（先决策后 prompt）**：所有跨 ticket 的架构选择先写成 ADR（如隔离模型、状态机实现方式、共享底座边界），定稿后 ticket prompt 引用 ADR，不在 ticket 里临时决策。
- **★全局资源台账**：把全局唯一资源的权威值钉死：
  - enum / 字典 → 落进 `schema-ssot.md §3`
  - ID 命名 / 业务编号规则 → 落进 `schema-ssot.md §4`
  - 共享组件 / design token → 落进 `components-ssot.md §4/§5`
  - 其他全局资源（菜单段/路由段/权限位等）→ 视栈落进 `stacks/<<stack>>-notes.md`（栈细节不进通用模板）

**产出**：ADR 集 + 全局资源台账（分散落进三件 SSOT + stacks）。

---

## 4. Step3 三件 SSOT 落地（SP1 的产出本体）

<!-- 这一步是 SP1 的核心交付。三件各治一个 dongjiaoshan 返工源。 -->

| 件 | 文件 | 治的病 | designer/角色 |
|---|---|---|---|
| ① 冻结 schema | `authority/schema-ssot.md` | dict 撞墙 + 列类型错 | coder/架构 |
| ② 组件+token+真截图锚定 | `authority/components-ssot.md` | 视觉偏差 + 共享组件没识别 | **★designer 上场（上游一等公民）** |
| ③ 机器可验收 checkbox | `authority/acceptance-checkboxes.md` | 双字段 + Verification Gap | coder + qa |

**纪律**：三件 SSOT 定稿即 FROZEN；AI 在 SP1b/SP2 只能**引用**这三件，**不能自造** schema/视觉/验收；改动走各文件的 CR 流程。

**产出**：三件 FROZEN 的 SSOT + CI 漂移检查（schema）+ failing-first 验收脚本（checkbox）。

---

## 5. 颗粒度判定（何时走全套 SP1，何时不写 spec）

<!-- 设计文档 §3.1：避免 SDD 维护税。强默认走全套，但小改直接给 task + 权威 context，不写 spec。-->
<!-- 这是 mental-model note，不建任何"自动触发"机器（Kevin 反 bloat：不做 tier-auto-trigger）。 -->

| 任务类型 | 走 SP1 哪些步 | 为什么 |
|---|---|---|
| **大型核心业务**（新域/新主流程/多表多端） | 全套 Step0-3 + GATE | 漂移成本高，三件 SSOT 的投入值回票价 |
| **中型功能**（已知域内新增 ticket，复用既有 schema/组件） | Step1 轻澄清 + 在三件 SSOT **追加段**（不重起） | 框架已在，只补增量 |
| **2 小时级 bugfix / 机械改**（改文案、调样式、修明确 bug） | **不写 spec**：直接给 task + 权威 context（引用三件 SSOT 相关段） | SDD 维护税 > 收益；强行写 spec 是仪式 |

> **判定口诀**：会被未来 2+ 个 ticket 依赖的"权威"才进 SSOT；一次性的活直接给 context 干。
> 这是 mental-model note——**不**做任何按 tier 自动触发的机器（反 bloat）。

---

## 6. ★GATE 判据（硬门槛 —— 不过不准进 SP1b/派单）

<!-- GATE 是 SP1→SP2 的齿轮。判据必须可机械核对，不能"感觉差不多了"。 -->

派单（进 SP1b）前，逐条核对，**全 Y 才放行**：

- [ ] **三件 SSOT 齐**：`schema-ssot.md` / `components-ssot.md`（有 UI 时）/ `acceptance-checkboxes.md` 均存在且各自头部声明 = FROZEN。
- [ ] **schema 冻结 + CI 漂移检查就绪**：`schema-ssot.md` 入 repo，CI 漂移检查脚本能跑（或人工比对脚本就绪）。
- [ ] **枚举/字典无未决 P0**：`schema-ssot.md §3` 的 🔴 待问客户项要么已答、要么有 Fallback 默认值且标 ⏳（不阻塞启动）。
- [ ] **视觉锚定到真截图**：`components-ssot.md §2` 每个在范围页面都钉到 🥇 真截图；共享组件已按 §3 识别并登记 §4。
- [ ] **验收可机器验**：`acceptance-checkboxes.md §6` 覆盖总表里每个范围内 ticket 都有行，关键断言带期望值，failing-first 验证脚本就绪。
- [ ] **需求已冻结**：Step1 需求拆解 FROZEN，OQ 均带 Fallback。

> **为什么 GATE 要硬**：dongjiaoshan 的返工螺旋（D09 后裂成 D09X/D10X/D-FIX）本质是带着未冻结的设计去执行。GATE 把"设计是否真完成"变成可核对的清单，不达标不许派单。

---

## 7. SP1b 每日任务生成（从 SSOT 切 D<N>）

<!-- 为什么"不再边写边拆"：dongjiaoshan 边实施边拆 ticket 导致依赖混乱、并行冲突。-->
<!-- GATE 通过后，从三件 SSOT + 依赖图一次性切出 D<N> 序列，按文件/模块边界保证可并行。 -->

- **切分依据**：ticket 全集（`acceptance-checkboxes.md`）+ 依赖图（哪些表/组件被哪些 ticket 依赖）。
- **★标并行性**：每个 D<N> 按依赖图标 `并行性`（`独立` / `依赖 D<M>` / `含共享底座`），写进 `D<N>/README.md` 顶部 + `daily/README.md §2` 总览——供执行人决定能否「并行跑多天」（worktree SOP 见 `daily/README.md §1.5`）。默认串行，并行是执行人按当天状态主动选的选项，**不自动调度**（反 bloat）。
  - 判定：本天**所有** ticket 的上游依赖都已在更早的、会先合并的天里 → `独立`；否则 `依赖 D<M>`；本天动 common/基类/全局 seed → `含共享底座`（它是别人的上游，先做完）。SP1 三件 SSOT 冻结得越早，跨天依赖越少，可并行的天越多。
- **可并行约束**：按文件/模块边界切 D<N>，使同一 D<N> 内多 ticket 改的文件不重叠（减少 review/合并冲突）。
  - **共享底座文件**用文件 zone（`_inflight.md` 标记谁在改哪段）协调，比 git worktree 更适合多人改同一共享层（dongjiaoshan 验证）。
- **ticket prompt 结构**（每个 D<N> 的 ticket）：
  - **§0 自检**：先读三件 SSOT 相关段（schema §X / 组件视觉 §Y / 验收 §Z）；不一致即 STOP。
  - **主任务**：引用三件 SSOT 的具体 §，不重述、不自造。
  - **§N 回填**：贴 raw output + 验收断言执行结果（供 closing 审计）。
- **细化程度**：近期 D<N> 细化，远期 D<N> 先骨架（避免过早细化在 CR 后全废）。

> **review 带宽提醒（来自设计文档批判）**：并发上限受 `<<TEAM_MODEL>>` 的 review 带宽限制——review 是吞吐天花板。SP1b 切并发度时别盲目堆高，SP2 会实测"每 review·小时能吃多少 diff"再定。

---

## 8. 与下游 SP2 / SP3 的接口

- **→ SP2（执行→验证）**：SP1 的三件 SSOT 是 SP2 的 gate 输入——schema CI 校验、验收断言 hook、视觉 diff 全部消费 SP1 产出。
- **→ SP3（反哺→再生）**：SP1 过程中发现的"通用机制"（如新的疑点分级套路、新的 SSOT 段模板）在项目结束时回写本模板（漂移收敛）；一次性的项目经验进经验池。

> 本文件描述工序；具体栈怎么落地（RuoYi 的 DDL/MyBatis、小程序截图 CLI、Prisma 等）见 `stacks/<<stack>>-notes.md`——栈是实例，工序是通用。
