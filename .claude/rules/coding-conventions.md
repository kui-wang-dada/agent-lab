---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
---

# 写法约定（所有 dev 类 agent 共享）

> path-scoped：只在碰到 TS/JS/Python 文件时加载，不污染 media/upwork/assistant 等非代码 session 的 context。

- **TypeScript**：不写 `any`；优先 type，必要时 interface
- **Python**：3.11+，FastAPI + Pydantic v2，不吞异常
- **前端**：Next.js App Router，server component 优先，client component 必须显式标注原因；Tailwind
- **后端**：错误统一 `{ error_code, message, details }`
- **通用**：函数 > 类，组合 > 继承；注释写"为什么"不写"是什么"
- 改前先 build / typecheck；没把握的依赖不引入；不留无说明 TODO
