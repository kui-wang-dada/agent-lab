# SKILLS_INDEX — 项目级 skill 索引

> 由 `kevin-curator` 周巡时刷新。所有 agent 工作前必读，决定"是否有现成 skill 可复用"。
> 项目级（`.claude/skills/`）+ 用户级（`~/.claude/skills/`）都在内。

**Last refreshed**: 2026-06-09（W24 周巡：本周无新 skill 落地 / 无新候选 / 无 rule 落地。分层自治首周稳态，subagent in-band 沉淀已覆盖；hook 噪音过滤健康）

---

## 项目级 (`.claude/skills/`)

| Skill | Domain | 描述 | 上次用 | 创建 |
|---|---|---|---|---|
| domestic-project-os-bootstrap | domestic | 开中/大型国内 freelance 项目时从 `templates/project-os/` 实例化三段流水线工程 OS（接料→设计/执行→验证/反哺→再生）| 未用（dongjiaoshan 是经验来源）| 2026-06-05 |

> ✅ **已审批生效（2026-06-08）**：`domestic-project-os-bootstrap` 是首个项目级 skill，Kevin 拍板採纳。

## 用户级 (`~/.claude/skills/`)

| Skill | Domain | 描述 | 上次用 | 状态 |
|---|---|---|---|---|
| log | assistant | 记录当前 session 工作要点到周报 | - | ✅ |
| project-scaffold | dev | 项目脚手架模板 | - | ✅ |
| slack-pull-images | assistant | 从 Slack 链接批量下载图片 | 见 kevin-upwork facts「Slack MCP 抓不到图」高频痛点 | ✅ |
| weekly-review | assistant | 生成本周周报（扫 ideas + jsonl 转录 → 周报）| - | ⚠️ **半失效，curator 建议「改写」而非删除**（见下方注） |

> **weekly-review 处理决议（2026-06-05 curator 评估）**：
> - **核心逻辑仍有效**：Step 3-4（扫 `~/.claude/projects` jsonl 按活跃度排序 + 清洗 user message 提炼主题）是栈无关的通用周报骨架，值得保留。
> - **失效部分**：Step 1-2 + 输出路径全部指向已删除的 `kevin-hub/ideas|plans|logs/`。
> - **curator 推荐：改写指向 `agent-lab/.claude/memory/research-notes/` + media `weekly-log/`，输出落 `agent-lab/.claude/memory/_weekly/`，而非删除**——理由：jsonl 扫描这套是 Kevin 实战验证过的、curator 周巡本身也复用同样手法；删了等于丢一个可用工具。
> - **但有重叠风险需 Kevin 拍板**：curator 周巡已产出类似周度产物，若 Kevin 觉得二者职责重复，可改判删除。**curator 未自动改写**（user-level skill 在 agent-lab 管辖外，且涉及职责划分，留给 Kevin 决定）。

---

## Domain 命名约定

| 前缀 | 归属 |
|---|---|
| `assistant-` | kevin-assistant |
| `upwork-` | kevin-upwork（英文市场） |
| `domestic-` | kevin-domestic（中文市场） |
| `research-` | kevin-research |
| `media-` | kevin-media |
| `product-` | kevin-product |
| `coder-` | kevin-coder（含架构 / 契约 / 实现） |
| `qa-` | kevin-qa |
| `dev-` | dev 类共享（product / coder / qa）|
| `general-` | 跨 domain 通用 |

---

## 候选 skill（待 Kevin 审批）

由 curator 写入 `.claude/memory/_skill-candidates-YYYY-WW.md`。审批通过的迁移到 `.claude/skills/` 并加入本索引。

| Skill 候选 | Domain | 描述 | 评审批次 | 状态 |
|---|---|---|---|---|
| `domestic-project-os-bootstrap` | domestic | 开大型国内 freelance 项目时实例化 project-os 模板 | 2026-W23 | ✅ 已转正（见上方项目级表，2026-06-08） |
| `media-weekly-preview-edit` | media | 每周成片前跑 `PREVIEW=60 --force` 出预览片 | 2026-W23 | ✅ 已落 media 项目 `media/.claude/skills/weekly-preview-edit/`（media 自管，不入本索引） |
