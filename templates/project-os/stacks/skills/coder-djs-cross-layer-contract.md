---
name: coder-cross-layer-contract
description: 跨层契约一致性（RuoYi + uni-app 全栈）。当 ticket 涉及 mp 表单提交 / 业务实体 ID 字段 / DDL 新建表 / OSS 新 bizType / mp 表单与 admin 列表配对时必读。覆盖 5 类核心契约：snowflake ID 序列化、业务码替代 ID、DDL 必含字段、OSS bizType 三端同步、mp+admin 配对 scope。
metadata:
  type: coder-knowledge
  stack: ruoyi-vue-plus + uni-app
  domains: [be, mp, admin, ddl]
---

> ⚠️ **ruoyi-specific，非 generic。** 本 skill 是 RuoYi-Vue-Plus + uni-app 栈插件的一部分（dongjiaoshan 抽出），**放栈插件 `stacks/skills/`，不放通用模板**。换栈不适用。这 5 条契约是该栈"前后端/多端一致性"的具体落地；generic 模板里对应的抽象概念是「冻结 schema SSOT + CI 漂移检查」。项目专属业务值（实体名/字段/库名）用占位符，权威值见项目 `PROJECT.md`；`<<PROJECT_PREFIX>>` = 项目业务前缀（dongjiaoshan 为 `djs`），`<<DB>>` = 库名。

# 跨层契约一致性（业务模块通用）

> 触发场景：任何涉及 mp 端提交、业务实体 ID 处理、新建业务表 DDL、新增 OSS bizType、mp 表单实施的 ticket。
>
> 实战教训：这 5 条契约在前 6 天出现了 4 次 S0 hotfix + 12 条 raise。**实施前必须逐条核对**——错一条意味着 mp 端不可用 / admin 数据丢失 / 追溯链断 / 用户输入截断。

---

## 契约 1：snowflake ID 全链路 string，不准 Number()

**问题**：JS `Number.MAX_SAFE_INTEGER = 2^53 = 9007199254740992`，ruoyi 默认 snowflake 是 19 位（>2^53），任何 `Number(idStr)` 都会**末位被截**。

**实施约束**：

- **后端**：Long ID 走 Jackson 默认序列化为 string（ruoyi `JacksonConfig` 已配 Long → String，**不要覆盖**）
- **TS 类型定义**（`miniapp/src/api/types/*.ts` + `plus-ui/src/api/*.ts`）：所有 ID 字段类型必须 `string`，**不准** `number`
  - `id: string` ✅
  - `id: number` ❌（会在 JSON.parse 时丢精度）
- **mp 表单**（uni-app + wot-design-uni）：
  - `<wd-input type="digit" />` 接 string，**不准** `<input type="number" />`（原生会强转）
  - body 字段类型 `string` 提交，**不准** `Number(form.xxxId)` / `+form.xxxId` / `Number.parseInt`
  - 必要时只做 `String(form.xxxId).trim()` 清空白
- **vitest 测试**：ID 字面量必须是 `'1001'` 不是 `1001`

**验证 SQL（DDL 实施后）**：
```sql
SELECT id, LENGTH(id) FROM <t_business_table> LIMIT 5;
-- 期望 LENGTH ≥ 18，且 mp 提交后 admin 列表能查到完整记录
```

**反例**：mp 表单用 `body.entityId = Number(form.entityId)`，工人输 `2058525064717926401`（19 位）→ 后端收到 `2058525064717926400`（末位 1 → 0）→ 抛 `not found` 500 错误。**多个 mp 表单全部踩坑**。

---

## 契约 2：mp 端业务实体一律用业务码二选一，不暴露 snowflake ID 给一线用户

**问题**：即使前端 ID 类型修对了 string，让一线用户手输 19 位数字本身就**不可用**——记不住、易输错。

**实施约束**：

- **mp 表单 ID 字段必须用业务码替代**（按本项目 `<<DOMAINS>>` 的实体定，权威见 `PROJECT.md`）：
  - 实体 → `<entityCode>`（业务编码，可读，如 "B01" / "P03" / 短码）
  - 供应商/关联实体 → `<refCode>`（编码二选一模式）
- **后端 BO 配套**：
  - BO 字段加 `<entityCode>?: string`（optional）+ `<entityId>?: string`（optional），二选一必填
  - service impl 入口加 3 行 resolve：若 id 空 → 用 `Mapper.selectIdByCode(code)` → 若仍空抛 `<entity>.not_found_by_code`
  - i18n key 配套：`<entity>.not_found_by_code` + `<entity>.id_or_code_required`（zh/en）
- **mp UI**：
  - label 用"<实体>编码"，**不用** "<实体> ID"
  - placeholder 给真实例子
  - input type="text" / "digit"，不用 "number"

**集成方向**：列表/搜索 API 落地后，回头改 mp 事件表单加 picker 组件（参考 UI 权威索引对应章节）。

---

## 契约 3：业务表 DDL 必含字段清单

**问题**：业务事件表全部漏 `del_unique`，与业务表全局约定不一致。

**DDL 必含字段（按顺序）**——金标准建表 6 件套，权威片段见 `stacks/ruoyi-notes.md §1`：

