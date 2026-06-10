# stacks/ —— 栈插件机制

> 一句话：**原则在 generic 模板，栈细节在这里。** generic 模板（PROJECT.md / SP1 三件 SSOT / 三段流水线）只写"工程机制"和"为什么"；具体到 RuoYi/Java、Next+FastAPI、uni-app 怎么落地，是**栈实例**，按栈拷一个插件进来。

---

## 0. 为什么要分层（设计依据）

设计文档（`docs/superpowers/specs/2026-06-03-human-ai-engineering-os-design.md` §2.3 / §3.1）逼出来的一条硬约束：

> 市场那套 AI 工程蓝图全是 web 栈（Prisma / Figma Code Connect / Playwright）。但实战项目可能是 RuoYi/Java + uni-app，也可能是 Next+FastAPI。**OS 必须写成「原则 + 按栈插件」**，否则要么模板被某一个栈污染、要么每个新项目都在重抄同一份框架踩坑。

所以：

| 层 | 放什么 | 寿命 | 例子 |
|---|---|---|---|
| **generic 模板**（上级目录） | 工程机制 + 为什么 + 占位符 | 跨所有项目，回写收敛 | 三件 SSOT 概念、CR/OQ 双轨、closing audit、§0 自检 |
| **栈插件**（`stacks/<stack>-plugin/`） | 金标准片段 + 框架踩坑 + 编号资源预分配范式 | 跨"同栈"项目复用 | "schema SSOT 在 RuoYi 怎么落"、"snowflake 全链路 string" |
| **死文档**（`stacks/<stack>-notes.md`） | N=1 经验、还没法泛化的教训 | 攒着，够 2 个项目再抽成插件 | `ruoyi-notes.md`（dongjiaoshan 实战教训） |

**反过度抽象（Kevin 红线）**：N=1 的栈经验**先留死文档**，不要提前做成"插件框架"。等同栈第 2 个项目来了、确认这条经验复现，再从死文档蒸馏成插件。`ruoyi-notes.md` 现在就是这个状态。

---

## 1. 插件 = 三样东西

一个成熟的栈插件（如未来的 `nextjs-fastapi-plugin/`）应当包含且只包含：

### ① 金标准片段（golden snippet）
该栈下"三件 SSOT"的**可直接复制的落地骨架**，对应 generic 模板里的抽象概念：

| generic 概念 | 栈实例（举例） |
|---|---|
| 冻结 schema SSOT（SP1 三件之一） | RuoYi：建表 DDL 6 件套 + MyBatis generator；Next+FastAPI：Prisma schema 或 OpenAPI + Zod |
| 共享组件 + design token + 真截图锚定 | web：Figma Code Connect；小程序：微信开发者工具 CLI 截图 diff |
| 机器可验收 checkbox | 验收 SQL / API 契约测试 / Playwright E2E |

金标准片段是"按这个抄就对"，不是"这是唯一真理"——它是**强默认**（设计文档"强默认 + 可关"哲学），有更合适的写法可以偏离，但偏离要在 ticket §N 写明原因。

### ② 框架踩坑清单（gotchas）
该栈/第三方框架底座**已经踩过的坑** + 自检命令。这是插件最值钱的部分——它把"排查 7 轮才钉死的根因"变成开工前一行 grep。每条坑的格式：

```
症状 → 根因 → 正确写法 → 自检命令（grep/SQL）
```

### ③ 编号资源预分配范式（resource pre-allocation）
多 agent 并行写代码时，**共享命名空间的撞号防御**。这是"隔离并行多 agent"在有共享底座时的关键机制（设计文档 §2.2）。范式 = 开工前把命名空间切成段，每个 ticket 在 prompt 里写"你用哪段"，agent 不能跨段占用。

栈无关的"为什么"（防止并行 agent 写同一张菜单表 / 同一个迁移序号撞车）写在 generic 模板的 `<ID_NAMING>` / `<MIGRATION_DIR>` 概念里；**具体怎么切段**（RuoYi 的 `menu_id` 5000-10999 分域、Flyway `V<yyyyMMddHHmm>` 时间戳排序）是栈细节，写在插件。

---

## 2. /new-project 怎么用插件

`/new-project`（实例化脚本）流程里，选栈那一步：

1. cp generic 模板 → `freelance/projects/<<PROJECT_NAME>>/.claude/` + `doc/`
2. **按所选栈拷对应插件**进项目（如 `cp -r stacks/nextjs-fastapi-plugin/* <project>/doc/stack/`）
3. init 替换占位符：把 `PROJECT.md` 里的 `<<STACK_BACKEND>>` / `<<DB>>` / `<<MIGRATION_DIR>>` 等填成真值——**只在 PROJECT.md 填一次**（单一变量源，anti-drift），插件和其他文件引用概念不重抄值
4. 栈插件里的金标准片段 → 进项目的 schema SSOT 骨架；踩坑清单 → 进对应 `coder-*` skill 的"开工前必读"

**关掉条件**：项目栈不在已有插件里 → 不拷任何插件，generic 模板照跑（三件 SSOT 退化为人工 review，没有 CI 漂移检查），项目结束时把新栈的经验沉成一份 `<newstack>-notes.md` 死文档，攒第 2 个项目再抽插件。

---

## 3. 现有内容

| 路径 | 类型 | 状态 |
|---|---|---|
| `ruoyi-notes.md` | 死文档（N=1 实战教训） | dongjiaoshan 沉淀，含建表 DDL 6 件套、Flyway 分段、menu_id 域段、软删退路、uni-app 踩坑、role 白名单、`_post-init.sh` 清缓存 |
| `skills/coder-mp-implementation-checklist.md` | ruoyi-specific skill | uni-app + wot-design-uni 实施 checklist |
| `skills/coder-djs-cross-layer-contract.md` | ruoyi-specific skill | 5 类跨层契约（snowflake / 业务码 / DDL 必含 / OSS bizType / mp+admin 配对） |
| `skills/coder-mp-entity-cache-test.md` | ruoyi-specific skill | MyBatis-Plus ServiceImpl 单测 entity cache 预热 |

> `skills/` 里 3 个 skill 文件头都标了 **"ruoyi-specific，非 generic；放栈插件不放通用模板"**。它们是 dongjiaoshan 抽出来的，跨"同栈"（RuoYi-Vue-Plus + uni-app）项目可直接复用；换栈不适用。

### 预留
- `nextjs-fastapi-plugin/` —— web 栈（Prisma/OpenAPI+Zod schema、Figma Code Connect 视觉锚定、Playwright E2E 验收、迁移序号预分配）。**等第一个 Next+FastAPI 项目落地时建**，不提前空写。
- 其他栈按需新增。

---

## 4. 给 generic 模板的反向约束（写插件时遵守）

- 不要把任何栈的 import 路径 / 模块名 / 框架类名写进 generic 模板——那些只能出现在 `stacks/`。
- generic 模板里凡涉及"具体怎么落地"的地方，用占位符引导读者来 `stacks/`：例如 schema SSOT 段写 `按 <<STACK_BACKEND>> 的金标准片段落地（见 stacks/<stack>-plugin）`。
- 插件升级（项目结束反哺）只回写**已复现 ≥2 次**的经验；一次性的留在死文档。
