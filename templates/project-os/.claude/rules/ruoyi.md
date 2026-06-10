---
paths:
  - "ruoyi-modules/**"
  - "plus-ui/**"
  - "**/*.vue"
---

# RuoYi-Vue-Plus 硬约束（碰业务代码自动加载）

> 这是 stack 经验"自动落为 path-scoped rule"的目标格式（经验回流引擎低风险类落点）。
> **完整 checklist / 建表 DDL / 踩坑清单**在 [`../stacks/ruoyi-notes.md`](../stacks/ruoyi-notes.md)，本 rule 只留最高频的强约束。

- **底座只读，业务只写**：`ruoyi-common` / `ruoyi-modules/ruoyi-{system,generator,job,workflow}` 等框架底座**不动**（settings.json 已 deny）。业务代码只落 `ruoyi-modules/ruoyi-<<PROJECT_PREFIX>>-*/`。
- **横切能力用现成子模块**，不在业务模块重造（加密/翻译/脱敏/Excel/OSS/多租户/幂等/限流/SSE）。写横切前先去 `ruoyi-demo` 找示例。
- **新 CRUD 优先 `ruoyi-generator` 生成**脚手架（Java + Vue 一起出），再定制，不手抄样板。
- **业务模块间不互相依赖**：跨域走 `ruoyi-<<PROJECT_PREFIX>>-common` 放 interface + DTO + Spring 注入；`-common` 只放 contract 不放实现。
- **权限双写**：后端 `@SaCheckPermission("module:resource:action")` + 前端 `v-hasPermi` 同字符串，两边必须同步。
- **建表按 6 件套**：`tenant_id` + 审计 6 件套（create_dept/create_by/create_time/update_by/update_time/remark）+ `del_flag` 软删，无一例外。漏列 INSERT 即报错。
- **迁移落 `<<MIGRATION_DIR>>`**，Flyway `V<yyyyMMddHHmm>` 时间戳命名（多 agent 并行时各天预占段，见 stacks）。
