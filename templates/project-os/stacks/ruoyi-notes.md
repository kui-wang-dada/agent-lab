# ruoyi-notes.md —— RuoYi-Vue-Plus + uni-app 实战教训（死文档，N=1）

> **性质**：这是 dongjiaoshan（RuoYi-Vue-Plus + plus-ui + uni-app + MySQL，5 域 / 66 ticket / 3-5 AI 并行写）的**实战教训沉淀**，不是插件框架。
>
> **为什么是死文档而不是插件**：N=1。这些教训目前只在一个项目复现过。按反过度抽象红线（见 `stacks/README.md` §0），等同栈第 2 个项目确认复现，再蒸馏成 `ruoyi-vue-plus-plugin/`。在那之前：开新 RuoYi 项目时**整篇读一遍当 checklist**，命中哪条就抄哪条。
>
> **占位约定**：本文是栈实例，写真实的 RuoYi 类名/列名是对的（栈细节就该具体）。但项目专属业务值（域名/模块名/具体字段/role_id 段/客户业务）一律用占位符——换个 RuoYi 项目这些会变。占位符权威值在项目 `PROJECT.md`。
> - `<<DOMAINS>>` 业务域列表 · `<<BUSINESS_MODULE_PATHS>>` 业务模块子树 · `<<MIGRATION_DIR>>` 迁移目录 · `<<DB>>` 库名
> - `<<PROJECT_PREFIX>>` 项目业务前缀（dongjiaoshan 是 `djs`，换项目换前缀）

---

## 0. 栈底座速记（什么不能碰）

RuoYi-Vue-Plus 是第三方框架底座，分四层：`ruoyi-common`（24 个横切子模块）→ `ruoyi-modules`（业务）→ `ruoyi-admin`（唯一可执行 jar）→ `ruoyi-extend`（独立伴生服务）。

- **底座源码只读**（`<<FRAMEWORK_BASE_PATHS>>` 在 settings.json deny）。业务代码只写在 `ruoyi-modules/ruoyi-<<PROJECT_PREFIX>>-*/`（`<<BUSINESS_MODULE_PATHS>>` 在 allow）。
- 横切能力（加密 / 翻译 / 脱敏 / Excel / OSS / 多租户 / 幂等 / 限流 / SSE）**已有现成子模块，不要在业务模块重造**。写横切功能前先去 `ruoyi-demo` 找示例。
- 新 CRUD **优先用 `ruoyi-generator` 生成脚手架**（同时产出 Java + Vue），再定制，不要手抄样板。
- 业务模块之间**不互相依赖**（避免循环依赖）。跨域调用走「`ruoyi-<<PROJECT_PREFIX>>-common` 放 interface + DTO」+ Spring 注入实现。`-common` 共享层**只放 contract，不放业务实现**。
- 权限：后端 `@SaCheckPermission("module:resource:action")`，前端 `v-hasPermi` 同字符串——**两边必须同步**。

---

## 1. 金标准建表 DDL（6 件套 + tenant + del_unique 软删退路）

> 治"65 表审计字段列类型错（437 行 patch）"的根。**所有业务表无一例外按此模式建。**

```sql
CREATE TABLE t_<域>_<业务>_<类型> (
    id              BIGINT       NOT NULL COMMENT '主键',
    -- 业务字段...
    tenant_id       VARCHAR(20)  NOT NULL DEFAULT '1001' COMMENT '租户编号',  -- 注①
    create_dept     BIGINT                                COMMENT '创建部门',  -- 审计 6 件套 ↓
    create_by       BIGINT                                COMMENT '创建者',
    create_time     DATETIME                              COMMENT '创建时间',
    update_by       BIGINT                                COMMENT '更新者',
    update_time     DATETIME                              COMMENT '更新时间',
    remark          VARCHAR(500)                          COMMENT '备注',
    del_flag        CHAR(1)      NOT NULL DEFAULT '0'     COMMENT '删除标志',
    del_unique      BIGINT       NOT NULL DEFAULT 0       COMMENT '软删唯一性辅助',  -- 注②
    PRIMARY KEY (id),
    UNIQUE KEY uk_<biz>_tenant (tenant_id, <biz_field>, del_unique)               -- 注③
) ENGINE=InnoDB COMMENT='<业务描述>';
```

