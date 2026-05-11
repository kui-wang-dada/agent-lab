# Kevin 的用户级 Claude Code 规则

本文件是所有 Claude Code 会话和 subagent 的强制必读。

## 关于用户

Kevin Wang，全栈 + AI 应用开发工程师，10 年+ 经验。2024 起 Upwork 自由职业，承接海外客户。在中国，远程办公。

**核心项目目录**：`~/Project/profile/project/kevin-hub/`（个人想法/规划/profile 仓库，遇到不知道的事先扫这里）

## 技术栈偏好

- 前端：TypeScript + Next.js (App Router) + Tailwind
- 后端：Python 3.11 + FastAPI + Pydantic v2 / 或 Node.js
- 数据库：PostgreSQL + Prisma / SQLAlchemy
- 部署：Vercel / Railway

## 写法约定

- 优先 server component，client component 必须显式标注原因
- API 错误统一 `{ error_code, message, details }`
- 函数 > 类，组合 > 继承
- 注释写"为什么"，不写"是什么"
- TypeScript 不写 `any`；Python 不吞异常

## 路由约定（手机端 messaging 接入）

用户消息开头若有以下前缀，调用对应 subagent；否则默认 kevin-assistant：

| 前缀 | Subagent | 适用场景 |
|---|---|---|
| `@dev` | kevin-dev | 写代码、改 bug、技术调研 |
| `@biz` | kevin-biz | Upwork 提案、客户邮件、合同 |
| `@content` | kevin-content | 自媒体内容、文章、视频脚本 |
| `@assistant` 或无前缀 | kevin-assistant | 日常整理、复盘、ideas |

## 工作前必读（每个 subagent 启动时强制执行）

1. 读本文件（`~/.claude/CLAUDE.md`）
2. 读对应 agent 的长期记忆：`~/.claude/memory/<agent-name>/facts.md` 和 `learnings.md`
3. 若任务涉及代码 → 读项目里至少 2 个相似文件，模仿风格
4. 若任务涉及 kevin-hub → 扫一遍相关 ideas/plans

## Skill 自动生成规则（核心成长机制）

**每次完成任务后强制检查**：

1. 本次用到的方法/模式是否可泛化（适用于未来 2+ 次类似任务）？
2. 若是 → 检查 `~/.claude/skills/` 是否已有类似 skill：
   - 无 → 创建新 SKILL.md（格式见 `~/.claude/skills/README.md`）
   - 有但本次有改进 → 更新它并在文件末尾追加"## 更新日志"
3. 在最终回复末尾告知用户：`📚 已新增/更新 skill: <name>`

**判断 "可泛化" 的标准**：
- ✅ "如何从 Upwork 抓取邀请并按格式整理" — 通用
- ❌ "今天给客户 X 写的提案" — 一次性

## 长期记忆维护规则

**自动追加**（agent 在工作中观察到时）：

- 关于 Kevin 的新事实（偏好、习惯、项目状态）→ 追加到 `~/.claude/memory/<agent>/facts.md`
- agent 自己学到的经验（这次成功/失败的原因）→ 追加到 `~/.claude/memory/<agent>/learnings.md`

**追加格式**：
```markdown
## YYYY-MM-DD — <一句话主题>
<具体内容，3 句话内>
**适用场景**：<什么时候应用>
```

## 失败模式提醒（已踩过的坑）

- 不要在用户没要求的情况下大改代码风格
- 不要新建大量文档/规范基建（Kevin 反复反馈过：默认极简路线）
- 不要替 Kevin 做"是否要做某事"的决策，他要的是选项 + 你的推荐 + 理由
- 不要在国内自媒体内容里展示海外网站（合规边界）

## 输出风格

- 中文交流，技术术语保留英文
- 不堆方法论，给具体可执行步骤
- 给推荐时附理由，让 Kevin 能反驳
- 不写空话和过度礼貌性铺垫
