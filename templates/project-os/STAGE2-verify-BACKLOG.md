# Stage2 (SP2) — 执行 → 验证骨干 · BACKLOG

> ⚠️ **设计未详化**：本文件是**待建清单**，不是已落地的机制。SP2 在 design doc 里仍是后续 sub-project（见 §4 后续待办）。下面每条 = 一句话目标 + 关掉条件 + 指向 design doc。
>
> **权威依据**：`agent-lab/docs/superpowers/specs/2026-06-03-human-ai-engineering-os-design.md` §4（SP2 执行→验证骨干）+ §2.2/§2.3（瓶颈已从"写代码"转到"验证 + review 带宽 + 业务判断"；review 带宽是吞吐天花板）。
>
> **总命门**（design doc §2.3）：市场蓝图假设"N 个专职 Verifier"，<<TEAM_MODEL>> 实际是少数全栈。**review 带宽是吞吐天花板，3-5 并行很可能偏高**——所以本骨干所有"并发""自动验证"项，都要先实测带宽再定量，禁止照搬市场数字。

---

## 待建清单

### 1. type/lint 硬 gate + hook 即时反馈 — ✅ 已落地（2026-06-09）
**目标**：每次写完代码，type check + lint 作为**硬门槛**当场跑，失败即拦——不留到 closing 才发现。用 hook（PostToolUse / Stop）即时反馈给 AI，闭环在 AI 自己手里修。
**实现**：project-os plugin 的 `hooks/stop-gate.sh`（同步 Stop hook，plugin `hooks/hooks.json` 声明）。读项目本地 `.claude/verify-cmd`（一行=校验命令）→ 非零退出返回 `{"decision":"block","reason":<截断输出>}`，AI 当场修闭环。gate 拦下的失败也进 review-queue 标 `signal:"failure"`，喂经验回流引擎。
**关掉条件（强默认+可关）**：`.claude/verify-cmd` 缺/空 = 关（慢栈如 mvn compile 默认走这条，降级 closing audit）。启用见 `.claude/verify-cmd.example`（快栈 tsc/vue-tsc/ruff 建议开）。
→ design doc §4「前置 type/lint 硬 gate + hook 即时反馈」。

### 2. 前置验收测试（治 Verification Gap）
**目标**：ticket 实现**之前**，先把"机器可验收 checkbox"（来自 SP1 三件 SSOT 第③件，含验收 SQL）变成可执行断言。先有验收契约，再写实现——根治 dongjiaoshan 的"状态字段双写 + Verification Gap"返工源。
**关掉条件**：无——这是治返工的核心，默认 ON。极小机械改可简化为单条断言而非整套。
→ design doc §4「前置验收测试」+ §2.1 三返工源③。

### 3. 真实运行时 smoke（治"反复打补丁"）
**目标**：编译过 ≠ 跑得起来。每 ticket 完工跑一次真实运行时 smoke（起服务 / 打接口 / 查 DB count / 看启动日志），把"路由 404 / Bean 不存在 / 字典空"这类只在运行时暴露的问题前移。dongjiaoshan 的现场自检（§0 运行时自检）救场过漏建表，**保留强化**。
**关掉条件**：无运行时的纯库/工具——降级为单测覆盖。
→ design doc §4「真实运行时 smoke」+ §2.1（§0 运行时现场自检领先市场，保留强化）。

### 4. 视觉自检环（治 106 视觉偏差）
**目标**：prompt 用**真截图**锚定（非字段表），实现后截当前 UI 与 ground-truth 截图做 diff，偏差超阈值即 raise。dongjiaoshan 视觉偏差根源 = designer 记忆空白 + prompt 用字段表非真截图。
**栈插件**：web 用 Figma Code Connect / Playwright 截图；**小程序需验证微信开发者工具 CLI 截图 diff**（这条是小程序特有的待验证机制，先确认 CLI 能稳定出图再上）。具体放 `stacks/<stack>-notes.md`。
**关掉条件**：纯后端 / 无 UI ticket。
→ design doc §4「视觉自检环(小程序需验证微信 CLI 截图 diff)」+ §2.1 三返工源②。

