# Kevin 的开发偏好（kevin-dev domain 共享）

> 由 kevin-product / kevin-coder / kevin-qa 共享读取。
> **数据源**：upwork-hunter/resume/profile.md、upwork-hunter/resume/PROJECT_KNOWLEDGE_BASE.md（AstridDAO 21 项目）、tianda-web/CLAUDE.md（2026-05 同步）

## Kevin 的实战栈宽度

10 年+ 全栈，覆盖 React / Vue / RN / FastAPI / AI / Web3。
**当前主要项目栈**（按权重）：
1. React Native（Venus 客户项目）
2. Next.js 15 App Router + Tailwind（tianda-web 个人站）
3. FastAPI + Pydantic v2 + SQLAlchemy async + Postgres（tianda-web 后端）
4. Vite + React 19 + TanStack Router + Ant Design Pro（admin 面板）
5. Python（quant 量化项目）
6. Web3（Wagmi v2 + Viem v2 + Solidity，AstridDAO 历史栈）

---

## 技术栈默认值（项目可覆盖）

### 前端
- **TypeScript** + **Next.js 15** (App Router) + **Tailwind 3** + **Lingui 5**
- 状态：**Zustand**（首选）、Pinia（Vue 项目）；不用 Redux
- 表单：**react-hook-form + zod**
- UI 组件：
  - 公开站：纯 Tailwind + Framer Motion
  - 后台：**antd 5 + @ant-design/pro-components**（ProTable / ProForm / ProDescriptions）
- Velite + MDX（内容驱动型站）
- React Native（Expo 0.76+ New Arch 项目按项目走）

### 后端
- **Python 3.11 + FastAPI + Pydantic v2**
- ORM：**SQLAlchemy 2.0 async**（Python）/ **Prisma**（Node）
- DB：**PostgreSQL 16** 主（tianda-web、Venus 后端）；**SQLite WAL** 原型 / 量化
- Auth：JWT HS256（15m access + 7d refresh，JTI DB 可吊销）+ argon2id 密码 hash
- 邮件 OTP：6 位数字
- 限流：**slowapi**（FastAPI）
- 跨域 cookie：`Domain=.<root-domain>; HttpOnly; Secure; SameSite=Lax`
- AI 集成：**Anthropic SDK 优先**，必启用 prompt caching
- markdown：nh3 sanitizer（XSS 防御）

### Web3 / DeFi
- 钱包：@reown/appkit / RainbowKit
- 链交互：Wagmi v2 + Viem v2（新）/ Ethers.js v5/v6（旧）
- 智能合约：Solidity + Hardhat + TypeChain
- 多链：Ethereum / Astar / Solana / CKB
- The Graph（Subgraph）
- DeFi 模式：CDP / AMM / Lending / Liquid Staking / NFT marketplace

### 测试
- pytest（Python）/ vitest（Node）/ Playwright（E2E）/ jest + @testing-library/react-native（RN）

### 部署 / DevOps
- Vercel（Node 静态） / Railway（Python+DB）
- 阿里云 OSS（静态托管）/ 宝塔面板（VPS 反代 + SSL）
- Docker + Docker Compose
- IPFS（Web3 项目）
- Cloudflare Pages
- GitHub Actions CI/CD

### AI / 自动化
- Claude API（首选）+ Cursor 辅助
- Anthropic Claude（情绪分析、market sentiment）
- 自动交易策略（Binance / OKX API）
- ETL 链上数据 pipeline

### 包管理
- **pnpm**（前端 Vue / React 现代项目）
- **uv**（Python 现代项目）
- yarn（部分旧项目）

### 编辑器
- VS Code 主力
- Cursor / Claude Code（AI 协作）
- 多开 Claude Code / Cursor 窗口做并行任务

---

## 核心约定（所有项目通用）

- **API 错误统一格式**：`{ error_code, message, details }`
- **不写 `any`**；类型推不出来时说原因
- **不吞异常**：try/except 必须 log + re-raise 或返回明确错误码
- **不裸 SQL**（除非性能必需，且必须 parameterized）
- **DB 变更必须 migration**（Prisma migrate / Alembic / postgres-init.sql）
- **环境变量从 env 读，不 hardcode 密钥**
- **AI 调用 → 必启用 prompt caching**
- **rate limit + 显式事务边界**为后端默认
- **Server Component 优先**（Next.js），client component 必须显式标注原因
- **Tailwind tokens** 是 source of truth — 不 hardcode 颜色
- **静态导出限制**（Next.js `output: 'export'`）：不能用 middleware / `cookies()` / `headers()` / `revalidate*` / `next/image` 优化