```sql
CREATE TABLE t_<域>_<业务>_<类型> (
    id              BIGINT       NOT NULL COMMENT '主键',
    -- 业务字段...
    tenant_id       VARCHAR(20)  NOT NULL DEFAULT '1001' COMMENT '租户编号',
    create_dept     BIGINT                                COMMENT '创建部门',
    create_by       BIGINT                                COMMENT '创建者',
    create_time     DATETIME                              COMMENT '创建时间',
    update_by       BIGINT                                COMMENT '更新者',
    update_time     DATETIME                              COMMENT '更新时间',
    remark          VARCHAR(500)                          COMMENT '备注',
    del_flag        CHAR(1)      NOT NULL DEFAULT '0'     COMMENT '删除标志',
    del_unique      BIGINT       NOT NULL DEFAULT 0       COMMENT '软删唯一标识',
    PRIMARY KEY (id),
    UNIQUE KEY uk_<biz>_tenant (tenant_id, <biz_field>, del_unique)
) ENGINE=InnoDB COMMENT='<业务描述>';
```

**关键约束**：
- `tenant_id VARCHAR(20)` 类型对齐 ruoyi `TenantEntity.tenantId` String（**不是** BIGINT）
- `del_unique BIGINT NOT NULL DEFAULT 0`——软删时由 `MetaObjectHandler.updateFill` update 为 id 值，让 UNIQUE 约束不冲突（机制详见 `stacks/ruoyi-notes.md §4`）
- INSERT 不显式赋 tenant_id（走 `InjectionMetaObjectHandler.insertFill` 自动）
- UNIQUE 约束**必含 tenant_id + del_unique**（V2 启用多租户拦截器时不冲突）

**自检 SQL**：
```sql
SELECT COLUMN_NAME FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='<<DB>>' AND TABLE_NAME='<your_table>'
  AND COLUMN_NAME IN ('tenant_id','del_flag','del_unique','create_by','update_by');
-- 期望 5 行
```

---

## 契约 4：OSS 新 bizType 必须三端同步

**问题**：新增凭证图 bizType，**只**改了 mp UI 但忘了后端白名单 + ts 类型。

**新增 OSS bizType 时 4 处必改**：

1. **后端白名单**：`ruoyi-<<PROJECT_PREFIX>>-common/.../service/impl/OssStsServiceImpl.java` 的 `ALLOWED_BIZ_TYPES` Set 加新值
2. **mp 类型**：`miniapp/src/api/types/oss.ts` 的 `OssBizType` literal union 加新值
3. **admin 类型**：`plus-ui/src/api/types/oss.ts`（如有）的 `OssBizType` literal union 加新值
4. **业务 BO 收口**：BO 加 `proofOssIds?: string` + DB 字段，service 写入 OSS 反查关联表（让详情页能反查凭证图）

**反例**：凭证图传到 OSS 成功，但 BO 没收 `proofOssIds` → ossId 是 dead-end，详情页无法展示凭证图。

**改完后必跑**：`mvn install ruoyi-<<PROJECT_PREFIX>>-common` + restart spring-boot（否则白名单不生效）。

---

## 契约 4.5：VO 操作人翻译用 `USER_ID_TO_NAME`，不要用 `USER_ID_TO_NICKNAME`

**问题**：`ruoyi-common-translation` 只实现了 `UserNameTranslationImpl`（对应 `TransConstant.USER_ID_TO_NAME`，输出 `user_name` 字段）。`USER_ID_TO_NICKNAME` 在 ruoyi 5.5.x 里**没有 impl**。

**实施约束**：业务 VO 的 `operatorName` / `createName` 等翻译字段：

```java
@Translation(type = TransConstant.USER_ID_TO_NAME, mapper = "operatorId")
private String operatorName;
```

**不要写** `TransConstant.USER_ID_TO_NICKNAME`——编译过但运行时翻译为 null。

---

## 契约 5：mp 表单 + admin 列表必须同 ticket scope

**问题**：subagent 写了 menu DDL 指向多个 admin vue 文件，但**实际只写了 mp 表单，admin 端 vue 全漏**。结果 admin 事件菜单点开全空白。

**实施约束**：

- **任何 mp 端业务功能 ticket**，scope 必须同时含：
  - mp 表单页（uni-app + wot-design-uni）
  - admin 列表页（plus-ui + Element Plus + BizTable）—— 如不需要独立列表，必须在 prompt 里**明确写出**"admin 端走统一 XX 台账，不为本事件做独立列表页"
  - 配套 menu seed DDL（component 路径 grep 验证 vue 文件存在）
- **mp 新建业务页**：必须同步加 `pages/<板块>/index.vue` 板块首页的入口卡片（详见 `coder-mp-implementation-checklist §3`）
- **DoD 自检**：admin 浏览器点 menu 不为空白；mp 板块首页能看到入口卡片

---

## 验收：本 ticket 5 项契约是否全过

ticket 实施完写 §N 完工总结时，**逐项标 ✅/N-A**：

```markdown
### 跨层契约自检
- [ ] 契约 1 snowflake → string：mp body / api types / vitest 全 string；input type=digit
- [ ] 契约 2 业务码替代 ID：mp UI 用 <entityCode>（如不涉及 ID 字段标 N/A）
- [ ] 契约 3 DDL 必含字段：tenant_id VARCHAR(20) / del_flag / del_unique / 6 个审计字段；UNIQUE 含 tenant_id+del_unique
- [ ] 契约 4 OSS bizType：如新增 bizType，3 端 + BO + DDL 5 处全改；mvn install + restart 已跑
- [ ] 契约 5 mp+admin 配对：admin 列表 vue 存在 / 或明确"走 XX 台账不独立列表"；mp 板块首页入口卡片已加
```

任一未 ✅ → STOP 报终审人。
