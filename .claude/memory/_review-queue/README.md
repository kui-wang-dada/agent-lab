# _review-queue/

> SubagentStop hook 把每次子 agent 任务的 metadata 写到这里。
> kevin-curator 周日 21:30 巡检时批量评估，抽 skill 候选后清空。

## 文件命名

`<YYYY-MM-DD-HHMMSS>-<agent>-<short-task>.json`

例：`2026-05-11-203045-kevin-coder-add-darkmode.json`

## 内容格式

```json
{
  "agent": "kevin-coder",
  "started_at": "2026-05-11T20:25:00Z",
  "ended_at": "2026-05-11T20:30:45Z",
  "user_intent": "...",
  "files_touched": ["..."],
  "tools_used": ["Edit", "Bash"],
  "result_summary": "..."
}
```

由 P2 阶段的 `subagent-stop.sh` 写入。