## 函数 / 抽象偏好

- 函数 > 类，组合 > 继承
- 注释写"为什么"，不写"是什么"
- 拒绝过度抽象（三层以上 wrapper）
- 没把握的依赖不引入

## 讨厌的写法（违反 = 必须改）

- `any` 类型
- 吞异常的 try/catch
- 过度抽象（三层以上 wrapper）
- 没把握就引入新依赖
- 大改用户没要求重构的代码
- 测 mock 而不测真实业务行为
- 在 prompt 里没说就 hardcode 颜色 / 字符串

## 工作方式偏好

- **写代码前先说 3 步内的计划**，让 Kevin 能拦截
- **改前先 build / typecheck / 跑测试**，确认基线
- **不熟的库用 context7 查文档**，不靠记忆
- **跑过的命令告知 Kevin**（让他能验证）
- **多 Claude Code 窗口并行**：写代码时间块（9-11 / 14-16:30 / 19-21）实际不饱和，多开窗口跑微产品制作不挤占主线 Upwork

---

## Kevin 的项目历史摘要（reviewer / architect 调用作上下文）

### Web3 / DeFi（21+ AstridDAO 项目）
- CDP 稳定币、AMM 交易（Bagua）、NFT 市场（Bluez）、Aave fork 借贷（pu239）、Liquid Staking（lst）、L2 协议（l2x）、Solana Blinks、Next.js DeFi 前端（Macaron / Stabble / Goku）
- 主要栈：Vue 3 + Vite + PrimeVue / React 18 + CRA + Ant Design / Next.js 14 + Chakra
- 见 `~/Project/profile/project/upwork-hunter/resume/PROJECT_KNOWLEDGE_BASE.md` 完整目录

### 移动端
- **Venus Skincare**（韩国 AI 美妆 App，当前主要 Upwork 客户）—— RN + AI 图像分析 + 订阅
- **Obico**（3D 打印监控 App）—— IoT + 监控
- 微信小程序

### 后端 / 自动化
- FastAPI 后端服务
- 量化交易 bot（BTC/ETH，Binance/OKX API）
- ETL 数据 pipeline（区块链数据）

---

## 当前在做 / 在维护的项目

| 项目 | 路径 | 状态 |
|---|---|---|
| Venus Skincare | Upwork 客户项目 | 主要产能，每周迭代 |
| tianda-web | `~/Project/profile/code/tianda-web` | V2 进行中，Next.js 静态 + FastAPI + Vite admin |
| agent-lab | `~/Project/profile/project/agent-lab` | 12 agent 体系，Hermes 风格 |
| media | `~/Project/profile/project/media` | 自媒体执行流水线，Docker 自动剪辑 |
| upwork-hunter | `~/Project/profile/project/upwork-hunter` | Upwork 投递工具 |
| quant (Crypto Sentinel v2) | `~/Project/profile/project/quant` | BTC/ETH 极端行情哨兵，本地 7×24 |
| indie-dev | `~/Project/profile/project/indie-dev` | 宠物医疗 B 端工具探索（兽医同学渠道） |

---

<!-- agent 追加新观察的代码偏好 -->

---

## 2026-05-17 — Venus 项目沉淀的默认技术栈

> **来源**：Venus 韩国 AI 美妆 App（开发 1 年+，~/Project/work/upwork/2025/4-6-rn-ai/）
> 这些是 Kevin 当前**最熟练、默认会选用**的技术栈。新项目除非有明确理由换，否则按这套。
> 详细架构 reference 见 [venus-architecture.md](venus-architecture.md)（有具体 file:line 引用）。