**关键约束（每条都踩过坑）**：

- **注①** `tenant_id VARCHAR(20)`，**不是 BIGINT**——要对齐 ruoyi `TenantEntity.tenantId`（String）。INSERT 不显式赋 tenant_id，走 `InjectionMetaObjectHandler.insertFill` 自动填。V1 全是 `'1001'`，V2 启用多租户拦截器时不用改表。
- **注②③ 软删唯一性退路（核心机制）**：`del_unique BIGINT NOT NULL DEFAULT 0`，且**所有 UNIQUE 索引必须以 `del_unique` 收尾**，含 `tenant_id`。
  - 原方案想用 MySQL 8 GENERATED VIRTUAL 列 `del_unique BIGINT GENERATED ALWAYS AS (IF(del_flag='0',0,id)) VIRTUAL`——**落地翻车：MySQL 8 不允许 GENERATED 列引用 AUTO_INCREMENT 主键（ER 3109）**。
  - 退路 = 普通列 `DEFAULT 0` + **应用层 fill**（见 §4 MetaObjectHandler）：软删时 `del_unique = id`。
  - 为什么不能直接拿 `del_flag` 进 UNIQUE：`del_flag` 只有 '0'/'1'，多行被软删后仍冲突。`del_unique`（已删行=id，未删行=0）保证已删除行 key 互不重复、新数据可插入。
  - 为什么不用 PostgreSQL 部分唯一索引：MySQL 8 不支持（除非函数索引，可读性差）。
- **禁止字段级 UNIQUE** 写法（`xxx_no VARCHAR(32) UNIQUE`）——必须写成命名 `UNIQUE KEY` 且含 `del_unique`。
- **例外**：统计预聚合表（定时任务重算、truncate+重写的）**不要 del_flag / del_unique / version**——它们不软删。

**review 硬门槛**：建模 ticket review 时，任一 UNIQUE 索引不含 `del_unique` → review 不过。

**自检 SQL**：
```sql
SELECT COLUMN_NAME FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='<<DB>>' AND TABLE_NAME='<your_table>'
  AND COLUMN_NAME IN ('tenant_id','del_flag','del_unique','create_by','update_by');
-- 期望 5 行
```

---

## 2. Flyway / DDL 文件 `V<yyyyMMddHHmm>` 模块分段（防多 agent 撞迁移序号）

> 这是"编号资源预分配范式"的 RuoYi 实例（见 `stacks/README.md` §1③）。多个 agent 同日并行写 DDL，靠时间戳排序 + 分钟去重防撞。

**命名**：所有 DDL 放 `<<MIGRATION_DIR>>`（dongjiaoshan 是 `script/sql/<<PROJECT_PREFIX>>/`），文件名

```
V<yyyyMMddHHmm>__<TICKET-ID>-<short-desc>.sql
例：V202605200900__SYS-INIT-001-create-business-tables.sql
    V202605211030__BRD-MD-002-farm-barn-pen.sql
```

- 文件名 timestamp **不是创建时间，是"预期上 staging 的顺序"**——所以初始化建表 ticket 必须用最早时间戳。
- 同一天多个 ticket → 精确到分钟（HHmm）；**同窗口**多 agent 同分钟撞了，AI 自行调到下一分钟（同窗口能看到已选的号）。
- **★并行 worktree 场景（多窗口跑多天）**：各 worktree 从同一 dev 切、**互相看不到对方选的时间戳**，"撞了再 +1 分钟"失效（都从同一基线起算，极易选同号）→ 必须**开跑前给每个并行天/分支预占一段不重叠的 HHmm 区间**（如 `day1=0900-0959 / day2=1000-1059 / day3=1100-1159`），写进各天 `README.md` 顶部，agent 只在本段内选号。这是并行 merge 不撞 Flyway 号的关键（呼应 `daily/README.md §1.5` 的"按天预分段"）。
- **没有回滚**：文件名末尾不加 `.down.sql`。

