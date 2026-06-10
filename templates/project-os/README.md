# project-os — 人 + AI 工程 OS 模板

> 可复制的"项目本地决策层 + 执行机 + 验证骨干"。每开一个新项目，把这套模板 `cp` 进 `freelance/projects/<name>/`，替换占位符即得到一个**自包含、可移植**的工程 OS。
>
> 设计来源：`agent-lab/docs/superpowers/specs/2026-06-03-human-ai-engineering-os-design.md`（方案 A：模板复制 + 事件驱动反哺）。
> 经验来源：dongjiaoshan 项目复盘（领先实践抽取 + 三个返工源根治）。

---

## 0. 这是什么 / 不是什么

**是**：一套同形的工程操作系统。所有项目用**同一个结构**——SP1 接料→设计、SP2 执行→验证、SP3 反哺→再生。
**不是**：可选的"加分仪式"。它是默认 ON 的工作流，不是项目大了才上的额外开销。

### 设计哲学：强默认 + 可关（不是"极简内核 + 按需加"）

dongjiaoshan 的教训是把"为跨项目/慢节奏设计的东西原样塞进单项目/冲刺"，结果整套像额外仪式空转。但**结论不是"砍到极简内核"**——而是：

- **强默认**：把已验证的最佳实践**默认打开**（三件 SSOT、前置护栏、事件驱动沉淀都是 ON）。
- **可关**：每个可选件都标明"关掉条件"。小项目不是"用了删减版 OS"，而是"同结构的更少实例"——一个 2 小时 bugfix 仍走同一套骨架，只是 ticket=1、不写 spec。
- **与项目大小无关**：fractal。大项目和小项目同形，区别只在实例数量。

> 为什么不是极简内核：极简内核会让人每次重新判断"这个项目要不要上 X"，判断成本本身就是熵。强默认把判断前移到模板里，项目里只做"要不要关"的减法决策——减法比加法安全。

---

## 1. 文件地图

```
project-os/                      ← scaffold（每 gig cp 一份，per-project 内容；机器层在 plugin）
├── README.md                    ← 本文件：哲学 / 占位符约定 / 实例化步骤 / 流水线总览
├── PROJECT.md                   ★单一变量源（SSOT of vars）：所有实例特定值只在这里声明一次
├── CLAUDE.md                    项目决策层引导（强约束 / 每日工作流 / 派单原则）
├── .claude/
│   ├── settings.json            权限护栏（deny 框架底座 / allow 业务子树）—— 仅权限，hooks 在 plugin
│   ├── rules/                   path-scoped 规则（如 ruoyi.md，碰对应栈文件才加载）
│   └── verify-cmd.example       type/lint gate 命令模板（cp 成 verify-cmd 启用，慢栈留空=关）
├── doc/
│   ├── authority/               ★SP1 三件 SSOT 落地处（schema / 组件+token+截图 / 验收 checkbox）
│   └── _adr/                    架构决策记录 + "何时引用"决策表
├── daily/                       SP1b 每日任务 + SP2 验证（prompt / testing / closing audit），项目根级，与 doc/ 平级
├── STAGE2-verify-BACKLOG.md     ★SP2 验证骨干（待建清单，指向 design doc §4）
├── STAGE3-reflux-BACKLOG.md     ★SP3 反哺→再生（待建清单，指向 design doc §4 + §1）
└── stacks/
    └── ruoyi-notes.md           按栈插件示例：RuoYi/Java/uni-app 专属机制（可选，按栈替换）
```

> **通用机制 vs 按栈插件**：模板正文（CLAUDE.md / doc / authority）只写**与栈无关的工程机制**（"冻结 schema 并在 CI 检测漂移""真截图锚定视觉""每 ticket 机器可验收"）。某个栈怎么落地（RuoYi 用 DDL+MyBatis generator、Next+FastAPI 用 Prisma 或 OpenAPI+Zod；视觉锚定 web 用 Figma Code Connect、小程序用微信开发者工具 CLI 截图）放进 `stacks/<stack>-notes.md`。换栈 = 换插件，不动正文。

---

## 2. 占位符约定（CANONICAL，全表）

所有实例特定值用 **全大写双尖括号** token。模板里出现的就是 `<<TOKEN>>`，实例化时全局替换。