### RN 端（高确信，Venus 主端）
- **Expo 53 managed + RN 0.79.5 + React 19**，新架构**关闭**（`newArchEnabled: false`）—— 第三方库兼容性大于性能收益
- **导航**：React Navigation v7（native-stack + bottom-tabs + material-top-tabs）；按业务域切 module navigator 文件
- **状态**：Zustand v5 + slice 模式，**单一 root store** `useRootStore` 由 N 个 slice 合并（user / scan / routine / product / clinic / task / chat / doctor / stripe / library / colorConsult）
  - 中间件链：`persist(subscribeWithSelector(devtools(...)))`
  - 跨组件读多个值必须 `useShallow`
  - persist 用 `partialize` 白名单（只持久化 token / userInfo / 少量 cache），用 AsyncStorage backend
  - `resetAllStores` 全局重置函数（logout 时用）
- **网络**：axios 单例 + request/response interceptor（`src/store/api/`），request 注入 Bearer token，response 检测 `x-new-token` header 实现无感刷新，401 自动触发 logout
- **表单**：暂未深度用 react-hook-form（RN 端逻辑分散在 store action 里）
- **动画**：reanimated 3 + @shopify/react-native-skia（人脸扫描特效）+ lottie-react-native
- **相机 / 人脸**：**react-native-vision-camera 4.7** + react-native-vision-camera-face-detector
  - 自封装 `useVisionCamera` hook（含 Android CameraX 黑屏自动重挂载 / 设备列表 polling fallback）
- **多语言**：**Lingui v5**（`@lingui/macro` + `useLingui()` + `t` tag），husky pre-commit 自动跑 `npm run lingui`，支持 en/ko/es/ja
- **推送**：expo-notifications + Customer.io（`customerio-expo-plugin` + `customerio-reactnative`）
- **IAP / 订阅**：**RevenueCat (`react-native-purchases`)** 是 source of truth；Stripe SDK 用于 web payment sheet，**Stripe RN SDK 锁定 0.62.0**（更高版本 Xcode 26.4 崩）
- **错误监控**：**Sentry**（`@sentry/react-native`），setUser 在 userInfo 变化时同步
- **分析**：Amplitude + Branch.io（attribution / deep link）
- **路径别名**：`@/` → `src/`，所有内部 import 用 `@/`
- **构建**：EAS Build + OTA Update（`update:preview` / `update:prod`），runtime version 2.1.2

### Web 端（高确信，三种栈共存）

| 项目 | 栈 | 用途 | 何时选 |
|---|---|---|---|
| **venus-skin-review** | Next.js 15 + shadcn/ui + Context | 医生评审门户 | 需要 SSR / 后端代理 / SEO |
| **venus-skincare-box** | Next.js 15 + shadcn/ui + Context | 内部 admin（订单/包/库存） | 同上，部署 Vercel |
| **venus-internal-admin** | **Vite + React 18 + react-router 6 + Zustand + shadcn/ui** | 任务端 admin | 重交互 / 不需要 SEO / 想要更快 dev server |

- **UI 库**：**shadcn/ui**（Radix 原语 + Tailwind）+ Lucide icons + sonner（toast） —— 所有 web 端统一
- **状态**：Next.js 项目用 **React Context + custom hooks**；Vite admin 项目用 **Zustand**（同 RN 端 root store 模式）
- **表单**：react-hook-form + zod + @hookform/resolvers
- **i18n**：自研轻量 i18n（locale 文件 + `t()` 函数）；Vite admin 用 Lingui
- **DB 访问**：Next.js 内部 API 用 `pg.Pool`（不引入 ORM）；主数据走外部 FastAPI
- **HTTPS 代理模式**（venus-skin-review）：production 经 Next.js proxy `/api/proxy/doctor` 调 HTTP 后端，避免 mixed-content；dev 直连
- **图表**：recharts
- **日期**：date-fns（部分项目用 luxon）

### 后端（高确信，Python 3.11 + FastAPI 0.111）

