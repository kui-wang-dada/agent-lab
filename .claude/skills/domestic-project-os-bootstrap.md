---
name: domestic-project-os-bootstrap
description: 开新的中/大型国内 freelance 项目（人+AI 协作交付）时，从 templates/project-os 实例化一套自包含的三段流水线工程 OS（接料→设计 / 执行→验证 / 反哺→再生），填 PROJECT.md 单一变量源即得到可移植的项目宪法
domain: domestic
created: 2026-06-05
updated: 2026-06-08
---

# 国内大型项目「工程 OS」实例化

## 触发条件

Kevin 接下一个**中型以上的国内 freelance 项目**，需要"人派单 + AI 主体执行 + 全栈 review"协作交付时。
典型信号：甲方给原型/SRS/Excel、多业务域、预估工期 ≥ 数天、需要并行多 ticket。
（2 小时级 bugfix 不必上全套，但仍走同一结构——见 tier 心智参考。）

## 输入

- 项目代号 + 绝对路径（落在 `~/Project/profile/project/freelance/projects/<name>/`）
- 团队模型（谁派单 / 谁 review / AI 写多少）
- 技术栈（后端 / 管理端 / 移动端 / DB）
- 第三方框架底座源码目录（要 deny 写）+ 业务代码子树（allow 写）
- 业务域列表 + 迁移目录 + ID/编号/字典命名规则

## 步骤

1. `mkdir -p` 项目目录，拷 **scaffold**（per-project 部分）：`cp -R agent-lab/templates/project-os/. <项目>/`（含隐藏 `.claude/`）。
   **机器层（agents/commands/hooks）不在 scaffold 里**——它是 project-os plugin。在项目内起 Claude Code 后装一次：`/plugin marketplace add <agent-lab 路径>` → `/plugin install project-os@agent-lab`。机器层更新 `/plugin update project-os@agent-lab` 自动传播，**不再手动同步副本**（消除机器层 drift）。
2. 填 `PROJECT.md` —— **单一变量源**，把所有 `<<TOKEN>>` 的实际值只在这里声明一次。其他文件引用概念不复制值。
3. 展开 `.claude/settings.json` 里 `<<FRAMEWORK_BASE_PATHS>>` / `<<BUSINESS_MODULE_PATHS>>` 两个路径（唯一允许展开值的文件，机器读的 JSON）。
4. 选栈：保留 `stacks/<本栈>-notes.md` + `.claude/rules/<本栈>.md`，删不相关的；没现成就照 `ruoyi-notes.md` / `ruoyi.md` 结构新建。启用 type/lint gate（快栈）：`cp .claude/verify-cmd.example .claude/verify-cmd` 填命令；慢栈（mvn）留空=关。
5. 起 Claude Code（cwd = 项目根，CLAUDE.md 自动加载）→ 进 SP1 接料：原型加锁只读 + snapshot md5 → 列疑点 P0/P1/P2 → 答 P0 → 拆解冻结。
6. SP1 GATE：三件 SSOT（① 冻结 schema ② 共享组件+token+真截图锚定 ③ ticket 全集+机器可验收 checkbox）齐 + 验收可机器验，**才准**进 SP2 执行。
7. SP2 每天 6 步日循环（切分支 → AI 三段式写 → 测试 AI→人 → closing audit → 完善次日 → 事件驱动沉淀）。
8. SP3 反哺：项目结束把通用机制回写 `templates/project-os/`（收敛副本 drift），栈特定教训进 `stacks/`，经验进 agent-lab 经验池。

## 输出格式

一个自包含、可移植的项目目录：`PROJECT.md`（SSOT）+ `CLAUDE.md`（项目宪法）+ `doc/authority/`（三件 SSOT）+ `daily/`（日循环模板）+ `STAGE2/3-BACKLOG.md` + `stacks/<栈>-notes.md`。

## 已知陷阱

- **不要砍成"极简内核 + 按需加"**：强默认 + 可关。每个可选件标"关掉条件"，小项目是"同结构更少实例"不是"删减版"。
- **不要建 tier-auto-trigger 引擎**：tier 是人脑标签，自动按规模判流程是过度工程（Kevin anti-bloat 红线）。
- **不要"一个 bug 一个 skill"**：落地优先级 SSOT(~60%) > prompt 模板(~30%) > doc/ADR(~10%) > skill(≤10%，横切 ≥3 ticket 才考虑)。
- **§0 自检不可省**：复盘救场记录显示它挡住过漏建表 / 字段类型错 / 分支切错；30s-2min 挡几小时返工，派单时别催 AI 跳过。
- **designer 是 Stage1 上游一等公民**：视觉 ground-truth 必须用真截图锚定，不能用字段表（dongjiaoshan 视觉偏差根因）。

## 更新日志
- 2026-06-05: 初版（从 dongjiaoshan 15 天复盘 + templates/project-os 抽出）
- 2026-06-08: Kevin 审批通过，正式生效
- 2026-06-09: project-os 拆 plugin（机器层 agents/commands/hooks）+ scaffold（per-project）。实例化改为 cp scaffold + `/plugin install project-os@agent-lab`；机器层经 marketplace 更新自动传播，消除副本 drift。新增 `.claude/rules/`（path-scoped 栈规则）+ type/lint gate（verify-cmd）。
