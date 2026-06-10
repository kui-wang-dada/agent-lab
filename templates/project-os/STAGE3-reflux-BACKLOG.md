# Stage3 (SP3) — 反哺 → 再生 · BACKLOG

> ⚠️ **设计未详化**：本文件是**待建清单**，不是已落地的机制。SP3 在 design doc 里仍是后续 sub-project（见 §4 后续待办）。下面每条 = 一句话目标 + 关掉条件 + 指向 design doc。
>
> **权威依据**：`agent-lab/docs/superpowers/specs/2026-06-03-human-ai-engineering-os-design.md` §4（SP3 反哺→再生）+ §1（方案 A 反哺闭环：项目结束一次性反哺，漂移在此收敛）。
>
> **总原则**（design doc §2.2）：**"自学习 agent" 是头号 hype**——连厂商都承认 agent 自动进化 skill 未实现。能跨项目复用的是**确定性 spec/skill + 人工策展**，不是向量 memory。所以 SP3 全部机制都是 **事件驱动沉淀 + 人拍板**，不做任何"agent 自动学习/自动进化 skill"。

---

## 待建清单

### 1. 修 `subagent-stop.sh` 两个已验证 bug
**目标**：修 dongjiaoshan 暴露的两个 hook bug（已确认，已在 hook 层定位）：
- **bug A**：agent 名 118/118 全推成 `unknown`——transcript 路径 `*subagents*` 判定 + `basename .jsonl` 取名失败。改成从 payload 直接拿 agent 标识（或解析 transcript 内的 agent 字段），别靠路径模式。
- **bug B**：`user_intent` 抓到 `<ide_opened_file>` 等 IDE 噪声——取"第一条 user message"时没过滤系统注入内容。改成跳过 `<...>` 包裹的系统 tag，取真正的人类意图首句。
**关掉条件**：无——这是已确认 bug，必修。
→ design doc §4「修 subagent-stop.sh 两个已验证 bug」+ §2.1（118/118 unknown + `<ide_opened_file>` 噪声）。

### 2. 蒸馏做成 hook 当场触发（不攒队列）
**目标**：把"经验蒸馏"做成 **SubagentStop / merge hook 当场触发**——每次 subagent 结束或每日 merge 时，立刻把这次的一行 learnings / skill 候选沉下来。**不再攒 `_review-queue` 等周巡批量消费**（dongjiaoshan 攒了 290-310 条从未被消费，冲刺期周巡最先被跳过）。
**关掉条件**：无——当场触发是治"队列空转"的核心。但**人拍板环节不可省**（见第 5 条）：hook 只负责沉候选，不自动写进经验池。
→ design doc §4「蒸馏做成 SubagentStop/merge hook 当场触发(不攒队列)」+ §1（事件驱动沉淀）+ §2.1（_review-queue 累积从未被消费）。

### 3. 项目结束一次性反哺经验池
**目标**：项目收尾时做**一次性**反哺：把项目沉淀的经验（facts / learnings）汇总写进 `agent-lab/memory/` 跨项目经验池。日常事件驱动沉淀解决"项目内"，这步解决"跨项目"。
**关掉条件**：无——项目结束必做，是方案 A 反哺闭环的左半边。
→ design doc §4「项目结束一次性反哺」+ §1（项目结束:经验 → 经验池）。

### 4. 模板再生 + 管漂移
**目标**：项目结束时，把本项目沉淀的**通用机制**回写到 `templates/project-os/`——下个项目 cp 时已自带本次教训。这是方案 A 唯一真风险（副本与 hub 漂移）的**收敛点**：漂移只在"项目结束回写"这一刻被纪律化地合并，不放任各副本各自演化。
**关掉条件**：本项目没产出任何通用机制改进（纯实例性工作）——则只反哺经验池（第 3 条），不动模板。
→ design doc §4「模板再生 + 管漂移」+ §1（通用机制 → 回写模板，漂移在此收敛）。

### 5. skill 抽取：事件驱动 + 人拍板（自学习 agent 是 hype，不做）
**目标**：skill 抽取保持 **事件驱动触发 + 人拍板**。hook 沉候选（第 2 条），人决定哪些真值得抽成 skill。**严格门槛**（dongjiaoshan 已验证）：同时满足"横跨 ≥3 ticket + 改 prompt 解决不了 + 方法论可复用"才抽——不要"一个 bug 一个 skill"，skill 多了稀释，没人读。
**明确不做**：不建任何"agent 自动进化 skill / 向量 memory 自动检索复用"的机制——那是市场头号 hype。
**关掉条件**：无候选达门槛 → 不抽，正常。
→ design doc §4「skill 抽取保持事件驱动 + 人拍板(自学习 agent 是 hype，不做)」+ §2.2（自学习 agent 是头号 hype；可复用的是确定性 spec/skill + 人工策展）。

---

## 反哺闭环全景（design doc §1）

```
项目内（日常，事件驱动）
   每日 closing / 每次 SubagentStop
   → hook 当场沉一行 learnings + skill 候选（第 2 条，不攒队列）
   → 人拍板哪些进 facts/learnings、哪些抽 skill（第 5 条）

项目结束（一次性）
   → 经验汇总反哺 agent-lab/memory 经验池（第 3 条）
   → 通用机制回写 templates/project-os（第 4 条，漂移在此收敛）
        │
        ▼
   下个项目 cp 模板时已自带本次教训
```

> 慢节奏 curator 周巡（design doc §1）**只整合经验池**，不再管"项目里"的消费——项目内消费已由事件驱动 hook 当场完成。这是对 dongjiaoshan "周巡在冲刺期最先被跳过 → 队列空转"的根治。
