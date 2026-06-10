# 开新项目 Runbook —— project-os 工程实践操作手册

> 这是**人面向**的操作手册：Kevin 接一个新 freelance 项目时，从零到跑起来该怎么操作。
> 机制原理在各处文档，本文只讲"按什么顺序做什么"。配套：[`project-os/README.md`](project-os/README.md)（占位符全表 + 流水线细节）、[`project-os/.claude/CLAUDE.md`](project-os/.claude/CLAUDE.md)（项目宪法）。

---

## 0. 先理解两层模型（一分钟）

project-os 拆成两块，各自的更新方式不同：

| 层 | 是什么 | 在哪 | 怎么进新项目 | 更新方式 |
|---|---|---|---|---|
| **scaffold（副本）** | per-project 内容：PROJECT.md / CLAUDE.md / doc/ / daily/ / 栈规则 | `templates/project-os/` | `cp` 一份进项目 | 每项目本就不同，diverge 是预期 |
| **plugin（机器）** | 通用机器：5 个 agent / `/parallel-day` `/integrate-day` / hooks | `templates/project-os-plugin/` | 经 marketplace `/plugin install` | 改源 → `/plugin update` **自动传播到所有项目** |

> 为什么这么拆：机器层（agent/hook/命令）以前 cp 进每个项目会各自 drift，改一处要手动同步 N 份。改成 plugin 后机器层只有一份源、自动传播；副本只剩"本就该不同"的项目内容。**这是 2026-06-09 优化的核心。**

---

## 1. 第一步：判断要不要上全套（人脑拍板，不是机器判）

| 项目形态 | 走多少 OS |
|---|---|
| 大型核心业务（多域 / 多 ticket / 长周期，如 dongjiaoshan） | **全套**：SP1 三件 SSOT + SP2 全验证 + SP3 反哺 |
| 中型功能（单域 / 数 ticket） | SP1 轻量（schema + 验收 checkbox，组件锚定按需） |
| 2 小时级 bugfix / 机械改 | **不写 spec**：直接给 task + 权威 context，但仍走同一结构（ticket=1） |

> **红线**：tier 是你心里的标签，**不要建"按规模自动判 tier 触发流程"的机器**。判断"这次关掉哪些可选件"是你当场的减法决策。强默认 ON，你按需关。

---

## 2. 开项目五步（10 分钟搭好骨架）

```bash
# ── 1) 建项目目录 ────────────────────────────────────────────
NEW=/Users/wkui/Project/profile/project/freelance/projects/<项目名>
mkdir -p "$NEW"

# ── 2) 拷 scaffold（含隐藏 .claude/）────────────────────────
cp -R /Users/wkui/Project/profile/project/agent-lab/templates/project-os/. "$NEW"/

# ── 3) 起 Claude Code（cwd = 项目根）后，装机器层 plugin（一次性）──
#     在项目内的 Claude Code 里执行：
#       /plugin marketplace add /Users/wkui/Project/profile/project/agent-lab
#       /plugin install project-os@agent-lab
#     之后机器层有更新：/plugin marketplace update agent-lab && /plugin update project-os@agent-lab
```

```
# ── 4) 填 PROJECT.md（★单一变量源，最关键一步）──────────────
#   把每个 <<TOKEN>> 的真值只在这里写一次（占位符全表见 project-os/README.md §2）：
#   项目名 / 路径 / 团队模型 / 栈（后端·前端·App·DB）/ 业务域 / 迁移目录 / ID命名 / 字典权威源
#   还要展开 .claude/settings.json 里两个路径变量（机器读的 JSON，唯一允许填实际路径处）：
#     <<FRAMEWORK_BASE_PATHS>>（deny 写：第三方框架底座）
#     <<BUSINESS_MODULE_PATHS>>（allow 写：业务子树）

# ── 5) 选栈 + 开 gate ───────────────────────────────────────
#   留 stacks/<你的栈>-notes.md + .claude/rules/<你的栈>.md，删不相关的（没现成→照 ruoyi 结构新建）
#   快栈（TS/Vue/Python）开 type/lint 硬 gate：
#     cp .claude/verify-cmd.example .claude/verify-cmd  然后填校验命令（如 pnpm vue-tsc --noEmit）
#   慢栈（mvn compile 慢）留空 verify-cmd = 关，降级为 closing 时一次性扫
```

搭完，起 Claude Code（cwd = 项目根，CLAUDE.md 自动加载）→ 进 SP1。

---

## 3. 跑起来之后：三段流水线你每段干什么

### SP1 接料 → 设计（产出三件机器可验的 SSOT）
1. **接料加锁**：甲方原型/Excel/SRS 放 `doc/origin/` 只读 + snapshot md5（偷改触发 CR）。
2. **需求澄清**：跨域列疑点 P0/P1/P2 → 答 P0 → 拆解冻结，开放问题进 `doc/_oq.md`（每条带 Fallback）。
3. **架构 + 台账**：先写 ADR（`doc/_adr/`，先决策后 prompt）+ 把 enum/字典/ID/编号定权威。
4. **★三件 SSOT 落地**（`doc/authority/`）：① 冻结 schema ② 共享组件+token+**真截图锚定**（`@designer` 上场）③ ticket 全集 + 每 ticket 机器可验收 checkbox（含验收 SQL）。
5. **★GATE**：三件齐 + 验收可机器验，**才准**进 SP2。从 SSOT + 依赖图切 `daily/D<N>/`（保证可并行）。

### SP2 执行 → 验证（每天 6 步日循环）

一天的内核都是同一套 6 步：切 `feature/day<N>` → 复制 `daily/D<N>/prompts/<ticket>.md` spawn AI → 三段式（§0 自检 / 主任务 / §N 完工报告）→ testing-ai 跑机器验证 → testing-human → closing audit → 完善次日 → 事件驱动沉淀。