---

## 3. menu_id / role_id 域段预分配（sys_menu / sys_role 撞号防御）

> 同上，编号预分配范式实例。业务菜单要 INSERT 进 ruoyi 自带 `sys_menu`，多 ticket 各加自己的菜单，靠**段分配**防撞。

**menu_id 段**（值是项目专属，权威在 `PROJECT.md`；这里写 dongjiaoshan 实例当范式参考）：

| 段 | 用途 |
|---|---|
| 1-2000 | ruoyi 自带菜单（占用） |
| 3000-4999 | 留给 ruoyi 未来升级吃掉（不要碰） |
| 5000+ 起按域切 1000 一段 | 每个 `<<DOMAINS>>` 一段（系统底座 / 通用主数据 / 各业务域 / 门店追溯 / 预留扩展） |

**规则**：每个 ticket 的 prompt 里写明「你的 menu_id 用 XXXX-XXXX」，**agent 不能跨域占用**。

**role_id 段**：业务角色 INSERT `sys_role`，从 101 起按域/岗位编号（dongjiaoshan 用 101-112 共 12 个业务角色 + ruoyi 自带 `superadmin` role_id=1）。同样在 PROJECT.md 定权威段。

**跨域共享 sys_* 表的写入纪律**（防并行 agent 同改一张表）：
- 第 1 天：建模 ticket **独占** `sys_user` / `sys_role` / `sys_menu` 的扩字段操作，其他 ticket 当天不能 alter `sys_*`。
- 第 2 天起：`sys_dict_data` 多 ticket 各加自己字典，用 **INSERT IGNORE 防撞**。
- `sys_menu` 多 ticket INSERT 各业务菜单，靠 menu_id 段防撞。

---

## 4. DjsMetaObjectHandler —— 软删 del_unique 应用层退路（§1 注②的实现）

GENERATED 列方案翻车后的退路：自定义 `MetaObjectHandler` 继承 ruoyi 的 `InjectionMetaObjectHandler`，加 `@Primary` 让 MyBatis-Plus 优先注入本实现。

**机制**：`updateFill()` 里先 `super.updateFill()`（ruoyi 默认填 updateTime/updateBy），再检测 `delFlag='1'` → 把 `id` 同步写进 `delUnique`（`updateStrategy=NOT_NULL` 会带进 SQL SET）。

**业务实体使用约束**：
- 有软删场景（带 `@TableLogic` 的 `delFlag`）的实体，**必须同时声明 `Long delUnique`** 字段（对应 DB `del_unique BIGINT NOT NULL DEFAULT 0`）。
- `delUnique` 不需要 `@TableField(fill=...)` 注解——Handler 直接 `setValue`。
- 不带 del_unique 的实体（`sys_*` / 统计预聚合表）Handler 自动跳过（`hasSetter` 判空）。
- Handler 内部异常**只 warn 不抛**（不打断主 UPDATE 流）。

**为什么必须有这层**：不 fill 的话软删后 `del_unique` 一直是 0，已删除行仍参与唯一性校验，新数据插不进去。

---

## 5. 字典缓存退路 `_post-init.sh`（清 Redis 两类缓存）

> 治"dict 撞墙 4 次"里的缓存粘滞那一类。初始化/升级跑完 DDL 后、首次启动 admin 前必跑。

两类要清的 Redis key：
1. **ruoyi 自带 NullValue 粘滞（`*:sys_dict`）**：清库阶段 DELETE/TRUNCATE 了 `sys_dict_*`，如果 admin 在这之前启过哪怕 1 次，Redisson 字典缓存会把"查空"按 NullValue 写进 `1001:sys_dict`（TTL 1h）。SQL 重新灌回数据后，缓存仍返 NullValue 到自然过期 → 表现为 admin 字典下拉空。
2. **业务字典聚合缓存历史残留（`*<<PROJECT_PREFIX>>:dict*`）**：早期把全量字典缓存到 `<<PROJECT_PREFIX>>:dict:full:1001` 等 key（TTL 1h），改字典后小程序仍返旧快照。现改实时聚合，此步清旧残留。

