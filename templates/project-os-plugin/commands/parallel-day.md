---
description: 自动建/复用 git worktree 并在其中执行某一天(D<N>)的全部任务——用于并行跑多天，全程不手敲 git
argument-hint: "<day-number>  例：/parallel-day 1"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task
---

你要在一个**隔离的 git worktree** 里执行第 `$1` 天（D`$1`）的任务，让它能与其他天并行、互不干扰。用户说「并行执行 D`$1`」也走这套。**严格按步骤，不跳。**

## 0. 前置校验（不过就 STOP，不硬跑）
1. 读 `daily/D$1/README.md`：不存在 → STOP 报「D$1 还没生成，先在 SP1b 切出来」。
2. 看其顶部 `并行性` 标记：
   - `依赖 D<M>` 且 D<M> 未 merge 到集成分支 → **STOP**：「D$1 依赖 D<M>，须先合并 D<M> 才能并行」。
   - `含共享底座` → **STOP**：「D$1 动共享底座（是别人的上游），应串行先做完合并，不进并行波」。
   - `独立`（或无未满足依赖）→ 继续。
3. 记下 D$1 顶部的**迁移号预占段**（如 `0900-0959`）。本天所有 migration 只在该段内选号——并行 worktree 之间互相看不到彼此选的号，**必须守段**（见 `stacks/<<本栈>>-notes.md` §2）。

## 1. 自动建/复用 worktree
集成分支默认 `dev`（若 `PROJECT.md` 指定了别的集成分支名，以它为准）。

```bash
ROOT="$(git rev-parse --show-toplevel)"
WT="$(dirname "$ROOT")/$(basename "$ROOT")-d$1"          # sibling 目录，不嵌套在项目内
git -C "$ROOT" fetch --all --quiet 2>/dev/null || true   # 有 remote 就刷新 dev
if git -C "$ROOT" worktree list | grep -q "$WT"; then
  echo "复用已存在的 worktree: $WT"
elif git -C "$ROOT" show-ref --verify --quiet refs/heads/feature/day$1; then
  git -C "$ROOT" worktree add "$WT" feature/day$1          # 分支已存在 → 挂上
else
  git -C "$ROOT" worktree add "$WT" -b feature/day$1 dev   # 新分支从 dev 切
fi
echo "WORKTREE=$WT"
```

跑完告诉用户：worktree 已就绪在 `$WT`，**接下来我只在这棵树上干，绝不碰主目录或别的 worktree**。

## 2. 在 worktree 里执行 D$1
**此后所有读写 / git / build / 测试都以 `$WT` 为根**——文件用绝对路径（`$WT/...`），git 用 `git -C "$WT" ...`，不依赖当前 cwd。

按本项目 `.claude/CLAUDE.md` 的 6 步日循环执行 D$1：
1. 多 ticket 并发 → 先在 `$WT/daily/D$1/_inflight.md` 登记各 ticket 文件 zone（同 zone 串行）。
2. 逐个 `$WT/daily/D$1/prompts/<TICKET>.md` 按**三段式**执行（可 `Task` 起 subagent 并行）：
   - §0 自检照走：git 在本 worktree 的 `feature/day$1` 分支、读三件 SSOT、确认上游已在 dev、编译健康；不过 STOP。
   - §0.5 设计预检 + 主任务（只引用三件 SSOT，不自造）。
   - migration 选号**只在 D$1 预占段内**。
   - §N 完工报告写 `$WT/daily/D$1/reports/<TICKET>.md`。
3. 跑 `$WT/daily/D$1/testing-ai.md` 全 ✅（人测按 `<<TEAM_MODEL>>` 安排，可后置）。
4. commit 到 `feature/day$1`。
5. long-running 进程（dev server 等）端口要和别的并行 worktree 错开（见 `stacks/<<本栈>>-notes.md`），用完关掉。

## 3. 收尾
全部 ticket 完工 + testing-ai ✅ + 已 commit → 报告：
> D$1 完成于 worktree `$WT`（分支 feature/day$1）。其他并行天也完成后，用 `/integrate-day <天号...>` 合并回 dev。

**绝不**：在主目录/别的 worktree 动手；越出迁移号预占段；force push / reset --hard（settings.json 已 deny）。