**怎么触发执行 —— 三档，你按当天状态挑（不自动调度）：**

| 档 | 怎么说 / 命令 | 跑几天 | 你的 review/merge 落在哪 | 什么时候用 |
|---|---|---|---|---|
| **1. 单个执行** | 「执行 D1」或 `/run-day 1` | 一天，当前会话 | 当天 closing 后你看 summary 决定 merge | 要稳、想盯一天；或只剩一天 |
| **2. 并行执行** | 「并行执行 D1 D2 D3」→ 开 3 窗口各 `/parallel-day 1`/`2`/`3` | 标 `独立` 的几天同时跑 | 攒一批写完一起测 → `/integrate-day 1 2 3` 合 | 几天彼此独立 + 当天有余力 |
| **3. 串行执行** | 「串行执行 D1-D10」或 `/serial-day 1-10` | 依赖的多天一个会话链式跑完 | **挪到全部跑完的末尾**批量厚验收 | 多天依赖、想基本无人值守 |

- **单个**：最稳，人 review 卡在每天。`/parallel-day` 把"并行"自动化（worktree 隔离 + 不手敲 git），`/integrate-day` 依次合并。
- **串行（这轮新增）**：`/serial-day 1-10` 在一条集成分支上链式跑——每 ticket 真绿 gate（防假绿）+ 关键决策落 `progress.md` + **天边界自动对照 `doc/origin/` 原型对齐** + **只在真卡住（`BLOCKED`）才熔断**，全部跑完才回归 + 对抗式 workflow 批量验。人只在末尾 review+merge，**不自动 merge 到 dev**。
  - **它把判断从逐天 review 前移、压在 SP1 质量上**：basically 无人值守地跑，靠的是 ticket spec 清楚到 fresh-context subagent 不用问就能执行。所以**前提是 SP1 三件 SSOT 齐 + prompt 已细化**（缺则命令直接 STOP，不硬跑）。
  - **熔断率 = SP1 质量体温计**：串行老在中途停 = SP1 没梳透的信号，回去补 SP1，别在 SP2 打补丁。
- **三档共用约束**：`review 带宽是吞吐天花板`，未实测前并发保守；都不手敲 git、不 force push。高风险/核心天可跑对抗式验证（见 §4），三档末尾都建议过一遍。

### SP3 反哺 → 再生（让下次接活更高效）
- **每天 closing**：AI 当场沉一行 learnings + skill 候选。**分层自治**：失败护栏/stack 经验/事实可当场落（事后 `git revert` 可否决）；新 skill/改机器出候选 → 你拍板。
- **项目结束一次性反哺**：见 §5。

---

## 4. 这轮新增的 4 个机制 —— 何时会碰到

| 机制 | 是什么 | 你什么时候碰 |
|---|---|---|
| **`.claude/rules/<栈>.md`** | path-scoped 规则，碰对应栈文件才自动加载（如 `ruoyi.md`） | 选栈时留对应那份；写业务代码时它自动生效，不用手动读 |
| **type/lint 硬 gate**（`.claude/verify-cmd`） | 每次 turn 结束跑校验，失败 block 喂回 AI 自己修 | 快栈开（填 verify-cmd）；慢栈关（留空） |
| **对抗式验证 workflow** | fresh-context 审查者逐条 refute 完工 ticket 的验收 checkbox | 高风险/核心 ticket 那天：`Workflow({scriptPath:'.claude/workflows/verify-tickets.js', args:{day:N}})` 或说"用 workflow 验证 DN 完工 ticket"。**只验证，你仍 commit** |
| **经验回流引擎**（hook + curator 周巡） | hook 给操作打 `signal`，周巡分层沉淀：低风险自动落+digest 供否决，高风险出候选 | 不用主动碰；每周看 `agent-lab/.claude/memory/_weekly/<周>-digest.md` 否决不想要的自动沉淀 |

---

## 5. 项目结束：反哺去哪（漂移在此收敛）

`@curator` 跑一次项目末反哺，按归属分流（**回写动作你拍板**）：

- **机器层改进**（agent prompt / 命令 / hook）→ 回写 `agent-lab/templates/project-os-plugin/`，`/plugin update` 传播。**高风险，必拍板**。
- **scaffold 通用机制**（doc 模板 / daily 模板 / 新 §0 自检项）→ 回写 `agent-lab/templates/project-os/`。
- **栈特定教训** → 回写 `stacks/<栈>-notes.md` 或 `.claude/rules/<栈>.md`（栈经验属低风险，可当场落）。
- **跨项目可复用经验** → 合并进 `agent-lab/.claude/memory/` 经验池。

> 机器层 drift 已被 plugin 消除（不用手动 diff）；只需核对 scaffold 部分（doc/ daily/ rules/ CLAUDE.md）与 templates 源的 delta。

---

## 6. 边界 / 已踩过的坑

- **§0 自检不可省**：挡住过漏建表/字段类型错/分支切错，30s-2min 挡几小时返工。派单别催 AI 跳过。
- **不要"一个 bug 一个 skill"**：落地优先级 SSOT(~60%) > prompt 模板(~30%) > doc/ADR(~10%) > skill(≤10%，横跨 ≥3 ticket 才考虑)。
- **不要砍成"极简内核 + 按需加"**：强默认 + 可关，小项目是"同结构更少实例"不是"删减版"。
- **designer 是 SP1 上游一等公民**：视觉用真截图锚定，不能用字段表（dongjiaoshan 视觉偏差根因）。
- **不在 agent-lab 直接动其他项目代码**：只读不写；本项目内才写业务代码（settings.json deny/allow 兜底）。
