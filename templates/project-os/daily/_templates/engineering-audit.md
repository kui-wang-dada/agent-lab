# 日终工程 Audit 模板（closing 时跑）

> **何时跑**：每天 closing 流程最后一步（ticket 全 ✅ + testing 全 ✅ + 已 commit、**未 merge** 集成分支之前）。merge 前最后一道关。
> **谁跑**：AI 主任务方一键扫全部维度 → 写 `D<N>/audit-report.md`；人做决策；当晚批量改。
> **目的**：保证当日新写/改的代码 / 迁移 / doc 与全局规范保持一致，让工程越来越干净，方便项目结束反哺模板。
>
> **维度可移植性（核心）**：
> - **通用维度（A 中间态 / C 工程约束 / E 产物完整 / F 流程对齐 / J doc-prompt 漂移）= generic**，搬到任何项目直接复用，下面的 grep 已写成栈无关或占位形。
> - **栈特定维度（B schema·迁移 / D 框架特性 / G 工程事实术语 / H 数字对账）按栈填真值** —— 真值与命令去 `stacks/<<本栈>>-notes.md` 取，本模板只留"该查什么 + 为什么"。
>
> **占位**：`<<...>>` 真值在 `PROJECT.md`；本模板引用概念。`<本日目录>` = 当天 daily 目录。

---

## 0. 触发条件（跑之前确认）

- [ ] 本日 ticket 全部 ✅ 已 closing（`reports/` 全在、`_open-issues.md` 全决策完，无 ⏳）
- [ ] `testing-ai.md` / `testing-human.md`（如有）全 ✅
- [ ] 全部代码已 commit 到集成分支，但**未 merge**（merge 前最后一道关）

---

## 1. 扫维度

每条都给 `file:line` + 实际文本片段。AI 一次性跑完全部检查 + 输出 markdown 报告，人决策后再批量改。

---

### A. 中间态污染（最严重 · generic）

新写的 doc / 迁移 / 代码里**不应留中间态**——要么是最终态，要么删掉：
- "曾经是 X，改成 Y" / "决策日期" / "类型 X 由 Y 改 Z" 字样
- 跨文件的变更编号引用（变更号只在 ADR / 变更记录文件的历史段保留）
- markdown `~~删除线~~` 内容（要么留要么删）
- `// 旧版本` / `// removed` / `// 原来的写法` / 注释掉的代码块

```bash
# A.1 中间态文本
grep -rn --include="*.md" -E "决策日期|曾经是|由 .* 改(成)?|原来是" <<BUSINESS_MODULE_PATHS>> .claude/ doc/
# A.2 跨文件变更编号引用（排除 ADR + 变更记录合法位置）
grep -rn --include="*.md" -E "CR-[0-9]{6,8}|变更号|详 CR-" doc/ .claude/ | grep -v "_adr/\|changes.md"
# A.3 markdown 删除线
grep -rn --include="*.md" -E "~~[^~]+~~" doc/ .claude/
# A.4 代码里的"旧版本注释"
grep -rn --include="*.<<STACK_BACKEND 主扩展名>>" --include="*.ts" --include="*.vue" -E "// 旧版本|// removed|// 原来的写法|/\* 旧" <<BUSINESS_MODULE_PATHS>>
```

---

### B. schema / 迁移一致性（按栈填真值）

> **为什么**：复盘头号返工源是"schema 撞墙 + 字段列类型错"。新建/改迁移时必须对照冻结 schema SSOT（`doc/authority/schema-ssot.md`）。
> **栈填**：把"必含字段 / 类型约定 / 表·实体命名前缀 / 迁移版本规则"按 `<<STACK_BACKEND>>` + `<<DB>>` 填，命令去 `stacks/<<本栈>>-notes.md` §audit-schema。

检查（占位，栈实例化时替换真值）：
- 业务表/实体必含的公共列（多租户 `tenant_id` / 软删 / 审计字段）类型与基类对齐 —— `<<填本栈公共列约定>>`
- 表/实体命名落在本业务域前缀（`<<DOMAINS>>` 对应前缀），**不是**旧前缀
- 若 doc 提到具体表数 → 与当前真值对齐（见 H 段）

