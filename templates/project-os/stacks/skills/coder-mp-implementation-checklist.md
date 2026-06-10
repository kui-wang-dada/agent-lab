---
name: coder-mp-implementation-checklist
description: 小程序（uni-app + wot-design-uni）实施 checklist。当 ticket 涉及 mp 端新建表单页 / 新建业务页 / 新建板块、改 mp 端 UI 交互、mp 端 API 类型定义时必读。覆盖 wot-design-uni 组件库使用、表单 schema 复用、板块首页入口管理、字典联动、i18n、拍照水印组件集成。
metadata:
  type: coder-knowledge
  stack: ruoyi-vue-plus + uni-app
  domains: [mp, fe]
---

> ⚠️ **ruoyi-specific，非 generic。** 本 skill 是 RuoYi-Vue-Plus + uni-app 栈插件的一部分（dongjiaoshan 抽出），**放栈插件 `stacks/skills/`，不放通用模板**。换栈（Next+FastAPI 等）不适用——通用工程原则（schema SSOT、共享组件锚定、验收 checkbox）在 generic 模板里，这里是该栈的具体落地。引用的项目专属业务值（域名/字典/字段）用占位符，权威值见项目 `PROJECT.md`；`<<PROJECT_PREFIX>>` = 项目业务前缀（dongjiaoshan 为 `djs`）。

# mp 端实施 checklist（uni-app + wot-design-uni）

> 触发场景：小程序新建表单页 / 业务页 / 板块；改 mp UI 交互；mp API 类型定义；接入拍照水印上传。
>
> 实战教训根因：早期 mp 端 hotfix 4 次、视觉偏离审计发现表单全部偏离设计约定。这份 checklist 是 mp 实施的"开工前必读"。

---

## 1. 组件库强制：wot-design-uni（不准混用）

**业务页面**必须用 `wot-design-uni` 组件，不准手写 view + style 模拟：

| 控件 | wd-* 组件 | 不要用 |
|---|---|---|
| 单行文本 | `<wd-input />` | `<input type="text" />` 裸 |
| 数字输入 | `<wd-input type="digit" />` | `<input type="number" />`（**强制类型转换**会截断 snowflake） |
| 单选 | `<wd-radio-group />` | `<view @click=...>` 模拟 |
| 字典下拉 | `<wd-picker />` | hardcode `<wd-radio-group>` |
| 日期 | `<wd-datetime-picker />` | 自己拼 input |
| 按钮 | `<wd-button type="primary">` | `<button>` |
| Toast | `useToast()` + `toast.success(...)` | `uni.showToast` |
| 模态 | `useMessage()` + `messageBox.confirm(...)` | `uni.showModal` |
| 卡片 | `<wd-card />` | view + box-shadow |
| 表格 | `<wd-table />`（如需） | view + flex 模拟 |

**例外**：`src/components/biz/` 下项目自建组件（拍照水印 / EntryForm / 各 Picker 等）必须复用，**不准在业务页里 inline 实现**。

### 1.1 biz 组件必须直接 .vue 路径导入，禁运行时桶口（血泪教训）

mp-weixin 编译器要直接 .vue 路径才能把组件映射成小程序自定义组件。**通过桶口 `@/components/biz` 的 index.ts re-export 运行时导入组件 → 该组件在模板里渲染成空白**（页面其他部分正常，只这个组件不显示，且不报错，极难排查）。多个 picker 页全踩过这坑。

```ts
// ✅ 正确：组件走直接 .vue 路径
import DemandPicker from '@/components/biz/DemandPicker/index.vue'
import EntryForm from '@/components/biz/EntryForm/index.vue'
// ✅ 类型走桶口没问题（编译期擦除，不触发运行时求值）
import type { EntryFormFieldSchema } from '@/components/biz'

// ❌ 错误：组件走运行时桶口 → mp 下渲染空白
import { DemandPicker, EntryForm } from '@/components/biz'
```

**自检**：`grep "import {.*} from '@/components/biz'"` 命中的非 `import type` 行 = 待修。

### 1.2 `wd-datetime-picker` 的 value 是**毫秒时间戳**，不是 'YYYY-MM-DD'——输入/输出两侧都要转（血泪教训）

官方契约：`<wd-datetime-picker type="date">` 的 value 是 **13 位毫秒时间戳**（`ref<number>(Date.now())`），`min-date`/`max-date` 也是时间戳。后端业务字段（`LocalDate`）是 `'YYYY-MM-DD'` 字符串。两边类型不一致，**两侧都要转**，少一侧就翻车：

