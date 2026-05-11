# Kevin 的代码偏好（kevin-dev 视角）

> 长期积累 Kevin 在代码层面的偏好和惯例。Agent 观察到新偏好时自动追加。

## 已知偏好（从 ~/.claude/CLAUDE.md 同步）

- TypeScript + Next.js (App Router) + Tailwind
- Python 3.11 + FastAPI + Pydantic v2 / 或 Node.js
- Server component 优先
- 错误统一 `{ error_code, message, details }`
- 函数 > 类，组合 > 继承

## 讨厌的写法

- `any` 类型
- 吞异常的 try/catch
- 过度抽象（三层以上 wrapper）
- 没把握就引入新依赖

---

<!-- agent 追加新观察的代码偏好 -->
