---
description: 在一个会话里串行链式执行多天(D<first>..D<last>)——每 ticket 真绿 gate + 关键决策落 progress、天边界对照原型对齐、只在真卡住才熔断、全部跑完末尾批量厚验收。把默认串行流自动化成基本无人值守；人只在末尾 review+merge。
argument-hint: "<范围>  例：/serial-day 1-10  或  /serial-day 1 2 3"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task
---

你要在**当前会话**里把第 `$ARGUMENTS` 天**按顺序串行**跑完（依赖天本就该串行），每天每个 ticket 都过机器验证，全部跑完再批量厚验收。用户说「串行执行 D1-D10」也走这套。这是三档执行里的**串行档**——把 `daily/README.md §1.5` 的「默认串行」自动化成基本无人值守的链。**严格按步骤，不跳；只在真卡住才停。**

## 设计前提（不满足就别上串行档，直接 STOP）
串行档把"人的判断"从逐天 review **前移并压在 SP1 质量上**——它基本无人值守地跑，靠的是 ticket spec 清楚到 fresh-context subagent 不用问就能执行。开跑前确认：
- **三件 SSOT 齐**（`doc/authority/` 冻结 schema + 共享组件 + acceptance-checkboxes.md）且验收可机器验 → 缺则 STOP：「SP1 没齐，串行档会把烂地基一路传播到末尾才暴露，先补 SP1」。
- **范围内的天 prompt 都已细化**（不是骨架）→ `D<N>/prompts/` 空/骨架的，先按 `daily/README.md §0` 滚动细化补全；补不全的天不纳入本次范围。
- **`含共享底座` 的天排在范围最前**（它是别人的上游，别夹在中间）。

## 0. 解析范围 + 建串行集成分支
1. 解析 `$ARGUMENTS`：`1-10` 展开为 1..10；`1 2 3` 原样。得到**有序**天号列表——串行按此序，不重排，依赖天靠"先到先做"满足。
2. 逐天 pre-check：`daily/D<N>/README.md` 不存在 → 把该天踢出范围并提示，**不**因单天缺失 STOP 整链。
3. 集成分支：串行链全程在**一条**集成分支上累加。这是对 `CLAUDE.md §9`「不在 day<N-1> 累加」的**显式例外**——那条防的是"多 agent 各在前一天分支累加 → review/merge 边界糊"；串行链是单一顺序执行体、review 边界 = 整条链末尾，不糊。
```bash
ROOT="$(git rev-parse --show-toplevel)"
FIRST=<范围首天>; LAST=<范围末天>
BR="feature/serial-d${FIRST}-d${LAST}"            # 或 PROJECT.md 指定的集成/staging 分支名
git -C "$ROOT" checkout dev && git -C "$ROOT" pull --ff-only 2>/dev/null || true
git -C "$ROOT" show-ref --verify --quiet refs/heads/$BR \
  && git -C "$ROOT" checkout $BR \
  || git -C "$ROOT" checkout -b $BR dev
```

## 1. 链式主循环（按天序，每天内按 ticket）
对有序列表里的每个天号 N：

### 1a. 进入 D\<N\>
- 更新 `daily/D<N>/progress.md` 顶部标「serial chain · 当前 D<N>」——**链游标落盘**：orchestrator 自己中途 compact 了，也能从这读回"我在第几天第几票"（你逃不掉 compaction，但让它无损）。
- 多 ticket 有共享 zone → 读/建 `D<N>/_inflight.md`，同 zone 串行。

### 1b. 逐 ticket spawn(fresh context) + 真绿 gate
对 `D<N>/prompts/<TICKET>.md` 里每个 ticket，用 `Task` 起一个 **fresh-context subagent**，prompt = 该 ticket 三段式全文 **+ 追加「前序决策」**（从已跑天/票的 `progress.md` 摘关键决策，喂给它，避免它重复推导或推歪）。