**脚本骨架**（环境变量可覆盖 `REDIS_CONTAINER` / `REDIS_PASSWORD`）：
```bash
#!/usr/bin/env bash
set -e
REDIS_CONTAINER="${REDIS_CONTAINER:-dev-redis}"
REDIS_PASSWORD="${REDIS_PASSWORD:-<redis-pass>}"
# 1) 清 ruoyi 字典 NullValue 缓存
docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning \
  --scan --pattern '*:sys_dict' \
  | xargs -I {} docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning DEL {} || true
# 2) 清业务字典聚合缓存残留
docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning \
  --scan --pattern '*<<PROJECT_PREFIX>>:dict*' \
  | xargs -I {} docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning DEL {} || true
```

**新增字典时的完整流程**：DDL 加 `sys_dict_type` + `sys_dict_data` 行 → 跑 `_post-init.sh` flush 缓存（不跑会 NullValue 缓存 1h）。字典 type 必须以 `<<PROJECT_PREFIX>>_` 开头（命名规范）。

---

## 6. uni-app / mp-weixin / wxss 踩坑清单

> 小程序端（uni-app + Vue3 + wot-design-uni）的"只在小程序复现、本地预览正常"那类坑——每条都排查多轮才钉死。

### 6.1 biz 组件必须直接 `.vue` 路径导入，禁运行时桶口
mp-weixin 编译器要直接 `.vue` 路径才能把组件映射成小程序自定义组件。**走桶口 `index.ts` re-export 运行时导入组件 → 该组件渲染成空白**（不报错，极难查）。
```ts
import DemandPicker from '@/components/biz/DemandPicker/index.vue'   // ✅ 组件走 .vue
import type { EntryFormFieldSchema } from '@/components/biz'         // ✅ 类型走桶口 OK（编译期擦除）
import { DemandPicker } from '@/components/biz'                       // ❌ 组件走运行时桶口 → 渲染空白
```
自检：`grep "import {.*} from '@/components/biz'"` 命中的非 `import type` 行 = 待修。

### 6.2 `:not()` / `*` 等复杂 CSS 选择器在 wxss 禁用
小程序 wxss 不支持部分复杂选择器（`*` 通配、`:not()` 等）。手写 style 模拟控件时会静默失效。**业务页用 `wd-*` 组件，不裸写 view+style 模拟**。

### 6.3 `<wd-datetime-picker>` 的 value 是毫秒时间戳，不是 'YYYY-MM-DD'
官方契约：`type="date"` 的 value 是 13 位毫秒时间戳，`min-date`/`max-date` 也是。后端业务字段（`LocalDate`）是 `'YYYY-MM-DD'` 字符串。**输入/输出两侧都要转，少一侧就翻车**：
- 输出没转 → 发毫秒给后端，Jackson 抛 `Invalid value for EpochDay`。
- 输入没转（直绑字符串） → picker 定位不到目标年，退回默认最小年（如 2016），用户只能选到 2016-2018。
```ts
const someTs = computed(() => ymdToTs(form.someDate))  // 输入侧：字符串→时间戳
function onConfirm(e){ form.someDate = toYmd(e.value) } // 输出侧：时间戳→字符串
```

### 6.4 数字输入禁 `<input type="number">`
原生 `type="number"` 会强制类型转换，截断 19 位 snowflake ID。用 `<wd-input type="digit" />` 收 string（详见 cross-layer-contract skill 契约 1）。

