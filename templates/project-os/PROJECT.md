# PROJECT.md — 项目宪法（★单一变量源 / Single Var Source）

> **这是整个 project-os 唯一声明实例值的地方。**
> 其他文件（doc/、daily/、authority/、.claude/）只**引用概念**（如"业务模块子树""字典权威源"），
> **绝不再重复声明具体值**。改栈 / 改路径 / 改团队模型，只动这一页 → 杜绝 drift。
>
> 实例化新项目时：cp 整个 `templates/project-os/` → 填本页所有 `<<占位符>>` → 其余文件自动生效。
> 填完后请删掉本注释块上方的"模板说明"，但保留下面的「填写指引」一行注释。

---

## 0. 填写指引（init 时逐项替换 `<<...>>`，填完即冻结，变更走 doc/changes.md CR）

| 占位符 | 含义 | 本项目实例值 |
|---|---|---|
| `<<PROJECT_NAME>>` | 项目代号（短，给目录 / commit / 文档标题用） | `<<PROJECT_NAME>>` |
| `<<PROJECT_PATH>>` | 项目绝对路径（AI §0 自检读文件用绝对路径） | `<<PROJECT_PATH>>` |
| `<<TEAM_MODEL>>` | 团队模型（谁派单 / 谁 review / 谁写码 / 谁测） | `<<TEAM_MODEL>>` |
| `<<STACK_BACKEND>>` | 后端技术栈 | `<<STACK_BACKEND>>` |
| `<<STACK_FRONTEND>>` | 前端（PC / 管理端）技术栈 | `<<STACK_FRONTEND>>` |
| `<<STACK_APP>>` | App / 移动 / 小程序端技术栈（无则填"无"） | `<<STACK_APP>>` |
| `<<DB>>` | 数据库 | `<<DB>>` |
| `<<DOMAINS>>` | 业务域列表（逗号分隔） | `<<DOMAINS>>` |
| `<<MIGRATION_DIR>>` | DB 迁移脚本目录（相对 repo 根） | `<<MIGRATION_DIR>>` |
| `<<ID_NAMING>>` | 业务 ID / 编码命名规则 | `<<ID_NAMING>>` |
| `<<ENUM_DICT_REF>>` | 枚举 / 字典权威源（指向 authority/ 下哪份） | `<<ENUM_DICT_REF>>` |
| `<<FRAMEWORK_BASE_PATHS>>` | 第三方框架底座源码目录（settings.json **deny** 写入，只读不改） | `<<FRAMEWORK_BASE_PATHS>>` |
| `<<BUSINESS_MODULE_PATHS>>` | 本项目业务代码子树（settings.json **allow** 写入） | `<<BUSINESS_MODULE_PATHS>>` |

> 上表「本项目实例值」列就地改写即可；下面各节用人类语言把这些值串成一页可读宪法。

---

## 1. 一句话

`<<PROJECT_NAME>>`：<一句话说清这个系统做什么、给谁用>。
客户/渠道：<国内甲方 中文/CNY · 或 · 海外客户 英文/USD>。
当前阶段：<接料 / 已澄清 / 开发中 / 内测 / 交付>。

## 2. 团队模型（review 带宽是吞吐天花板，照此排并发）

`<<TEAM_MODEL>>`

> **为什么单列**：市场蓝图假设"N 个专职 Verifier"，真实小团队往往不是。
> review·小时能吃多少 diff = 真实吞吐上限，并发数照此定，**不照"理论上能并行几个 ticket"定**。

## 3. 技术栈（"原则 + 按栈插件"——通用机制在 doc/，栈细节在 stacks/）

| 层 | 选型 | 栈插件笔记 |
|---|---|---|
| 后端 | `<<STACK_BACKEND>>` | `stacks/<...>-notes.md`（若有） |
| 前端 | `<<STACK_FRONTEND>>` | 同上 |
| App / 移动端 | `<<STACK_APP>>` | 同上 |
| 数据库 | `<<DB>>` | — |

> **铁律**：框架特定机制（如某脚手架的 service 基类、迁移命名、菜单 seed）**不进** doc/ 通用骨架，
> 一律落在 `stacks/<stack>-notes.md` 当**可选栈插件**。通用工程机制留在 doc/，栈是实例。

## 4. 代码边界（决定 AI 能写哪、不能动哪——同步进 .claude/settings.json）

| 类别 | 路径（相对 repo 根） | AI 权限 |
|---|---|---|
| 第三方框架底座 | `<<FRAMEWORK_BASE_PATHS>>` | **只读**（settings.json deny 写入）——升级框架走单独流程，不在日常 ticket 里改 |
| 本项目业务子树 | `<<BUSINESS_MODULE_PATHS>>` | **可写**（settings.json allow）——所有业务 ticket 落这里 |

> **为什么分**：业务代码与框架底座混在一棵树时，AI 容易"顺手改了框架"导致升级冲突 + review 噪声爆炸。
> 物理隔离 deny/allow 是最便宜的护栏。

## 5. 业务域 & 权威源（三件 SSOT 的指针，值在 authority/ 不在这里）

- **业务域**：`<<DOMAINS>>`
- **枚举 / 字典权威**：`<<ENUM_DICT_REF>>`（AI 只能引用，不能自造；CI 漂移即报错）
- **ID / 编码命名**：`<<ID_NAMING>>`
- **迁移目录**：`<<MIGRATION_DIR>>`（命名规约见 stacks/ 或 _adr/）

> 三件 SSOT 的**内容**分别在 `authority/`（schema / 组件 / 验收 checkbox），本页只放**指针**。

## 6. M 锚点（里程碑 / 节奏锚，不是甘特图）

> 只列"硬节点"——客户演示日、内测启动、交付日。daily/ 的 D&lt;N&gt; 挂到这些锚点下，**不在这里排每天**。

| 锚点 | 日期 | 含义 / 进入条件 |
|---|---|---|
| M0 接料完成 | `<日期>` | origin/ 加锁 + snapshot 基线 + WARNING 标注完 |
| M1 设计 GATE 过 | `<日期>` | 三件 SSOT 齐 + 验收 checkbox 可机器验 → 才准派单进 Stage2 |
| M2 客户演示 | `<日期>` | <核心 demo 范围> |
| M3 内测启动 | `<日期>` | <谁测 / 怎么提 bug> |
| M4 交付 | `<日期>` | <交接物 / 维护期约定> |

## 7. 不做清单（显式 Out-of-Scope —— 防 scope creep，每条带"重启条件"）

> 强默认是"砍"；要做的话走 CR 重新进 scope。每条写清"什么条件下重新评估"。

- ❌ <某功能>　—— 重启条件：<客户演示后强烈要求 / V2 启动 / ...>
- ❌ <某集成>　—— 重启条件：<...>
- ❌ <某端>　　 —— 重启条件：<...>

## 8. 一等公民约束（每个 ticket 都要过，不是可选项）

- **security**：B 端通常有 tenant / 权限 / 支付 → security review 是 Stage2 一等公民（不是上线前补）。
- **成本**：多 agent token 账单可能与人力同量级 → 跟踪用量，别无限 fan-out。
- **维护期**：交付客户长期用 → 可维护性 / 可交接性是验收项，不只看"能跑"。

---

> 改本页任何值 = 改项目宪法 → 必须走 `doc/changes.md` CR + 签字。AI 在 §0 自检时以本页为准。