```bash
# B.x 旧前缀 / 错误公共列类型残留（栈实例化时按 stacks/ruoyi-notes.md 等填具体 grep）
# grep -rn --include="*.md" --include="*.sql" -E "<<旧前缀正则>>|<<公共列错误类型正则>>" doc/ <<BUSINESS_MODULE_PATHS>>
```

---

### C. 工程约束（DB / 框架硬约束 · generic 形式，真值按栈）

> 通用机制：某些"框架 + DB 版本"组合有硬约束（如某 DB 版本不支持的 DDL 特性、ORM 特定写法），doc/迁移里不应残留错误方案，应指向正确方案（通常记在某条 ADR）。
> **栈填**：把具体的约束（如"某 generated 列写法不被支持，改为应用层填充"）按 `<<DB>>` + `<<STACK_BACKEND>>` 填，参 `stacks/<<本栈>>-notes.md` §audit-constraint。

```bash
# C.x 检测被禁的 DDL/ORM 写法残留（栈实例化时填）— 应 0 命中
# grep -rn --include="*.md" --include="*.sql" -E "<<被禁写法正则>>" doc/ <<BUSINESS_MODULE_PATHS>>
```

---

### D. 框架特性 / 蓝图混淆（按栈填）

> 通用机制：某能力有"当前实现版本"与"未来蓝图版本"（如鉴权、对象存储、支付），蓝图关键字只该出现在对应 ADR，混进主实现 doc/prompt = bug。
> **栈填**：列出本项目"有版本分叉的能力"+ 各自关键字，参 `stacks/<<本栈>>-notes.md` §audit-feature。

```bash
# D.x 蓝图关键字泄漏进主实现（栈实例化时填）= bug
# grep -rn --include="*.md" -E "<<蓝图关键字正则>>" doc/ | grep -v "<<蓝图所在 ADR 路径>>"
```

---

### E. 工程产物完整性（generic）

每个 ticket 完工后必有：
- [ ] `reports/<TICKET-ID>.md`（per-ticket 报告，AI 写，含 §0/§0.5 自检行 + PR Contract）
- [ ] `_open-issues.md` 里本 ticket raise 全部决策（✅/❌，不留 ⏳）
- [ ] 写代码的 ticket：迁移文件落 `<<MIGRATION_DIR>>`（如有 schema 变更）
- [ ] 单测至少 1 个 happy path

```bash
# E.1 当日 reports 数量 ≈ ticket 数
ls <本日目录>/reports/ | wc -l
grep -cE "^\| [A-Z]+-[A-Z]+-[0-9]+ " <本日目录>/README.md

# E.2 _open-issues 里没有遗留 ⏳
grep -n "状态.*⏳" <本日目录>/_open-issues.md

# E.3 reports raw-output 覆盖反向校验（治 Verification Gap）
#   依据：复盘里约 70% 报告 raw output 覆盖不足 = 翻车前兆。每份 report 自测段应 ≥ 3 个 code-block。
for f in <本日目录>/reports/*.md; do n=$(grep -cE '^```' "$f"); echo "$((n/2)) blocks  $f"; done
#   block 数 < 3 的报告 → 不合格，打回让对应 ticket 补 raw output