- **架构**：分层 Routes → Services → Models / Schemas，每层独立目录
- **路由自动发现**：`api/v1/router.py` 用 `importlib` 扫描 `routes/` 目录，每个文件 export `router` 自动挂载
- **ORM**：**SQLAlchemy 2.0**（同步 API + Session）—— 注意：Venus 用同步 Session 而非 async，连接池 `pool_size=10 + max_overflow=20`，`pool_pre_ping=True`
- **Pydantic v2**：schemas 用 `BaseModel` + `ConfigDict(from_attributes=True)`
- **配置**：`pydantic-settings.BaseSettings` + `Field(alias="ENV_VAR_NAME")`，env 文件按 `APP_ENV` 切换（`config/environments/{development,production,test}.env`）
- **鉴权**：JWT HS256（python-jose），多种 token 类型用 `type` 字段区分（user / doctor / skinbox）；passlib + bcrypt
- **Token 自动刷新**：自研 `TokenRefreshMiddleware`，剩余时间 < 阈值时在 response header 注入 `X-New-Token`，客户端 axios interceptor 检测后更新 —— **优于传统 refresh token 流程**（少一次往返）
- **错误处理模板**：每个 route 三层 catch（`HTTPException` re-raise、`ValueError → 404`、`Exception → 500 + logger.error exc_info=True`）—— 全项目一致
- **AI 集成**：OpenAI SDK + LangChain + Pinecone（RAG），不用 Anthropic（客户已锁 OpenAI）
- **微服务**：4 个独立 FastAPI 进程共享 PostgreSQL
  - `fastapi-backend`（主业务，8000）
  - `ai-skin-analysis`（人脸分析，8002，Roboflow + MediaPipe + PyTorch）
  - `task-service`（cron + one-off，9200，自封装 registry）
  - 服务间通过共享 docker network `venus-internal` 通信
- **DB schema 管理**（Venus 特殊）：fastapi-backend / ai-skin-analysis **手写 SQL**（不用 alembic 自动迁移）；task-service 独立 alembic chain
- **任务调度**：**APScheduler 3.10** + 自封装 RecurringJobSpec/OneOffJobSpec registry pattern；每个 task 一个文件，在 `__init__.py` 集中注册 cron
- **重试**：tenacity 装饰器 `@with_retry(attempts=3, retry_on=(...))`
- **邮件**：Customer.io（替代了 SendGrid，仍保留 sendgrid 库依赖）
- **支付**：Stripe Python SDK + RevenueCat webhook 入口

### 跨层惯用模式

- **字段命名**：API JSON 用 **snake_case**（FastAPI / Pydantic 默认），前端直接用 snake_case 不做自动 camelCase 转换 —— 减少一层心智负担
- **错误格式**：不是 `{error_code, message, details}`，而是 FastAPI 默认 `{detail: "..."}` + HTTP status code；客户端按 status 分支处理。**这与 Kevin 在 tianda-web 的偏好不同**，是历史包袱
- **API client 不自动生成**：手写 service 文件（`lib/services/*-api.ts`），不用 OpenAPI generator
- **类型共享**：前后端**不共享类型**，前端手写 TS interface 对应后端 schema
- **包管理**：RN 用 **yarn**，Next.js 用 **npm**，Vite admin 用 **npm** —— 客户项目历史包袱，不强求 pnpm
- **部署**：宝塔 + Docker Compose（VPS），Vercel（venus-skincare-box），EAS（RN）
- **错误上报**：Sentry（RN）+ 后端日志文件（无 Sentry 后端集成）
- **测试覆盖薄**：fastapi-backend 有 pytest 但覆盖低；RN 有 maestro_e2e 目录但不强制；web 项目**无测试框架**
- **环境变量管理**：所有项目均 startup 时打印全部 env（`print_all_env_vars()`）便于 debug

### 与 Kevin 自有项目（tianda-web）的差异点

| 维度 | Venus（客户项目） | tianda-web（个人项目） |
|---|---|---|
| SQLAlchemy | 同步 Session | **async** Session |
| DB 迁移 | 手写 SQL | Alembic |
| 错误格式 | FastAPI 默认 `{detail}` | `{error_code, message, details}` |
| Pydantic v2 schema | 直接 BaseModel | 部分 dataclass 化 |
| 状态管理（Next.js） | Context | Zustand |
| UI 库（后台） | shadcn/ui | **antd 5 + ProComponents** |
| AI Provider | OpenAI（客户锁） | **Anthropic 优先** |
| 字段命名 | snake_case 全栈 | 后端 snake / 前端按需 |

**新项目默认选 tianda-web 那一套**（async + Anthropic + antd 后台），Venus 的栈是"维护客户项目时用，自有项目不必照搬"。
