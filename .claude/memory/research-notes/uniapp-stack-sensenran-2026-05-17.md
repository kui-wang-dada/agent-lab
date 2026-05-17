---
name: uniapp-stack-sensenran-2026-05-17
description: sensenran-guzi 项目微信小程序端 uniapp + Vue3 + TS + Pinia 完整技术栈选型清单，含 wot-design-uni/alova/z-paging/lottie 等核心库选择、包大小预算、5 大避雷
metadata:
  type: reference
---

# 谷子宇宙小程序 uniapp 技术栈选型清单

**调研日期**：2026-05-17
**项目**：sensenran-guzi（30 天工期、单端微信小程序、8 模块）
**前置决策**：uniapp + Vue 3 + TS + Pinia（已定）

---

## 1. 核心技术栈

| 类别 | 选型 | 理由 |
|---|---|---|
| 框架 | uniapp 3.x（Vue 3 / Vite） | 已定 |
| 语言 | TypeScript 5.x（严格模式） | 与 FastAPI Pydantic 对齐 |
| 状态 | Pinia 2.0.x + `pinia-plugin-persistedstate` | 已定；持久化 storage 必须改写为 `uni.setStorageSync`（默认走 localStorage 在小程序端炸） |
| **UI 库** | **wot-design-uni**（首选） | Vue3+TS 原生写、暗黑/主题/i18n 全有、80+ 组件、维护活跃（10 天前刚发 1.14）；比 uView Plus 更"现代"，无 Vue2 历史包袱 |
| 网络请求 | **alova** + `@alova/adapter-uniapp` | 自带请求去重/缓存/loading/重试/取消，省一层封装；比 luch-request 现代，比手撸 `uni.request` 拦截器省 200 行模板 |
| 表单校验 | wot-design-uni 内置 `wd-form` + `async-validator` | 别引第三方表单库，组件库自带够用 |
| 路由 | uni-app 自带（不需 router 库） | — |
| 工具 | `uni-helper/uni-app-types`（类型补全）+ `unocss-preset-weapp`（可选） | 类型补全必装；Unocss 看 Kevin 习惯，可不上 |

---

## 2. 关键业务模块的轮子

| 场景 | 选型 | 备注 |
|---|---|---|
| **扭蛋开盒动效** | **lottie-miniprogram + canvas 渲染**（JSON 让设计师/AI 出，托管 COS） | 不要用 CSS 动画硬撸；JSON 必须放网络地址、不能本地（小程序限制）；devicePixelRatio 必须算否则锯齿 |
| **倒计时**（预购截止/抽奖） | wot-design-uni `wd-count-down` | 别自己写 setInterval 避免后台切前台时钟漂移 |
| **图片懒加载/商品列表** | uni 原生 `<image lazy-load>` + `z-paging`（无需瀑布流） | 谷子商品图基本同尺寸，**用普通流不要瀑布流**——降复杂度 |
| **下拉刷新+上拉加载** | **z-paging**（15 万下载、热门榜常驻） | 比 uni 自带的 onPullDownRefresh 省 80% 代码，自动管理空状态/loading/错误 |
| **微信登录** | 自己封装（30 行）—— `uni.login` + 后端 code2Session | 不要装第三方 SDK，纯封装即可 |
| **微信支付** | 自己封装（20 行）—— `uni.requestPayment` 调后端预下单接口 | 同上。后端用 `wechatpay-python` V3 SDK 做签名/验签 |
| **订阅消息** | `uni.requestSubscribeMessage` 原生 + 自己封一个 hook | 模板 ID 在后台配置中心管 |
| **富文本渲染**（资讯文章） | `mp-html`（dcloud 插件市场最热） | 必装。`editor` 原生组件做后台编辑也可；MVP 后台用 wangEditor，前端用 mp-html 渲染 |
| **二维码生成**（拼豆核销码） | `uqrcode` | 5KB 纯 JS，无依赖 |
| **客服按钮** | `<button open-type="contact">` 原生 | 不装任何库 |

---

## 3. 工程化

### 编译目标
仅 `mp-weixin`，`package.json` 只留 `dev:mp-weixin` 和 `build:mp-weixin`，砍掉 H5/App 入口减少 vite 噪音。

### 包大小预算（主包 2MB 红线）

| 包 | 内容 | 预算 |
|---|---|---|
| 主包 | 5 个 tab 页：首页 / 资讯列表 / 我的 / 购物车（可砍）/ 客服浮层；Pinia stores；wot 全局组件 | ≤ 1.5MB |
| `packageGacha`（分包） | 扭蛋详情 + 抽奖动画页 + 概率公示（含 lottie JSON 引用） | ≤ 1MB |
| `packagePreorder`（分包） | 商品详情 + 订单确认 + 订单详情 | ≤ 800KB |
| `packageReservation`（分包） | 门店选择 + 时段座位 + 核销二维码 | ≤ 500KB |
| `packageArticle`（分包） | 文章详情页（mp-html 重） | ≤ 800KB |

**分包预加载**：首页配 `preloadRule` 预下 `packageGacha`（最高频路径）；其他按用户进入触发。
**避坑**：wot-design-uni 全量引入会进主包，**必须配 easycom 按需引入**（默认就是按需，但要检查 `pages.json` 没误开 `autoscan`）。