- **输出侧没转**：选完日期把毫秒原样发后端 → `JSON parse error: Invalid value for EpochDay ... 1451577600000`（Jackson 把毫秒当 EpochDay）；还拿它做字符串比较（`a > b`）会 number vs string 失效。
- **输入侧没转**（把 'YYYY-MM-DD' 字符串当 model-value 传）→ picker 解析不了、**定位不到目标年、退回默认最小年（如 2016）**，用户只能选到 2016-2018。

```vue
<!-- ❌ 全错：v-model 直绑字符串字段（输入侧定位到 2016 + 输出侧发毫秒报 EpochDay） -->
<wd-datetime-picker v-model="form.someDate" type="date" />

<!-- ✅ 正确：model-value 传时间戳 + min/max 时间戳窗口；@confirm 转回 'YYYY-MM-DD' 存字段 -->
<wd-datetime-picker
  :model-value="someTs" :min-date="pickerMin" :max-date="pickerMax"
  type="date" @confirm="onSomeDateConfirm" />
```
```ts
import { pickerMaxTs, pickerMinTs, toYmd, ymdToTs } from '@/utils/date'
const someTs = computed(() => ymdToTs(form.someDate))   // 输入侧：字符串 → 时间戳（定位正确年份）
const pickerMin = pickerMinTs()                          // 去年初 ~ 明年末窗口
const pickerMax = pickerMaxTs()
function onSomeDateConfirm(e: { value: string | number }) {
  form.someDate = toYmd(e.value)                         // 输出侧：时间戳 → 'YYYY-MM-DD'
}
// 提交边界再兜一层（defense-in-depth）：someDate: toYmd(form.someDate)
```

**自检**：`grep -n "wd-datetime-picker" src/pages/**/*.vue` → 凡绑日期字段的，检查 ① model-value 是不是时间戳（不是字符串）② 有没有 @confirm + toYmd ③ 有没有 min-date/max-date。三者缺一即待修。`src/utils/date.ts` 备 `toYmd` / `ymdToTs` / `pickerMinTs` / `pickerMaxTs`。

---

## 2. 表单页 schema 化（按业务分类的 EntryForm 模板）

**问题**：手写表单结构、提交逻辑、loading 态、错误处理散落各页 → 严重违反共享组件约定，视觉/行为偏离。

**标准做法**：按 ticket 性质归类到几套 `EntryForm` 模板（字段共性抽出来），业务页只写 `<EntryForm :schema="schema" />`，**不直接拼 wd-* 组件**。分类按本项目 `<<DOMAINS>>` 的事件性质切（如：通用事件录入 / 终态事件 / 物料领用 / 调度工序 等），字段共性如「主体业务码 + 事件日期 + 凭证图 + 备注」。

**EntryForm schema 写法**：
```ts
const schema: FormSchema = {
  fields: [
    { key: '<bizCode>', label: '<主体业务码>', type: 'input', input: { type: 'text' }, required: true },
    { key: 'eventDate', label: '事件日期', type: 'datetime', required: true },
    { key: '<dictField>', label: '<字典字段>', type: 'dict', dictType: '<<PROJECT_PREFIX>>_xxx', required: true },
    { key: 'proofOssIds', label: '凭证图', type: 'camera', bizType: '<biz_proof>' },
    { key: 'remark', label: '备注', type: 'textarea' },
  ],
  submitApi: 'POST /<<PROJECT_PREFIX>>/<域>/event/<类型>',
  onSuccess: { toast: '<记录已保存>', back: true },
};
```

**复杂控件走 `#field-<key>` slot**：schema 的 type 枚举覆盖不了的字段（自定义业务 Picker / 拍照水印 / 级联字典器 / 关联其他表的 picker 等），在业务页用 `<template #field-<key>="{ model, update }">` 插入业务组件，**不要**回退手拼 wd-* + form。EntryForm 保留这部分字段的 schema.validator + required 校验链；业务页负责在组件里 emit 值 → 调 `update(v)` 回写到 form。

```vue
<EntryForm :schema="schema" v-model="form">
  <template #field-<bizCode>="{ model, update }">
    <BizPicker :model-value="model.<bizCode>" @update:model-value="update" />
  </template>
  <template #field-proofOssIds="{ model, update }">
    <CameraUploadWithWatermark biz-type="<biz_proof>"
      :model-value="model.proofOssIds" @update:model-value="update" />
  </template>
</EntryForm>
```

