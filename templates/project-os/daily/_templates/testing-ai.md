# D&lt;N&gt; —— AI 机械验证（手指敲键盘的活）

> **顺序铁律**：AI testing → 人感官 testing。**本文件全 ✅（含环境前置）才解锁 `testing-human.md`**，不并行、不倒序。
>
> **核心边界**：手指敲键盘（shell / 查询 / 接口调用 / 编译 / 计数 / 文件存在性）= AI 的活；手指点鼠标 + 肉眼对照 = 人的活（在 `testing-human.md`）。例外：DB GUI 客户端"点开表树看字段"是人；"在查询窗口敲 schema 描述"是 AI。
>
> **占位**：`<<...>>` 真值在 `PROJECT.md`；栈特定命令去 `stacks/<<本栈>>-notes.md`。本模板给"该验什么 + 怎么记"。

---

## §0 环境前置 + 前置验收契约（★轻量 TDD —— 必须先于 spawn 写好）

> **为什么 §0 在最顶上**：复盘头号翻车是 **Verification Gap**（"双字段没人发现 / 没有验收标准就算完"）。治法 = 每个 ticket **在 spawn 之前**就有机器可验的"实现前期望 / 实现后期望"断言。AI §0 自检（第 7 项）会来这里找本 ticket 段，**找不到 → STOP 等 Kevin 补**。这是 SP1 三件 SSOT 第③件"机器可验收 checkbox"在执行端的落点。

### 0.1 环境前置（AI 跑，全绿才往下）

按本栈实际填（命令见 `stacks/<<本栈>>-notes.md` §env）：

- [ ] 依赖/容器起来（`<<DB>>` / 缓存 / 对象存储等）
- [ ] be 装好 + 起服务；fe 装好 + 能 dev/build
- [ ] 缓存/字典刷新（如有"灌数据后需 flush 缓存"的坑）
- [ ] 当日迁移已 apply（`<<MIGRATION_DIR>>` 下本日新增全部跑过）

```bash
# 贴环境前置的 raw output（起服务/迁移 apply 的关键后 5 行）
$ <<env 命令,见 stacks/>>
<...>
```

### 0.2 前置验收契约（每个本日 ticket 一段 —— Kevin 派单前填）

> 格式：每 ticket 写「实现前期望」+「实现后期望」两条机器可验断言（计数 / 查询返回 / 文件存在 / 接口返回码）。AI §0 自检先跑"实现前"对账初始态；§N 完工跑"实现后"贴 raw output。

```markdown
#### <TICKET-ID-1>
- 实现前期望：`<断言，如：相关表不存在 / 计数为 0 / 接口 404>`
- 实现后期望：`<断言，如：表存在且字段对齐 schema§X / 计数为 N / 接口返回业务数据>`
- 验收方式：`<可机器跑的命令/查询，见 stacks/<<本栈>>-notes.md>`
```

（按本日 ticket 数复制；**漏一个 → 对应 ticket 不准 spawn**。例外：批量串行写 + 集成留后跑的合并块，§0 验收顺延集成阶段统一跑。）

---

## §1+ 验证清单（按本日实际 ticket 填）

> 每项给"完整命令 + 期望结果 + 实跑 raw output"。**强制贴 raw output —— 不允许只写"已通过 / ok / 全部跑通"**（复盘：约 70% 报告 raw output 覆盖不足 = 翻车前兆）。

### §1 <TICKET-ID-1>

| # | 验证项 | 命令（栈特定见 stacks/） | 期望 |
|---|---|---|---|
| 1.1 | 编译 / 类型健康 | `<<be 编译 + fe lint/typecheck>>` | 0 error |
| 1.2 | 单测 happy path | `<<单测命令>>` | Tests run: N, Failures: 0 |
| 1.3 | schema 落地对账 | `<<DESC/describe 表，对照 doc/authority/schema-ssot.md §X>>` | 字段名/类型/公共列对齐 |
| 1.4 | 枚举/字典 seed 计数 | `<<count 查询>>` | N 条（对齐 SSOT） |
| 1.5 | 资源/菜单/权限段 seed | `<<count 查询>>` | 父 + N 行按钮权限 |
| 1.6 | 接口 happy path | `<<带鉴权的接口调用>>` | 返回业务数据 / code=success |
| 1.7 | 安全面（碰 tenant/权限/支付时）| `<<跨租户/越权探针>>` | 拒绝 / 隔离生效 |
| 1.8 | 文件/产物存在性 | `<<ls/grep 关键产物>>` | 存在 |

```bash
# §1 raw output（每条命令的真实 stdout 后 5 行）
$ <1.1 命令>
<...BUILD SUCCESS>
$ <1.2 命令>
<...Tests run: ...>
```

### §2 …§N
（按本日 ticket 数复制 §1 结构。）

---

## §Cross 跨 ticket 联调（AI closing 时跑，人不用做）

| # | 验证 |
|---|---|
| C.1 | `<ticket-A 暴露的契约 X 与 ticket-B 调用方 Y 对齐>` |
| C.2 | `<跨域数据流通：上游产数据 → 下游消数据一致>` |
| C.3 | `<共享枚举/字典在两 ticket 用法一致>` |

```bash
# §Cross raw output
```

---

## 失败处理

- AI testing ❌（含环境前置失败）→ AI 主任务方 fix 后**重跑本文件全部**，全 ✅ 再走 `testing-human.md`。
- 人感官测试遇到"起不来 / 路由 404 / 表/数据空" → **当场交 AI 处理**（不要自己 debug）；AI 修不动才升级 `_open-issues.md` / @ Kevin。
- 阻塞性问题 → 直接 @ Kevin。

## 验收
全部 §1+ + §Cross ✅ + raw output 已贴 → 报"环境就绪 + 验证通过" → 解锁 `testing-human.md`。
