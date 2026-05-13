# SKILLS_INDEX — 项目级 skill 索引

> 由 `kevin-curator` 周巡时刷新。所有 agent 工作前必读，决定"是否有现成 skill 可复用"。
> 项目级（`.claude/skills/`）+ 用户级（`~/.claude/skills/`）都在内。

**Last refreshed**: 2026-05-12（agent 重组：biz→upwork + 新增 domestic / research）

---

## 项目级 (`.claude/skills/`)

| Skill | Domain | 描述 | 上次用 | 创建 |
|---|---|---|---|---|
| _(空)_ | - | 待 curator 周巡时从 _review-queue/ 抽出第一批候选 | - | - |

## 用户级 (`~/.claude/skills/`)

| Skill | Domain | 描述 | 上次用 | 状态 |
|---|---|---|---|---|
| log | assistant | 记录当前 session 工作要点到周报 | - | ✅ |
| project-scaffold | dev | 项目脚手架模板 | - | ✅ |
| slack-pull-images | assistant | 从 Slack 链接批量下载图片 | - | ✅ |
| weekly-review | assistant | 生成本周 kevin-hub 周报 | - | ⚠️ **路径已失效**：引用 `kevin-hub/ideas|plans|logs/` 但 kevin-hub 已删除。需要 Kevin 决定：删除 / 改写指向 `agent-lab/.claude/memory/` |

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