### 2.1 EntryForm SLOT_KEYS 扩展规则

mp 平台限制：`<slot :name="key">` 不支持动态字面量绑定，必须静态枚举。每个新业务 picker 字段都要在 `EntryForm/index.vue` 的 `SLOT_KEYS` 常量加一行 + template 加一个 `<view v-if="field.key === 'xxx'">` 块。

**当前规则**：每 ticket 加 2-4 key 接受现状（务实，别提前抽象）。

**监控临界（关掉/升级条件）**：当 `SLOT_KEYS > 20` 个时升级到 v2 — 抽 `EntryFormWithSlots`（封装 slot 注入逻辑，或换 vue-jsx render function 解决静态绑定限制）。在那之前保持简单务实。

**反模式**：
- ❌ `<slot :name="field.key">` 动态绑定 — mp 平台编译阶段就报 unknown slot name
- ❌ 按 ticket scope 分文件 + auto-merge — 引入复杂构建，得不偿失
- ❌ 复用某个 generic slot（如 `extra1`/`extra2`）传 picker — slot 内容耦合 form 业务字段名，重命名时全场翻车

**触发抽 v2 的红灯**：
- SLOT_KEYS > 20 + 多个 picker 互相冲突
- mp 平台允许更动态 slot 后（关注 wot-design-uni / uni-app 版本升级 release note）

---

## 3. 板块首页入口卡片（mp 必加）

**问题**：各 ticket 完成自己的 mp 表单页，但**忘了改板块首页** `pages/<板块>/index.vue` 的 entries 数组 → 工人在 mp 端**根本到不了新加的页面**。

**强制约束**：mp 端**任何新加 page** 必须同步改对应 `pages/<板块>/index.vue` 的入口卡片数组：

```ts
// pages/<域>/index.vue
const entries = reactive([
  { group: '基础', items: [...] },
  { group: '<分组>', items: [
    { title: '<事件名>', icon: '<icon>', route: '/pages/<域>/event/<类型>/index' },  // <- 新加
    // ...
  ]},
]);
```

**DoD 自检**：mp 板块首页能直接点到本 ticket 的新页面，**不需要工人手输路由**。

---

## 4. 字典联动（wd-picker + dictType）

mp 端字典下拉必须用项目自建组件 `<DictPicker dictType="<<PROJECT_PREFIX>>_xxx" v-model="form.xxx" />`，**不准** 自己 hardcode option list。

字典查询路径（V1）：
- mp 端启动时全量拉 `/applet/dict/all` → 缓存到 pinia store
- DictPicker 组件从 store 读，**不 per-page 拉**
- 字典 type 必须以 `<<PROJECT_PREFIX>>_` 开头（命名规范，权威见 `<<ENUM_DICT_REF>>`）

新增字典时：
- DDL 加 sys_dict_type + sys_dict_data 行
- 跑栈插件 `_post-init.sh` flush Redis 字典缓存（不跑会 NullValue 缓存 1h，详见 `stacks/ruoyi-notes.md §5`）

---

## 5. 拍照水印上传组件集成

mp 端凭证图上传**必须**用项目自建组件 `<CameraUploadWithWatermark bizType="<type>" v-model="form.proofOssIds" />`，**不直接调** `uni.chooseImage` + `uni.uploadFile`。

实施时：
- bizType 必须在 OSS 白名单（参考 skill `coder-djs-cross-layer-contract` §契约 4）
- 后端 BO 必须收 `proofOssIds?: string` 字段
- DDL 必须有 `proof_oss_ids VARCHAR(500)` 或 OSS 反查关联表（让详情/列表页能反查凭证图）

**反例**：mp UI 接了凭证图组件，但后端 BO 没收 proofOssIds → ossId 传到 OSS 但与业务记录无关联 → 详情页查不到。

---

## 6. i18n（zh_CN + en_US 双份）

mp 端**所有**可见字符串必须 `t('xxx.yyy')`，配套：
- `src/locale/zh_CN.ts` 加 key + 中文
- `src/locale/en_US.ts` 加 key + 英文（即使 V1 只用 zh-CN，也必须双份，否则 TS 报缺 key）

