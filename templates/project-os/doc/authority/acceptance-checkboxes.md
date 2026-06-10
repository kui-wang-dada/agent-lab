# <<PROJECT_NAME>> — Ticket 机器可验收 Checkbox（SSOT ③）

<!-- 这是 SP1 三件 SSOT 的第三件，也是 SP1 → SP2 的齿轮：每个 ticket 的验收标准翻成机器可验证的 checkbox，-->
<!-- AI 实现前先写、failing 不进下一步，且能被 SP2 的 hook 机械验证。 -->
<!-- 治什么病：dongjiaoshan 复盘第三返工源——"pig_status 双字段 + Verification Gap"。-->
<!-- 根因：验收标准是人话（"猪状态对就行"），没翻成可机器判定的断言（含期望值的 SQL/接口断言）；-->
<!-- 于是同一语义被实现成两个字段、谁也没发现，直到联调才暴露 = Verification Gap。 -->
<!-- 设计核心（Kevin 拍板）：SP1 产出是"机器可验的 SSOT"，验收不是写完再补，而是实现前先写、且直接成为 Stage2 gate。 -->

---

## 0. 头部声明（验收契约元数据 —— 必填）

| 项 | 值 |
|---|---|
| **上游（验收标准从哪来）** | 需求拆解（冻结版）+ `schema-ssot.md`（列类型/枚举期望值）+ `components-ssot.md`（视觉期望） |
| **下游（验收喂给谁）** | SP2 执行机：每个 ticket 实现前先把本文件对应段的 checkbox 写成 failing；SP2 的 verify hook 机械跑这些断言，全绿才算 done |
| **冲突优先级** | 本文件验收断言 > ticket prompt 口语描述。断言与实现冲突 → 实现错，不是断言错（除非 CR 改断言） |
| **机器可验性要求** | 每条 checkbox 必须可被一条命令/SQL/接口调用判定 true/false；含期望值。**禁止**写"看起来对""大致正确"这类人判定 |

---

## 1. 为什么"机器可验收"是硬要求（设计依据，勿删）

<!-- 这一段解释机制，让填表人/AI 不要退化成写人话验收。 -->

- **人话验收 = Verification Gap**：dongjiaoshan 的 pig_status 双字段问题，就是验收停在"状态显示正确"这种人话上——人话无法机械判定"是不是一个字段、值是不是来自权威枚举"。
- **机器可验 = failing-first + hook gate**：把验收翻成"跑这条 SQL 应得这个值""调这个接口应返回这个结构"，AI 实现前先让它 fail，实现到全绿才算完。SP2 的 hook 直接跑这些断言当 gate（齿轮咬合点）。
- **含验收 SQL 的期望值**：断言必须带**期望值**，不是"查得到就行"。`SELECT COUNT(*) ... = 1`、`列类型 = DECIMAL(12,3)`、`枚举值 ∈ {schema-ssot §3 的集合}`——期望值是机器判定的依据。

---

## 2. 单 Ticket 验收模板（每个 ticket 复制一段）

<!-- 颗粒度判定见 SP1-pipeline.md：大型核心业务走全套；2 小时级机械改可只写 §2.1 几条关键断言，不必铺满。 -->

### `<<TICKET-ID>>` — <<ticket 标题>>

**关联业务流**：`business-flow.md §<<X>>`
**关联 schema**：`schema-ssot.md §<<Y>>`（涉及表/字段/枚举）
**关联视觉**：`components-ssot.md §<<Z>>`（涉及页面/真截图，若有 UI）
**实现前置**：本段所有 checkbox 先写成 failing；全绿才允许 SP2 标 done。

#### 2.1 Schema / 数据层断言（机器可验，含期望值）

<!-- 这是治 pig_status 双字段的关键：把"这个语义就一个字段、类型对、枚举来自权威"写成可跑的断言。 -->

```sql
-- [ ] AC-1 字段存在且类型正确（防双字段/类型漂移）
--   断言：<<table>>.<<col>> 类型 = <<期望类型，引 schema-ssot §Y>>
--   验证：<<栈对应的列类型查询，见 §5>> → 期望 = '<<期望类型>>'

-- [ ] AC-2 枚举值受控（防自造字典 / 防 dict 撞墙）
--   断言：<<table>>.<<col>> 的全部出现值 ⊆ schema-ssot §3 的 <<dict_key>> 集合
SELECT DISTINCT <<col>> FROM <<table>>
  WHERE <<col>> NOT IN (<<schema-ssot §3 枚举值列表>>);
--   期望：0 行（出现行 = 用了权威外的值 = fail）

-- [ ] AC-3 业务规则落地（含期望值，举例：状态流转/唯一性/外键完整）
SELECT COUNT(*) FROM <<table>> WHERE <<违反业务规则的条件>>;
--   期望：= 0
```

> **为什么逐条带 SQL + 期望值**：让 SP2 hook 能直接执行、机械判定。没有期望值的断言等于没断言。

#### 2.2 接口 / 契约断言（API/服务层）

