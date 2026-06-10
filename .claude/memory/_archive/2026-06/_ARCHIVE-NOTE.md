# _archive/2026-06 — 已消费的 review-queue 记录

## 2026-06-05 批（curator 补跑周巡，积压 4 周）
2026-06 月内有真实任务意图的 subagent 记录。去重后真实任务模式：
dongjiaoshan 项目复盘→工程模板(27，抽成 skill `domestic-project-os-bootstrap`) /
海外 grant 报价询价(3) / media W21 预览剪辑(5)。
结论见 `../../_skill-candidates-2026-W23.md`。

## 2026-06-07 批（W23 周日周巡，21 条全部噪音）
全部为 IDE-opened-file 事件（`kevin-research/facts.md` 被频繁打开）和 session-start 标记。
无任何可抽的 skill 候选。提醒：review-queue 中 IDE-opened-file 噪音比例极高（见 _skill-candidates-2026-W23.md §给 Kevin 的发现）。

## 2026-06-09 批（W24 周巡，4 条全部噪音 / hook 过滤已生效）
4 条均为最小 session/subagent 元数据 stub（无 `user_intent_snippet`、无 `signal:failure`、无 `occurrences`）：
2026-06-07 三条同一对话内 session/subagent stop 闭合事件、2026-06-08 一条单 session 标记。
**对比 W23（21 条噪音 → W24 4 条噪音）**：2026-06-08 落地的 hook 噪音过滤（见 `.claude/hooks/stop.sh` / `subagent-stop.sh` git 记录）正在生效——IDE-opened-file 类纯噪音已被剔除，剩下的是无法预筛的"无任务上下文 stop 事件"。结论：**hook 噪音过滤健康，无新候选**。