subagent 必做：
1. **§0 自检**（git 在 `$BR`、读三件 SSOT、上游硬产物在位、编译健康）→ 不过回 `BLOCKED`。
2. §0.5 设计预检 + 主任务（只引用 SSOT，不自造、不重定义）。
3. **跑机器验证**：`D<N>/testing-ai.md` 本 ticket 段全 ✅ + type/lint gate（`.claude/verify-cmd` 若启用）绿。失败自己 fix 重跑，不请示。
4. §N 完工报告写 `D<N>/reports/<TICKET>.md`；**关键决策**（字段命名 / 接口形状 / 为什么这么选）补一行进 `D<N>/progress.md`（决策契约，供下游票/天读）。
5. 返回 `DONE`（附真绿证据）或 `BLOCKED`（附卡点）。

orchestrator 收到后：
- **防假绿**：核 report 的机器验证是**真绿**——testing-ai 每条旁有 ✅+关键输出、单测汇总 `Tests run>0`（不是 0、不是只编译过、没被 `-q` 吞掉汇总行）。"应该没问题"的自我声明不算绿，打回让它真跑。
- 真绿 → **checkpoint commit**（每票一个，出事能 `git log` 定位/revert 到具体票）：
  ```bash
  git -C "$ROOT" add -A && git -C "$ROOT" commit -m "D<N>/<TICKET>: <一句话>"
  ```
  起下一个 ticket。
- **`BLOCKED` → 熔断**：停整条链，报 Kevin：哪天哪票、卡在什么（缺上游 / spec 矛盾 / 修不动的 gate）、怎么续（修完说「`/serial-day <剩余范围>`」续跑，集成分支会复用）。**熔断只在真卡**——例行 gate 失败 subagent 自己修过了；到这一步是它修不动、或撞到自己定不了的决策。

### 1c. 天边界：对照原型对齐（窄熔断背后的大网）
D\<N\> 全票 `DONE` 后，用 `Task` 起一个 **fresh-context 对齐 subagent**：读 `doc/origin/`（甲方原型快照）+ `doc/authority/`（三件 SSOT），比对 D\<N\> 实建的，**只报"偏离原型/SSOT"项**（少做了 / 做歪了 / 多做了没要求的），不管代码对不对（那是 1b 机器验证的活）。
- **有偏离 → 停链报 Kevin**：窄熔断（1b）逮不住"自信地错"（subagent 不知道自己错就不触发熔断、机器测试又恰好过）；这道对齐就是兜它的大网。3 和 1b 是一对，缺了它窄熔断不安全。
- **诚实边界**：**视觉型原型（Figma/截图）这道检查牙口钝**——AI 只能截图肉眼比，抓不准像素漂移；结构/数据型原型（字段/字典/SQL）才锐。视觉对齐根治仍靠 SP1 真截图锚定（designer 上场），别指望这里补回来。
- 无偏离 → checkpoint commit `D<N> done`，进下一天。

## 2. 全部跑完 → 末尾批量厚验收（不自动 merge）
范围内所有天 `DONE` 后**批量**验。这是串行档省掉逐天重测换来的，所以**末尾这一下必须厚，不能走过场**（假绿 / 漏验 / "自信地错"都在这兜底）：
1. **回归**：跑全栈测试（命令见 `stacks/<<本栈>>-notes.md §test`）+ 各天 testing-ai 复跑，断言 `Tests run>0`。
2. **对抗式验收**：对高风险/核心天跑
   ```
   Workflow({ scriptPath: '.claude/workflows/verify-tickets.js', args: { day: N } })
   ```
   逐条 refute 验收 checkbox。
3. **汇总**：哪些天/票全绿、回归是否真绿、对抗式验出哪些 refuted/unverifiable → 一份总报告交 Kevin。
4. **人 review + merge**：Kevin 看总报告，无 S0/S1 才 merge `$BR` → dev。

## 绝不
- 不自动 merge `$BR` 到 dev / 不 force push / reset --hard（settings.json 已 deny）；末尾交人签字（与对抗式 workflow 同边界）。
- 不在假绿上往下走（report 自我声明 ≠ 真绿）。
- SP1 没齐 / prompt 还是骨架就硬上串行档（前提不满足直接 STOP）。
- 不为图快重排依赖天顺序（串行靠顺序满足依赖）。

> **熔断率 = SP1 质量体温计**：某次串行老在 1b/1c 停（频繁 `BLOCKED` / 老报偏离），不是串行档不好用，是 SP1 没梳透——回去补 SP1，别在 SP2 打补丁。