```
- [ ] AC-4 <<接口>> 入参 <<X>> → 期望返回 <<结构/状态码/字段>>（引 schema-ssot 字段定义）
      验证：<<curl/契约测试调用>> → 断言 <<期望>>
- [ ] AC-5 <<错误路径>> → 期望统一错误结构 <<{ error_code, message, details }>>
```

#### 2.3 视觉 / 交互断言（有 UI 时，引 components-ssot）

```
- [ ] AC-6 页面用了 components-ssot §4 指定的共享组件 <<组件名>>，未手写原生控件
      验证：<<grep 实现文件确认引用 / 截图 diff vs 真截图>>
- [ ] AC-7 关键交互按真截图（components-ssot §2 行 <<页面>>）实现，无 §6 已知偏离
```

#### 2.4 安全 / 权限断言（B 端一等公民，有租户/权限/支付时必填）

<!-- 为什么单列：设计文档把 security 列为 SP2 一等公民。B 端有 tenant/权限/支付，越权/漏租户隔离是高危。-->
<!-- 在验收层就钉死"隔离列必带、权限注解必加"，比 SP2 才发现强。 -->

```
- [ ] AC-8 所有查询带范围隔离（引 schema-ssot §1.2 隔离列）：
SELECT COUNT(*) FROM <<相关查询的代码扫描>> WHERE <<缺隔离条件>>;  -- 期望：0
- [ ] AC-9 写接口有权限校验（角色/数据范围注解存在）
```

> **关掉条件**：无多租户/无敏感权限的内部工具/单用户应用 → §2.4 可删。但凡有客户数据隔离/支付，**不准关**。

---

## 3. failing-first 纪律（实现前先写、failing 不进下一步）

<!-- 这是 TDD 思想在验收层的落地，也是 SP1→SP2 的齿轮纪律。 -->

1. 拆到某 ticket → **先**填本文件该 ticket 段的全部 checkbox（带期望值的断言）。
2. 把断言落成可执行的 failing 验证（SQL 脚本 / 契约测试 / grep 检查）。
3. AI 实现该 ticket。
4. SP2 verify hook 跑全部断言 → 必须全绿才允许标 done。
5. 任一条 failing → ticket **不进下一步**（不合 PR、不进下一个 D<N>）。

> **为什么 failing-first**：先写期望、再实现，逼着把"做完什么样算对"想清楚——这正是 dongjiaoshan 缺的前置验收契约。

---

## 4. 成为 SP2 hook gate（齿轮咬合点）

<!-- 解释本文件如何被 SP2 机械消费，别让它退化成"人看的清单"。 -->

- 本文件每个 ticket 段的断言集 → SP2 在该 ticket 的 verify 阶段被 hook 自动拉取并执行。
- hook 执行方式（按栈，见 §5）：跑 SQL 脚本 / 契约测试 / lint+grep；任一非 0 退出 → gate fail。
- gate fail 的 ticket：禁止 merge、禁止进入 closing。
- 这是 SP1（写断言）→ SP2（机械执行断言）的咬合点，使"验收"从人力活变成机械活，关掉 Verification Gap。

---

## 5. 按栈落地（断言怎么变成可执行验证 —— 栈是实例）

| 栈 / 层 | Schema 断言（§2.1） | 接口断言（§2.2） | 视觉断言（§2.3） |
|---|---|---|---|
| **`<<DB>>`** | 从元数据查列类型（如 `information_schema.columns`）；`SELECT ... WHERE 违规` 期望 0 行 | - | - |
| **后端 `<<STACK_BACKEND>>`** | 迁移后跑 SQL 脚本断言；列类型 dump 比对 | 本栈契约测试；统一错误结构断言 | - |
| **前端 `<<STACK_FRONTEND>>`** | 消费 API，断言走接口层 | 同上 | 实现页截图 diff vs 真截图 / 组件引用 grep |
| **移动/小程序 `<<STACK_APP>>`** | 消费 API，断言走接口层 | 同上 | 本栈对应工具截图 diff vs 真截图 |

> **填表说明**：每栈把"断言→执行手段"映射到本栈工具，具体写法/命令落 `stacks/<<本栈>>-notes.md`，本表只给映射入口。
> （示例：Java 栈接口断言可用 MockMvc、视觉可用 Playwright/微信 CLI 截图；Next+FastAPI 栈可用 OpenAPI 契约测试 + pytest httpx + Zod/Pydantic schema 校验——均为示例，按本栈落地。）

---

## 6. 验收覆盖总表（全 ticket 一览 —— GATE 检查项）

<!-- GATE 判据之一：每个在范围内的 ticket 都必须在此表有行且 checkbox 已写。空行 = GATE 不过。 -->

| Ticket | 关键断言数 | 含安全断言? | 验收脚本就绪? | 状态 |
|---|---|---|---|---|
| `<<TICKET-ID>>` | `<<N>>` | `<<Y/N/NA>>` | `<<Y/N>>` | `<<未写/已写failing/全绿>>` |