| Token | 含义 | 示例填值 |
|---|---|---|
| `<<PROJECT_NAME>>` | 项目代号 | dongjiaoshan |
| `<<PROJECT_PATH>>` | 项目绝对路径 | `/Users/wkui/Project/profile/project/freelance/projects/dongjiaoshan` |
| `<<TEAM_MODEL>>` | 团队模型 | Kevin 派单+终审 / 3 全栈 review+测试 / AI 全写 |
| `<<STACK_BACKEND>>` | 后端栈 | RuoYi-Vue-Plus (Java/Spring) |
| `<<STACK_FRONTEND>>` | 管理端前端栈 | plus-ui (Vue3 + ElementPlus) |
| `<<STACK_APP>>` | 移动端/小程序栈 | uni-app + wot-design-uni |
| `<<DB>>` | 数据库 | MySQL 8 + Redis |
| `<<FRAMEWORK_BASE_PATHS>>` | 第三方框架底座源码目录（settings.json **deny** 写） | `ruoyi-common/**`、`ruoyi-modules/ruoyi-{system,generator,job,workflow}/**` |
| `<<BUSINESS_MODULE_PATHS>>` | 业务代码子树（settings.json **allow** 写） | `ruoyi-modules/ruoyi-<biz>-*/**`、`plus-ui/src/views/**` |
| `<<DOMAINS>>` | 业务域列表 | 域A / 域B / 域C / 域D / 域E |
| `<<MIGRATION_DIR>>` | 迁移目录 | `ruoyi-admin/src/main/resources/db/migration/` |
| `<<ID_NAMING>>` | ID / 编号 / 菜单段命名规则 | menu_id 按域分段 + 业务编号规则（详见栈插件） |
| `<<ENUM_DICT_REF>>` | 字典 / enum 权威源 | `doc/authority/` 冻结 schema 的字典段 |

### 反漂移铁律：单一变量源

- **所有实例特定值只在 `PROJECT.md` 声明一次**。
- 其他文件（CLAUDE.md / doc / authority / backlog）**引用概念，不重新声明值**。需要具体路径时写"见 PROJECT.md 的 `<<BUSINESS_MODULE_PATHS>>`"，不复制粘贴一份路径。
- 例外：`.claude/settings.json` 因为是机器读的 JSON 无法引用概念，必须填实际路径——它是唯一允许"展开变量值"的文件，且只展开 `<<FRAMEWORK_BASE_PATHS>>` / `<<BUSINESS_MODULE_PATHS>>` 两个。
- 好处：客户改需求 / 加一个域，只改 PROJECT.md 一处，全 OS 的概念引用自动指向新值，不会出现"A 文件说 5 域 B 文件说 6 域"的漂移。

---

## 3. 实例化步骤（scaffold cp + plugin install）

> 📖 **完整人面向 runbook（含判断要不要上、三段你每段干嘛、新机制速查）见上级 [`../README.md`](../README.md)**。本节是 in-template 快速命令参考。

> **架构**：本目录是 **scaffold**（per-project，cp 一份，本就该 diverge）。机器层（agents / commands / hooks）在 **project-os plugin**，经 agent-lab 的 local marketplace 安装——机器层更新 `/plugin update` 自动传播到所有 gig，**不再靠手动同步副本**（消除机器层 drift；这是 plugin 化的核心收益）。

```bash
# 1. 建项目目录
NEW=/Users/wkui/Project/profile/project/freelance/projects/<name>
mkdir -p "$NEW"

# 2. 拷 scaffold（per-project 部分，含隐藏的 .claude/）
cp -R /Users/wkui/Project/profile/project/agent-lab/templates/project-os/. "$NEW"/

# 3. 装 project-os plugin（机器层）——在项目内起 Claude Code 后执行一次：
#      /plugin marketplace add /Users/wkui/Project/profile/project/agent-lab
#      /plugin install project-os@agent-lab
#    机器层有更新时：/plugin marketplace update agent-lab && /plugin update project-os@agent-lab

# 4. 填 PROJECT.md（单一变量源）——每个 <<TOKEN>> 的实际值只在这里写一次
$EDITOR "$NEW"/PROJECT.md

# 5. 展开 settings.json 两个路径变量（<<FRAMEWORK_BASE_PATHS>> / <<BUSINESS_MODULE_PATHS>>）

# 6. 选栈：留 stacks/<你的栈>-notes.md + .claude/rules/<栈>.md，删不相关的（没现成→照 ruoyi 结构新建）
#    启用 type/lint gate（快栈）：cp .claude/verify-cmd.example .claude/verify-cmd 并填命令；慢栈留空=关

# 7. 起 Claude Code（cwd=项目根，CLAUDE.md 自动加载）→ 进 SP1 接料
```