### 6.5 staging 部署只走【本地直传】，不要 push CI 自动 build
**部署唯一正路**：本地 `pnpm upload:mp --robot=1 --mode=staging`（本地 build + miniprogram-ci 上传）。**绝对不要用 ubuntu CI 自动 build+上传**。
- 症状：wot-design-uni 的 virtualHost 复杂组件（`wd-search`/`wd-picker`/`wd-tabs`）在**体验版真机** Shadow Root 渲染为空；简单组件正常；本地开发者工具预览正常 → 极难定位。
- 隔离实验决定性结论：本地产物→任何上传 ✅；**CI(ubuntu) 产物→上传 ❌**。唯一坏变量是 ubuntu 构建环境产出的产物（疑似 `@uni-ku/bundle-optimizer` beta 版在不同 OS/node 下产出不同产物结构）。
- **方法论教训**：排查"只在某环境复现"先做**隔离实验缩小变量**再动手——这次连改 5 次配置全打偏，最后靠"两条上传路径 + 同机真机对比"一次锁定。不要轻信单次 workflow 的机制论结论，必须用产物 grep 自证。

### 6.6 LAN IP 漂移防御
mp 调本地后端，`env/.env` 的 `VITE_SERVER_BASEURL` 必须是当前机器 LAN IP，Mac 切 WiFi 会变。测试前自检（让 AI 跑，不进人力测试黑名单）：
```bash
EXPECTED=$(grep VITE_SERVER_BASEURL env/.env | head -1 | sed "s|.*'http://\(.*\):8080'.*|\1|")
CURRENT=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)
[ "$EXPECTED" = "$CURRENT" ] && echo "✅ 对齐" || echo "❌ 改 env/.env + 重 build"
```

---

## 7. Vue3 `useDict` 字典范式（admin plus-ui 端）

admin 端字典走 ruoyi 自带 `useDict('dict_type')` + pinia `dict` store 缓存，**不 per-page 拉、不 hardcode option**。mp 端走项目自建 `<DictPicker dictType="<<PROJECT_PREFIX>>_xxx" v-model="...">`，启动时全量拉一次缓存到 store。字典 type 一律 `<<PROJECT_PREFIX>>_` 前缀。

---

## 8. role 白名单 / `@SaIgnore` 匿名放行范式

公开/匿名接口（如对外追溯只读页、扫码查询）走 `@SaIgnore` 跳过 Sa-Token 鉴权，**而不是**给业务 controller 加白名单（避免误放行整个 controller）。dongjiaoshan 对外追溯 API 范式：`/<<PROJECT_PREFIX>>/public/trace/...` 走 `@SaIgnore` + Redis 缓存。

**退化登录态防御**：mp 端某些"操作人"字段（如打标人/测量人），若没有员工选择端点 → 取登录态 nickname 兜底；正解是补员工 applet 端点 + EmployeePicker 组件一次性解决多处（一次解决同根的多个 ticket，别逐个打补丁）。

---

## 9. VO 操作人翻译用 `USER_ID_TO_NAME`，不要 `USER_ID_TO_NICKNAME`
ruoyi 5.5.x 的 `ruoyi-common-translation` 只实现了 `UserNameTranslationImpl`（`TransConstant.USER_ID_TO_NAME`，输出 `user_name`）。`USER_ID_TO_NICKNAME` **没有 impl**——编译过但运行时翻译为 null。
```java
@Translation(type = TransConstant.USER_ID_TO_NAME, mapper = "operatorId")
private String operatorName;
```

---

## 10. 抽插件时的红灯（什么时候这份死文档升级成 plugin）

当**第 2 个 RuoYi-Vue-Plus + uni-app 项目**确认以下经验复现，把对应段从这里蒸馏进 `ruoyi-vue-plus-plugin/`：
- §1 DDL 6 件套 + §4 del_unique 退路 → 金标准片段（schema SSOT 落地骨架）
- §2/§3 编号预分配 → 编号资源预分配范式
- §6 uni-app 踩坑 + §5/§9 → 框架踩坑清单

在那之前保持死文档：复制粘贴 + 项目专属占位符替换即可，不做框架化。
