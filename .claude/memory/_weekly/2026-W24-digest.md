# 2026-W24 curator 周巡 digest

**周巡触发**：launchd 自动调度 `com.kevin.agent-lab-curator` 周二触发点（W24 首次真跑，周日/周一未触发；按 ISO 周号幂等）
**执行时间**：2026-06-09
**模式**：headless（`--dangerously-skip-permissions`）

> 用途提醒（来自 `_weekly/README.md`）：本文件是"分层自治 — 强默认 + 可否决"里"可否决"那一环的落点。Kevin 审阅后可对任意自动落条目 `git revert` 否决。

---

## TL;DR

**本周自动落了 0 条 / 高风险候选 0 条 / review-queue 归档 4 条**——是健康信号，不是失败。

理由：W23 校准方案落地后，subagent 已在 W23 末 in-band 直接沉淀本周经验（覆盖率充分），周巡未发现需 curator 二次沉淀的条目；hook 噪音过滤上周打补丁后 review-queue 噪音从 21 条降到 4 条 stop 元数据 stub，无 `signal:failure` 无 `user_intent_snippet`。**不强行"为做而做"的沉淀**。

---

## ① 本周自动落了什么（低风险类，可 `git revert` 否决）

| # | 类别 | 落点 | 置信度 | 一句话 |
|---|---|---|---|---|
| — | — | — | — | **本周 0 条**——subagent in-band 已沉淀；周巡未发现需补的可泛化条目 |

**为什么是 0 条**：

- review-queue 4 条全是 stop 元数据 stub（无 `user_intent_snippet`、无 `signal:failure`、无 `occurrences`），按"低风险类且分 ≥ 0.6 才自动落"规则，全部低于阈值。
- W23 期间 subagent 已直接 in-band 沉淀本周经验，落点散落在以下文件（**非本次周巡新增，仅核对存在**）：
  - `kevin-dev/learnings.md`：2026-06-07 五条（media pipeline 观点浮层 OOM 修复 / lavfi `color@0.0` alpha 丢失 / marker 内联三处 strip 同步 / docker compose build 必跑 / 自用工具产品化"独占钩子"思维框架）
  - `kevin-dev/learnings.md`：2026-06-05 多条（RuoYi-Vue-Plus 抗高并发四件套 / display_map vs term_map / run-steps.sh --until / FunASR Mac spike 修正）
  - `kevin-domestic/learnings.md`：2026-06-05 两条（微信小程序备案审批是头号风险 / 死线项目报价拆解）
  - `kevin-research/facts.md`：2026-06-07 一条（script-first 视频工具市场调研沉淀）+ 2026-06-05 一条（ASR 词级时间戳调研沉淀）
- 这些都是 subagent 自己按"格式 + 适用场景"标准入库的，curator 复审认为：质量高、结构正确、无重复——**curator 这里不重复沉淀，避免 entropy**。

---

## ② 高风险候选（待 Kevin 拍板）

| # | 类别 | 摘要 | 评分 | 文件 |
|---|---|---|---|---|
| — | — | — | — | **本周 0 条**——无 subagent 体系结构调整 / 无新 skill 候选 / 无 plugin 机器改动需求 |

**为什么是 0 条**：

- W23 已审批的 `domestic-project-os-bootstrap` 是首个落地的项目级 skill，仍处 "未在真实 gig 验证" 阶段（MEMORY.md 的 "Defer engineering-practice optimizations" 条目就是这层认知）。本周未发生新 gig 触发 skill 复用，无新候选浮现。
- subagent prompt / agent 列表 / project-os plugin 机器结构本周均无改动需求来自任何记录。

---

## ③ review-queue 处理

| 项 | 数量 |
|---|---|
| 本次扫到的条目 | 4 |
| 已归档 | 4（全部）|
| 队列剩余 | 0（只留 `README.md`）|
| 归档目录 | `.claude/memory/_archive/2026-06/`（追加到既有月归档；`_ARCHIVE-NOTE.md` 已补 W24 段）|

**4 条详情**：

| 文件 | type | 备注 |
|---|---|---|
| `2026-06-07-174505-session.json` | session stop | 同一 session ID `578ff44b` |
| `2026-06-07-174651-subagent.json` | subagent stop | `agent: unknown`、`user_intent_snippet` 是 IDE-opened-file 文本（archive 文件） |
| `2026-06-07-174704-session.json` | session stop | 不同 session ID `558f9a34` |
| `2026-06-08-065559-session.json` | session stop | 同 `578ff44b` 第二次 stop |

**对比 W23 → W24**：W23 周巡时 21 条全噪音；W24 仅 4 条 stop 元数据 stub。**2026-06-08 落地的 hook 噪音过滤已生效**——IDE-opened-file 类纯噪音被剔除，剩下的"无任务上下文 stop 事件"是无法预筛的兜底状态。

---

## ④ 整合 / 信源说明

- **facts.md 跨域整合扫**：kevin-research / kevin-media / kevin-domestic / kevin-dev / kevin-upwork 各 facts.md 本周 diff 已读，无重复/无冲突/无过期需清理条目。
- **research-notes 入口扫**：本周新增 `chinese-asr-wordlevel-2026-06-05.md`、`script-first-video-tool-market-2026-06-07.md` 两份。两者均已被 subagent 在 W23 末沉淀到 `kevin-research/facts.md` 的同主题 brief 段（含信源补充 + 适用场景）。**curator 这里不重复抽取**——research-notes 本身定位是"可引用的调研档案"，brief 沉淀已覆盖结构化结论，重复沉到 learnings 反而是 entropy。
- **USER.md 更新**：Hot Context 推进到 W24，记录"分层自治校准方案首周稳态运行"观察。Change Log 追加 2026-06-09 条目。
- **SKILLS_INDEX.md 更新**："Last refreshed" 改 2026-06-09，文字反映"本周无新 skill / 无新候选 / 无新 rule"。

---

## ⑤ 需 Kevin 拍板的开放问题（不会瞎编进 facts）

无。本周分层自治体系稳态运行，无需 Kevin 介入决策。

> 历史保留待拍板项（沿用上周列表，本周未发生新讨论也未关闭）：
> - **海外 grant 1k GBP** 询价最终决策口径——状态仍是"待 Kevin 在 USER.md 中补充确认是否成交+成交价"。本周记录 0 进展。
> - **weekly-review user-level skill 改写 vs 删除**——上周 curator 推荐"改写指向 agent-lab/.claude/memory/research-notes/ + media weekly-log/"，但属 user-level skill 管辖外+涉职责划分，仍留 Kevin 决定。

---

## 元 / 自检

- 严格遵守"高风险类绝不自动落"红线：未碰 `.claude/agents/`、未碰 `templates/project-os/`、未碰任何 plugin 机器层、未在 `.claude/skills/` 下新建文件。
- 严格遵守"低风险类需 ≥ 0.6 阈值"红线：4 条 stub 全部低于阈值，全部归档不落。
- 严格遵守"headless 直接落盘、不留 diff 提案"红线：本次所有改动通过 Write/Edit 直接落盘，无"等 Kevin 确认"的待办文本。
