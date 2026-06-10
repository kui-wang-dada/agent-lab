---
description: 在当前会话里执行某一天(D<N>)的完整 6 步日循环——单天、人保留当天 closing+merge 决策。三档执行里的"单个执行"（也可直接说「执行 D1」）。
argument-hint: "<day-number>  例：/run-day 1"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task
---

在**当前会话**（不开 worktree）里把第 `$1` 天（D`$1`）按 `.claude/CLAUDE.md` §2 的 **6 步日循环**跑完。这是三档执行里的**单个执行**——一天、careful、你在当天 closing 后做 review + merge 决策。用户说「执行 D`$1`」「单独跑 D`$1`」也走这套。

**与另两档的区别（同一日循环，差别只在人 review 落在哪）：**
| 档 | 命令 | 跑几天 | 人 review/merge 落点 |
|---|---|---|---|
| **单个** | 本命令 `/run-day` | 一天 | 当天 closing 后（要稳、要盯一天用它）|
| **并行** | `/parallel-day` ×N 窗口 | 独立的几天同时 | 攒批一起测，`/integrate-day` 合 |
| **串行** | `/serial-day` | 依赖的多天链式 | 挪到全部跑完的末尾批量 |

## 步骤

### 0. 切分支（不在上一天分支累加）
```bash
ROOT="$(git rev-parse --show-toplevel)"
git -C "$ROOT" checkout dev && git -C "$ROOT" pull --ff-only 2>/dev/null || true
git -C "$ROOT" show-ref --verify --quiet refs/heads/feature/day$1 \
  && git -C "$ROOT" checkout feature/day$1 \
  || git -C "$ROOT" checkout -b feature/day$1 dev
```
`daily/D$1/README.md` 不存在 → **STOP** 报「D$1 还没生成，先在 SP1b 切出来」。

### 1. 按 CLAUDE.md §2 六步跑
开工看 `D$1/README.md` ticket 清单 → 多 ticket 先在 `D$1/_inflight.md` 登记文件 zone（同 zone 串行）→ 逐个 `prompts/<TICKET>.md` 三段式执行（§0 自检 / 主任务 / §N 报告，可 `Task` 起 subagent）→ 跑 `D$1/testing-ai.md` 全 ✅（**真绿**：每条旁标 ✅+关键输出、单测 `Tests run>0`，自我声明不算）→ `testing-human.md` 按 `<<TEAM_MODEL>>` → closing audit + `summary.md` → 第 6 步事件驱动沉淀。

### 2. closing 后交你决策
AI 出 `summary.md` + `audit-report.md`，你看无 S0/S1 残留 → merge `feature/day$1` → dev。**本命令不自动 merge**（与串行档末尾一致，人保留 merge 签字）。

**绝不** force push / reset --hard（settings.json 已 deny）；不催 AI 跳过 §0 自检。
