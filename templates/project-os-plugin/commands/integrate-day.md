---
description: 把已完成的若干天分支依次合并回集成分支(dev)——含冲突处理 + 清理 worktree，全程不手敲 git
argument-hint: "<day-number...>  例：/integrate-day 1 2 3"
allowed-tools: Bash, Read, Edit, Grep, Glob
---

把第 `$ARGUMENTS` 天的 `feature/day<N>` 分支**依次**（不并发）合并回集成分支，按 `daily/README.md §1.5` 的冲突处理。集成分支默认 `dev`（`PROJECT.md` 指定则以它为准）。

## 0. 前置
- 确认列出的每个天号都已完成（对应 worktree 里 testing-ai ✅ 且已 commit）。未完成的 → 跳过并提示。
- `ROOT="$(git rev-parse --show-toplevel)"`；在 `$ROOT`（主目录/dev）上操作，不在 worktree 里合。

## 1. 依次合并（每合一个就 build + smoke，冲突早暴露）
```bash
git -C "$ROOT" checkout dev && git -C "$ROOT" pull --ff-only 2>/dev/null || true
```
对参数里的每个天号 N（**按给定顺序，一个一个来**）：
1. `git -C "$ROOT" merge --no-ff feature/day<N>`
2. **若冲突**：几乎都在「共享接缝」——
   - **追加型登记表**（路由 / 菜单 seed / i18n / DI 注册）：多是「两边各加一行」→ 两行都留，`git add`。
   - **迁移号撞了**：说明某天没守迁移号预占段 → 把后合的那个 migration 文件名调到空号 + 必要时 rename，`git add`。
   - **共享配置**（依赖清单 / 全局 yml）：人工合并两边意图。
   - 解完 `git -C "$ROOT" commit`（完成 merge）。
3. 合完跑一次**编译 + 集成 smoke**（命令见 `stacks/<<本栈>>-notes.md` §test）；❌ 先修再合下一个。

> 想更稳：合某天前，让该天 worktree 先 `git -C "$WT" rebase dev`，把冲突在自己分支消化掉再回来合。

## 2. 全部合完
- 跑一次完整集成 smoke（跨天联调：上游产数据→下游消数据一致）。
- ✅ → 报告：已合并 D`$ARGUMENTS` 到 dev，集成 smoke 通过。

## 3. 清理 worktree（合干净才移除）
对每个已成功合并的天号 N：
```bash
WT="$(dirname "$ROOT")/$(basename "$ROOT")-d<N>"
git -C "$ROOT" worktree remove "$WT"        # 若有未提交残留会报错——先确认是否真不要了
git -C "$ROOT" branch -d feature/day<N>     # 已合并的分支可删（保留也行）
```

**绝不** force push / reset --hard / clean -f（settings.json 已 deny）。合并顺序、build gate、冲突处理都按上面来，不图快跳步。
