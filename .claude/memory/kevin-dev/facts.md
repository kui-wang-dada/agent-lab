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
