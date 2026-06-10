# <<PROJECT_NAME>> — 冻结版需求拆解（模板骨架）

> **本文件是模板骨架。** 实例化时按本结构新建为 `02-需求拆解-vX.md`（X = 冻结版本号），
> 本骨架可保留作为下次新建的参考，也可删。

| 项 | 值 |
|---|---|
| **版本号** | `vX`（GATE 通过即冻结） |
| **冻结状态** | 🔒 **冻结只读** —— 冻结后任何变更走 [`changes.md`](changes.md) CR，**不动本文件正文** |
| **上游** | `00-brief.md` 澄清结论 + `origin/` 客户原始料 + 架构 ADR |
| **下游** | 三件 SSOT（见文末"与三件 SSOT 的关系"）+ daily ticket 拆分 |

---

## 1. 功能域清单（占位）

> 域列表按 `../PROJECT.md` 的 `<<DOMAINS>>` 实例化，本文件只引用概念，不重复声明域值。

| # | 功能域 | 一句话职责 | 关联 ticket（→ 见各域 AC 段） |
|---|---|---|---|
| 1 | `<<域A>>` | `<<职责>>` | `<<TICKET-ID...>>` |
| 2 | `<<域B>>` | `<<职责>>` | `<<TICKET-ID...>>` |

---

## 2. 每域 AC（验收标准）

> 每个功能域一段；每个 ticket 列"做什么 + 验收标准（人话）"。**机器可验断言不在这里写**——
> 翻成可机器判定的 checkbox 落 [`authority/acceptance-checkboxes.md`](authority/acceptance-checkboxes.md)，本文件只钉死"业务上算对的标准"。

### 2.1 `<<域A>>`

#### `<<TICKET-ID>>` — `<<ticket 标题>>`

- **做什么**：`<<一句话功能描述>>`
- **AC（验收标准）**：
  - [ ] `<<可判定的业务结果，如：录入 X 后列表能查到、状态按 Y 流转>>`
  - [ ] `<<边界/反例，如：必填空被拦、终态不可再操作>>`
- **涉及**：schema `<<表/字段>>` / 组件 `<<页面>>` / 字典 `<<dict_key>>`（占位，详见三件 SSOT）

（按 ticket 数复制本块。）

### 2.2 `<<域B>>`

（同上结构。）

---

## 3. 与三件 SSOT 的关系（需求 → 落地）

> 本需求拆解是三件 SSOT 的**上游**。冻结后，下面三件按本文件的字段/视觉/验收口径分别落地，
> 实施时三件 SSOT 是机器可验的权威；本文件提供"业务为什么这样定"的人话依据。

| 本文件 | → 落到哪件 SSOT | 落什么 |
|---|---|---|
| 每域字段/枚举语义 | [`authority/schema-ssot.md`](authority/schema-ssot.md) | 冻结表结构 + 字典/枚举 + ID 编号规则 |
| 每域页面/交互 | [`authority/components-ssot.md`](authority/components-ssot.md) | 共享组件清单 + design token + 真截图锚定 |
| 每 ticket AC（人话） | [`authority/acceptance-checkboxes.md`](authority/acceptance-checkboxes.md) | 翻成含期望值的机器可验 checkbox |

> **冻结纪律**：本文件 🔒 后，需求变更一律走 [`changes.md`](changes.md) CR；CR 落地顺序 = 先改 SSOT（权威）→ 再生成迁移 → 再改码 → 再更新验收。**不在本文件正文里改/留中间态。**
