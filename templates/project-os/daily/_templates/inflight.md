# D&lt;N&gt; In-Flight Tickets（当日并发 zone 表）

> **这是比 git worktree 更轻的并发隔离机制。** 当日多个 ticket 并行 spawn 时，靠"文件 zone"判断能不能并行，而不是开 worktree。
>
> **为什么用 zone 表而非 worktree**：复盘结论 —— 多 agent 高频改的往往是**同几个共享文件**（依赖清单 / 全局配置 / 共享基类 / 全局 seed）。worktree 隔离的是工作区，解决不了"两个 agent 都要改同一个共享 `<<FRAMEWORK_BASE_PATHS>>`/common 文件"。zone 表把冲突显式化：**同 zone 串行，跨 zone 并行**，比 worktree 轻、且 AI §0 自检能直接读它判断。
>
> **用法**：派单方 spawn 前在表里加一行（写清这个 ticket 会动哪些"粗粒度文件 zone"）；AI 完成时把状态改 ✅。AI §0 自检第 3 项会读本文件，命中"同 zone 有别的 ticket 正在飞" → 先 wait 或 STOP。
>
> **关掉条件**：当天只 spawn 一个 ticket（无并发）→ 本文件可不建。

| Ticket | Spawn 时间 | 改动文件 zone（粗粒度） | 状态 |
|---|---|---|---|
| `<TICKET-A>` | <HH:MM> | `<如：业务域 X 子树 / 迁移目录 / 某共享基类>` | ⏳ 进行中 |
| `<TICKET-B>` | <HH:MM> | `<如：业务域 Y 子树>`（跨 zone，与 A 并行 ok） | ⏳ 进行中 |
| `<TICKET-C>` | <HH:MM> | `<如：全局菜单/权限 seed>`（⚠️ 与 A 冲突，串行等 A） | ⏸ 等 A |
| ... | | | ✅ 完成 |

## 冲突解决约定
- **同 zone 多 ticket → 串行**（后者等前者完成再 spawn / 继续）。
- **跨 zone 并发 → 各自跑，互不干扰**。
- **高频冲突文件清单**（项目实例化时按 `<<STACK_BACKEND>>`/`<<STACK_FRONTEND>>` 填真值，参 `stacks/<<本栈>>-notes.md`）：
  - 依赖/构建清单（父级 build 文件）
  - 全局运行时配置
  - 全局 seed（菜单 / 权限 / 字典）
  - 共享上下文 / 拦截器 / 基类（在 `<<FRAMEWORK_BASE_PATHS>>` 旁的项目 common 层）
- **shelf 战术**（同一模块多 agent 并发，对方未编译完导致本 ticket build 失败时）：临时移走对方未完包 → build 本 ticket → **务必恢复**；reports 必须记录 shelf 操作 + 对方包 + 责任 ticket-id；**不在 shelf 期间改对方包**（违反 scope 边界）。具体命令见 `stacks/<<本栈>>-notes.md`。
- **closing 缓冲**：日终联调前留一段时间，让全部在飞 agent 都编译通过，再做 cross-ticket 联调。