# E.4 PR Contract 段存在性（每份 report 应有"PR Contract"段，点名 reviewer 看哪块）
grep -Lc "PR Contract" <本日目录>/reports/*.md

# E.5 感官测试编号一致性（人感官测试 testing-human.md 的全局编号 / 精简）
#   根因：N 个 ticket agent 各自 append，没人把拼出来的重排成连续编号 → 每段从 1 重数 / 散文化 / 超长。
#   不是检测完就算，不达标必须当场单人重排（见下"修复动作"）。
HUMAN=<本日目录>/testing-human.md
echo "§N 段数（应 ≈ ticket 数）:"; grep -cE "^## §[0-9]" $HUMAN
echo "重复 N.M 编号（应 0）:"; grep -oE "^\| *[0-9]+\.[0-9]+ " $HUMAN | sort | uniq -d
echo "散文式裸编号红旗（应 0）:"; grep -cE "^\| *[0-9]+ \|" $HUMAN; grep -cE "^[0-9]+\. " $HUMAN
echo "行数（≤200 基准；超 250=没精简）:"; wc -l < $HUMAN
echo "技术黑话泄漏（应 0）:"; grep -niE "<<本栈技术黑话正则,见 stacks/>>" $HUMAN | head
```

**E.5 修复动作（不达标 = 任一红旗）**：closing **必跑一次 testing-human 单人汇编重排**（一个人/一个 pass 从头扫，不是让各 ticket agent 各自补）：
1. 段头统一 `## §N <TICKET>`，N = README 当日清单行序；条目 `N.1/N.2...` 全局唯一不重数。
2. 每段 `| 编号 | 测试点 |`，每条压成一行大白话；删每段重复的登录注释（通用规则只在 §0 说一次）。
3. 删技术黑话（grep 命中的词换成测试员看得见的控件名）；超 13 项的段拆/合并、超 250 行整体收紧。
4. 重排完再跑一遍 E.5 grep，§N 段数=ticket 数、重复编号 0、裸编号红旗 0 才算 ✅。

---

### F. 流程 / 模板一致性（generic）

> daily 文件（`D<N>/*.md`）和模板（`_templates/*.md`）必须跟当前流程对齐——流程改了，文档别还引用旧步骤/旧分支策略。

```bash
# F.1 daily 文件还在用旧流程措辞 / 旧分支名（项目实例化时把"旧措辞"按 stacks/ 填）
grep -rn --include="*.md" -E "<<旧流程/旧分支措辞正则>>" <本日目录>/ .claude/
# F.2 模板引用的产物路径与实际目录结构一致
ls <本日目录>/ | sort
# F.3 模板里"参考路径"不指向已删文件（命中后手工 stat 验存在）
grep -rn --include="*.md" -E "参考 .+\.(<<STACK_BACKEND 扩展名>>|vue|ts|sql)" _templates/ | head -30
```

---

### G. 旧术语 / 工程事实错位（按栈填真值表）

> 通用机制：doc/代码注释/prompt 里的"工程事实"（分支命名、包/模块路径、框架真实类名、构建脚本名）容易写错或过时。
> **栈填**：实例化时把下表"旧（应清）→ 新（真值）"按 `<<STACK_BACKEND>>`/`<<STACK_FRONTEND>>` 真实情况填，参 `stacks/<<本栈>>-notes.md` §audit-fact。

| 旧（应清） | 新（真值，栈填） |
|---|---|
| `<<错误分支措辞>>` | `<按 <<TEAM_MODEL>> 分支策略，见 daily/README.md>` |
| `<<错误模块/包路径>>` | `<<BUSINESS_MODULE_PATHS>> 下真实路径` |
| `<<框架虚构类名>>` | `<框架真实类名>` |
| `<<错误构建/lint 脚本名>>` | `<本栈真实脚本名>` |

```bash
# G.x（栈实例化时按上表填具体 grep）
# grep -rn --include="*.md" -E "<<旧术语正则>>" doc/ .claude/ <<BUSINESS_MODULE_PATHS>>
```

---

### H. 数字对账（按栈/业务填真值）

> 通用机制：doc 里散落的"具体数字"（业务表数 / 字典数 / 角色数 / 菜单数 / ticket 数）容易跟实际漂移。把当前真值填进表，grep 旧数字应得 0。
> **真值刷新约定**：每次 closing 跑 audit 时，用实测 query（栈特定，见 `stacks/<<本栈>>-notes.md` §audit-count）刷新"真值"列，旧值挪到"应清"列。**历史叙述段**（"某 ticket 当时建了 N 张表"）是实施事实，不动；本表只跟踪累积扩展。

| 维度 | 真值（当前，实测填） | 旧数字（应清） |
|---|---|---|
| 业务表 / 实体数 | `<实测>` | `<历史旧值列表>` |
| 枚举 / 字典类数 | `<实测>` | `<...>` |
| 字典数据条数 | `<实测>` | `<...>` |
| 角色数 | `<实测>` | `<...>` |
| ticket 总数 | `<<本项目 ticket 全集数>>` | `<历史旧值>` |

```bash
# H.x 数字对账（按真值改 grep）
# grep -rn --include="*.md" -E "<<旧数字正则,如 52 张表|30 类字典>>" doc/
```

---

### I. 运行时 / 启动期 / nil 兼容（按栈填）

> 通用机制：启动期 / 登录前 / 空数据路径有"过早调用"风险（鉴权时序、空集合、解析器黑名单、消费方旧范式、mock 用户没 seed）。
> **栈填**：`<<STACK_APP>>` / `<<STACK_FRONTEND>>` 的具体检查（哪些端点登录前调必须放行、消费方旧范式会整页空白、`<<STACK_APP>>` 样式/编译期黑名单等）去 `stacks/<<本栈>>-notes.md` §audit-runtime；本段在通用 audit 里只留"提醒该查"。

```bash
# I.x（栈实例化时按 stacks/ 填具体 grep；web 栈与 app 栈检查项不同）
```

---

### J. doc-prompt 漂移防御（generic —— 治 SP1→SP2 齿轮错位）

> prompt 主体描述的"数据模型/默认数据/字段名"与 `doc/authority/schema-ssot.md` SSOT + 实际库不一致 → AI 按 prompt 字面建错 → 跟下游对不上。**SSOT 是权威，prompt 落后就忽略 prompt。**

```bash
# J.1 prompt 模板 / 当日 prompt 里残留"人日/工期"估算（违反单一估时权威源，见 daily/README.md）
grep -rn --include="*.md" -E "人日|工期|预计.*小时|预计.*天|deadline" _templates/ <本日目录>/prompts/

# J.2 当日 prompt 主体 + doc/authority/schema-ssot.md 同 ticket 段，关键字段名/表名对账（手工 review）
#   操作：每个 ticket prompt spawn 前，AI §0 自检同时对账 → 命中差异以 SSOT + 库为准，prompt 落后忽略，append _open-issues.md

# J.3 prompt 模板"参考路径"不指向已删文件
grep -rn --include="*.md" -E "参考 .+/.+\.(\w+)" _templates/ | head -30  # 命中后手工 stat
```

---

## 2. 输出报告

把全部检查结果按维度分类写进 `<本日目录>/audit-report.md`，每条标：`file:line` 实际文本 / 严重度（A·C > D > B·G·H > F·I·J）/ 建议操作（修 / 保留 / 拒绝）。

```markdown
## D<N> 工程 Audit 报告
### A. 中间态污染（N 处）
- [doc/...md:174](...) "<片段>" — 建议删后半句
### B. schema/迁移（0 处）✅
### E.3 reports raw-output 覆盖
- D<N>/reports/<X>.md 仅 1 block — 打回补 raw output
### H. 数字对账（1 处）
- [<本日目录>/README.md:7](...) "<旧数字>" — 应 "<真值>"
```

---

## 3. 决策 + 批量改

人看报告，每条决策：**修**（当晚批量改，每改一类立即 `grep -rn` 验 0 残留）/ **保留**（标 ⏸ + 理由，防下次重提）/ **拒绝**（标 ❌，规则误判）。

改完跑全栈健康（具体脚本见 `stacks/<<本栈>>-notes.md` §health）：be 编译 + fe 构建都 ✅ → 才 merge。

---

## 4. 反哺模板（项目结束时）

本 audit 的**通用维度（A/C/E/F/J）**在项目结束时回写 `agent-lab/templates/project-os/`（漂移在此收敛）；**栈特定维度（B/D/G/H/I 的真值表 + grep）**沉淀进对应 `stacks/<<本栈>>-notes.md`。下个项目 cp 模板时已自带本次教训。