### 5. 异构 fresh-context 预审（注意 token 成本）— ✅ 已落地（2026-06-09，dynamic workflow）
**目标**：用一个**全新上下文**的异构 agent（不带实现者的偏见）对 diff 做预审，挖实现者上下文里看不见的问题。
**实现**：`.claude/workflows/verify-tickets.js`（dynamic workflow）。吃当天 `daily/D<N>/reports/` 完工 ticket → discover 列各自验收 checkbox → 每 ticket 派 fresh-context 审查者**逐条 refute**（并发 ≤ 16）→ 报告 refuted/unverifiable 项。**硬边界：只验证、出报告，人仍然 commit**（放大 review 带宽，不替代签字）。调用：`Workflow({ scriptPath: '.claude/workflows/verify-tickets.js', args: { day: 3 } })`，或对 Claude 说"用 workflow 验证 D3 完工 ticket"。
**成本警示**：fresh-context = 重新喂 context，**token 成本可能很高**——只对高风险/核心 ticket 那几天跑，且计入第 8 条 token 看板。不要每天每 ticket 都跑。
**关掉条件**：机械改 / 低风险 ticket / token 预算吃紧——不跑即可。
→ design doc §4「异构 fresh-context 预审(注意 token 成本)」+ §2.3（成本量化）。

### 6. security review —— 一等公民
**目标**：B 端有 tenant 隔离 / 权限 / 支付，security review 是 Stage2 **一等公民**，不是事后补。每个涉及多租户/鉴权/资金/外部输入的 ticket 必过 security 维度（越权、租户串数据、注入、密钥泄露）。
**关掉条件**：无敏感面的纯展示/工具 ticket——但默认对所有数据写入路径 ON。
→ design doc §4「security review 一等公民」+ §2.3（市场漏的三块之一：安全合规直接补进 OS）。

### 7. review 带宽实测 + 3 全栈角色锁定 + 并发上限 — 🟡 部分（并发上限已成文）
**目标**：**先实测**"每 review·小时能吃多少 diff"，再据此定并发上限——不照搬市场"3-5 并行"。同时锁定 <<TEAM_MODEL>> 里全栈的角色定位：**只 review，还是也写码？**（这决定真实可用带宽）。
**已成文**：`daily/_templates/README` 段 + `T5 verify-tickets workflow` 已写明两个硬上限——人 review 带宽（保守取低值，实测前 ≤ 自己定）+ dynamic workflow 并发 ≤ 16（Claude Code 官方上限，CPU 依赖）。**人 review 带宽仍需 Kevin 实测填真值**（这条 = 吞吐天花板，未实测前并发保守）。
**关掉条件**：无——必须实测。
→ design doc §4「review 带宽实测 + 3 全栈角色锁定(只 review 还是也写码)+ 并发上限实测」+ §2.3（命门）。

### 8. token 成本看板
**目标**：多 agent 的 token 账单**可能与人力成本同量级**。建看板量化每日/每 ticket token 消耗（尤其第 5 条 fresh-context 预审、并行 agent），让"加一个验证 agent"是有成本数据支撑的决策，不是无脑加。
**关掉条件**：单人小项目可降级为周末瞄一眼总量，不建实时看板。
→ design doc §4「token 成本看板」+ §2.3（市场漏的三块之一：成本量化）。

---

## 落地顺序建议（待 Kevin 拍板）

1. 先做 **1（type/lint gate）+ 2（前置验收）+ 3（运行时 smoke）**——这三条直接治三个返工源，ROI 最高。
2. 再做 **7（带宽实测）**——它决定 5/并发的可行性，是其余项的前提。
3. **4（视觉）/ 5（fresh-context）/ 6（security）** 按 ticket 性质选择性开。
4. **8（token 看板）** 随 5 一起上（fresh-context 是 token 大头）。

> 维护期视角（design doc §2.3 第三块）：所有验证产物（验收 SQL / 截图基线 / security checklist）要能随项目交付给客户长期维护，不是一次性脚手架——落地时设计成可交接的。
