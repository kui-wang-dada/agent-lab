# Kevin 的开发偏好（kevin-dev domain 共享）

> 由 kevin-product / kevin-frontend / kevin-backend / kevin-qa 共享读取。
> 任何一个 dev 类 agent 观察到 Kevin 的代码偏好，追加到这里。

## 技术栈（默认值，项目可覆盖）

### 前端
- TypeScript + Next.js (App Router) + Tailwind
- Server Component 优先，client component 必须显式标注原因
- React Native（Expo 0.76+ New Arch 项目按项目走）
- 状态：Server Component 默认；客户端用 Zustand 或 Jotai；不用 Redux
- 表单：react-hook-form + zod

### 后端
- Python 3.11 + FastAPI + Pydantic v2
- 或 Node.js（看项目）
- ORM：Prisma（Node）/ SQLAlchemy 2.0（Python）
- DB：PostgreSQL 主，SQLite 原型
- 缓存/队列：Redis
- AI 集成：Anthropic SDK 优先，**必启用 prompt caching**

### 测试
- pytest（Python）/ vitest（Node）/ Playwright（E2E）

### 部署
- Vercel（Node）/ Railway（Python+DB）

## 核心约定

- API 错误统一 `{ error_code, message, details }`
- 函数 > 类，组合 > 继承
- 注释写"为什么"，不写"是什么"
- TypeScript 不写 `any`
- Python 不吞异常
- DB 变更必须 migration

## 讨厌的写法

- `any` 类型
- 吞异常的 try/catch
- 过度抽象（三层以上 wrapper）
- 没把握就引入新依赖
- 大改用户没要求重构的代码
- 测 mock 而不测真实业务行为

## 工作方式偏好

- 写代码前先说 3 步内的计划，让 Kevin 能拦截
- 改前先 build / typecheck / 跑测试，确认基线
- 不熟的库用 context7 查文档，不靠记忆
- 跑过的命令告知 Kevin（让他能验证）

---

<!-- agent 追加新观察的代码偏好 -->