错误提示 key 命名规范：
- `<domain>.<action>.<reason>`（例：`<entity>.not_found_by_<code>` / `<action>.<constraint>`）
- 不混 emoji

---

## 7. LAN IP 漂移防御

mp 调本地后端：`env/.env` 的 `VITE_SERVER_BASEURL` 必须是当前机器 LAN IP。Mac WiFi 切网会变。

测试前必跑（让 AI 在自动验证环节跑，**人力不跑**）：
```bash
EXPECTED=$(grep VITE_SERVER_BASEURL env/.env | head -1 | sed "s|.*'http://\(.*\):8080'.*|\1|")
CURRENT=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)
[ "$EXPECTED" = "$CURRENT" ] && echo "✅ 对齐" || echo "❌ 改 env/.env + 重 build miniapp"
```

---

## 8. mp 端 vitest 单测

业务逻辑型 ts 文件（api / utils）必须配 `.test.ts`：
- 配置 `vitest.config.ts` + `tsconfig.test.json`
- 测试覆盖：API 调用参数 / 响应类型 / utils 函数边界
- 不测 vue 组件渲染（成本高、价值低，让真机人力验收）

跑命令：`cd miniapp && pnpm test`

---

## 9. 实施完工验收（ticket §N 完工总结必勾）

```markdown
### mp 实施 checklist
- [ ] 1. 组件全用 wd-* 或 components/biz/*，无手写 view+style 模拟控件
- [ ] 2. 表单页用 EntryForm schema，未直接拼 wd-* 组件
- [ ] 3. 板块首页 entries 数组已加新页入口卡片
- [ ] 4. 字典用 DictPicker（如涉及）
- [ ] 5. 凭证图用 CameraUploadWithWatermark，BO 收 proofOssIds（如涉及）
- [ ] 6. i18n 双份（zh_CN + en_US）
- [ ] 7. LAN IP 检查（让 AI 在自动验证环节跑，**不在人力测试**）
- [ ] 8. vitest 配套（如涉及业务逻辑 ts）
```

任一未 ✅ → 标 ⚠️ 在 reports + raise 到 _open-issues。

---

## 10. staging 部署：只走【本地直传】，不要 push CI 自动 build

**部署命令（唯一正路）**：
```bash
cd code/main/miniapp
pnpm upload:mp --robot=1 --mode=staging
# 本地 build + miniprogram-ci 上传 → 微信公众平台「版本管理」选为体验版 → 真机扫码
```

**⚠️ 绝对不要用 GitHub Actions 的 ubuntu CI 自动 build+上传**（push 自动触发应停掉，仅留 `workflow_dispatch` 手动兜底）。

**为什么（血泪根因，排查 7+ 轮才钉死）**：
- 症状：wot-design-uni 的 **virtualHost 复杂组件**（`wd-search` / `wd-picker` / `wd-tabs`）在**体验版真机**上 **Shadow Root 渲染为空、组件不显示**；而简单组件（`wd-tag`）正常。本地开发者工具预览一切正常 → 极难定位。
- 隔离实验结论（决定性）：① 本地产物 → 开发者工具上传 ✅ ② 本地产物 → miniprogram-ci 上传 ✅ ③ **CI(ubuntu) 产物 → miniprogram-ci 上传 ❌**。**唯一坏的变量是 CI 的 ubuntu 构建环境产出的产物**，不是 miniprogram-ci 工具、不是 upload setting、不是 minify/上传过滤、不是组件代码。
- 疑似机理（未根治）：`@uni-ku/bundle-optimizer` 是 **beta 版**，在不同 OS/node（mac vs ubuntu）下产出**不同的产物结构**，ubuntu 那份在真机不渲染。

**排查这类"只在某环境复现"问题的方法论（这次教训）**：
1. **先做隔离实验缩小变量，再动手改**——不要凭组件知识/配置项猜。这次连续 5 次盲改配置全打偏，因为没先隔离变量。
2. **两条上传路径对比 + 同机真机验证**是关键证据：本地直传 vs CI 上传，同一台手机扫码对比，一次性锁定"坏在 CI build 环境"。
3. **不要轻信单次 workflow 调研结论**——必须用产物 grep 自检证伪/证实，不照搬机制论。
4. 急用体验版的 workaround：**开发者工具手动上传**也 OK（已验证）。

**根治后**（升级 bundle-optimizer 稳定版 / 排查 CI 环境）可恢复 `push staging` 自动触发。