### TypeScript 配置要点

```ts
// tsconfig.json 关键
"types": ["@dcloudio/types", "@uni-helper/uni-app-types", "@types/wechat-miniprogram"]
```

- **必装** `@uni-helper/uni-app-types`，否则 `<view>` 都报红
- `vue-tsc` 当前对 uni 自定义组件类型推导仍有 bug，可在 CI 关闭模板严格校验，本地 IDE 用 Volar 即可
- pinia store 用 setup 语法时，`defineStore` 的 state 必须显式标 `ref<Type>()`，否则持久化恢复时类型丢失

### 调试链路（Kevin 是 vscode 重度用户）

**推荐**：vscode + CLI 模式，不用 HBuilderX。

```bash
# 一次性安装
npx degit dcloudio/uni-preset-vue#vite-ts my-project
cd my-project && pnpm i
pnpm dev:mp-weixin   # 产物到 dist/dev/mp-weixin
```

vscode 写代码 → 微信开发者工具导入 `dist/dev/mp-weixin` → 热编译实时刷新。
vscode 装 Volar（**禁用 Vetur**，俩一起会冲突）。

---

## 4. 已知坑 / 避雷（5 条优先级最高）

1. **Pinia 持久化在小程序端默认炸**：`pinia-plugin-persistedstate` 默认用 `localStorage`，小程序里 undefined。必须在初始化时传 `storage: { setItem: uni.setStorageSync, getItem: uni.getStorageSync }`。
2. **Vue 3 `<script setup>` 在 uniapp DevTools 显示 AppData 乱码**：调试 reactive 数据看不清楚，workaround 是关键页面临时 `console.log(toRaw(state))` 而不是依赖 DevTools 面板。
3. **wot-design-uni 组件多一层节点**：组件渲染时 wxml 会多套一层 `<view>`，**深层 flex 布局可能塌**——遇到对齐异常先查是不是被中间层吃掉了样式，用 `:host` 或父级强制 `display: contents` 解决。
4. **lottie-miniprogram 的 JSON 必须托管在网络地址**（COS / 备案域名），**不能本地引入**——这是微信小程序 canvas 限制。开发期 mock 也要起 dev 服务器。
5. **uniapp 编译 vue3 setup 时 ts 装饰器和某些高阶类型推导挂掉**：避免在组件 props 用过于花的泛型（如 `PropType<Conditional<T>>`），保持 props 类型扁平。复杂类型放 store / service 层。

---

## 5. 推荐方案总结（拍板清单）

> **推荐栈**：uniapp 3.x（Vite + Vue 3 setup）+ TypeScript 5 严格模式 + Pinia 2 + persistedstate（适配 uni storage）+ **wot-design-uni**（UI）+ **alova + adapter-uniapp**（请求）+ **z-paging**（列表）+ **lottie-miniprogram**（扭蛋动画）+ **mp-html**（资讯渲染）+ **uqrcode**（核销码）。
>
> **微信登录/支付/订阅消息一律自己封装**（每个 20-30 行），不引第三方 SDK。
>
> **包大小预算**：主包 ≤ 1.5MB，4 个业务分包各 0.5-1MB，预加载 packageGacha。
>
> **调试链路**：vscode + Volar + CLI `dev:mp-weixin` → 微信开发者工具导入 `dist/dev/mp-weixin`，不碰 HBuilderX。
>
> **预计踩坑**：1) Pinia 持久化默认 localStorage 不兼容（启动当天就要改）；2) wot 组件多套一层节点导致 flex 塌；3) lottie JSON 必须托管在网络地址；4) DevTools AppData 乱码影响 setup 调试，靠 console 兜底；5) 主包很容易超 2MB，**分包配置必须 D1 就上**别等到第 3 周才补。
>
> **与已有架构方案 04-architecture.md 的差异**：把"微信原生 + Mobx-miniprogram + vant-weapp"全替换为"uniapp + Pinia + wot-design-uni"；其他层（FastAPI / Postgres / COS / 微信支付 V3 / 部署 / 监控）维持不变。

---

## 参考资料

- [wot-design-uni GitHub](https://github.com/Moonofweisheng/wot-design-uni) — Vue3+TS UI 库主力
- [wot-design-uni 文档](https://netlify.wot-design-uni.cn/)
- [z-paging GitHub](https://github.com/SmileZXLee/uni-z-paging) — 列表分页事实标准
- [DCloud 插件市场 wot-design-uni 页](https://ext.dcloud.net.cn/plugin?id=13889)
- [uniapp Vue3+TS+Pinia 模板（推荐参考结构）](https://github.com/sunpm/unisave)
- [Pinia 持久化在 uni 端的坑与解法](https://yql520.com/archives/1695613190513)
- [uniapp 接入 lottie-miniprogram 详细指南](https://blog.csdn.net/qq_20686495/article/details/128036594)
- [uniapp 分包优化最佳实践](https://zhuanlan.zhihu.com/p/1931005175516070355)
- [vscode + CLI 模式开发 uniapp](https://www.cnblogs.com/haoxianrui/p/18684753)
- [uni-app 官方分包文档](https://zh.uniapp.dcloud.io/component/animation-view.html)