> **机器层 vs scaffold 的 drift 边界**：plugin（机器）更新自动传播，drift 被消除；scaffold（PROJECT.md / doc / daily）每项目本就不同，diverge 是预期，项目结束时把**通用机制**回写 templates（plugin 或 scaffold 源），栈特定教训进 stacks。

---

## 4. tier 仅作心智参考（不自动触发）

项目可粗分三档心智模型，**仅用于人判断"这次要不要关掉某些可选件"**：

| tier | 形态 | 走多少 OS |
|---|---|---|
| 大型核心业务 | 多域 / 多 ticket / 长周期 | 全套 SP1（三件 SSOT）+ SP2 全验证 + SP3 反哺 |
| 中型功能 | 单域 / 数 ticket | SP1 轻量（schema + 验收 checkbox，组件锚定按需）|
| 2 小时级 bugfix / 机械改 | 单 ticket | **不写 spec**：直接给 task + 权威 context（避免 SDD 维护税）|

**强约束（Kevin anti-bloat）**：**不要**建任何"自动按规模判 tier 并触发不同流程"的机器。tier 是人脑里的标签，不是代码里的开关。判断"要不要关 X"是人当场拍板的减法决策，不需要 OS 替你判。任何"tier-auto-trigger 引擎"都是过度工程，禁止建。

---

## 5. 三段流水线总览

```
甲方资料(xlsx/原型/SRS/聊天/录音)
   │
   ▼
┌─ Stage1 (SP1)  接料 → 设计 ────────────────────────────────────────┐
│  Step0 接料加锁:origin/ 只读 + snapshot 存 md5(偷改触发 CR)          │
│  Step1 需求澄清:跨域列疑点 P0/P1/P2 + 机器可勾选 → 答 P0 → 拆解冻结 + OQ │
│  Step2 架构 + 全局资源台账:ADR(先决策后 prompt) + enum/字典/ID/编号定权威 │
│  Step3 ★三件 SSOT 落地(doc/authority/):                               │
│     ① 冻结 schema(enum/字典/ID/表结构) — CI 漂移即报错                 │
│     ② 共享组件清单 + design token + 真截图锚定(designer 上场)          │
│     ③ ticket 全集 + 每 ticket 机器可验收 checkbox(含验收 SQL)         │
│  ★GATE:三件 SSOT 齐 + 验收可机器验 → 才准进 SP1b                       │
│  SP1b 每日任务生成:从 SSOT + 依赖图切 D<N>(按文件/模块边界保证可并行)    │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌─ Stage2 (SP2)  执行 → 验证 ──────────────────────────────────────┐
│  AI 写代码(每 ticket 三段式 §0 自检 / 主任务 / §N 总结)              │
│  验证骨干(详见 STAGE2-verify-BACKLOG.md):                          │
│   type/lint 硬 gate + hook 即时反馈 → 前置验收测试 → 运行时 smoke    │
│   → 视觉自检环(真截图 diff) → 异构 fresh-context 预审               │
│   → security review(一等公民) → review 带宽实测 + 并发上限 + token 看板 │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌─ Stage3 (SP3)  反哺 → 再生 ──────────────────────────────────────┐
│  每日 closing 事件驱动沉淀:一行 learnings + skill 候选(不靠周巡)     │
│  详见 STAGE3-reflux-BACKLOG.md:蒸馏 hook 当场触发 / 项目结束一次性   │
│  反哺经验池 / 通用机制回写模板(漂移在此收敛) / skill 事件驱动+人拍板  │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
                  模板升级 → 下个项目 cp 时已自带本次教训
```

**三痛各对一机制**：ceremony → 决策层瘦身（砍项目用不上的 domain）；output-quality → 验证骨干 + 三件 SSOT；learning-loop → 事件驱动沉淀 + 项目结束反哺。
