#!/usr/bin/env bash
# Stop hook —— 项目 OS 模板（通用，实例化时无需改动）
# 主 session 结束时（用户离开、/clear、/compact）记录到 _review-queue/。
# 与 subagent-stop 区别：这条是"主对话"的元信息，反哺评估时优先级稍低
# （主对话覆盖面广，模式不如子 agent 任务集中）。
#
# 注：type/lint 硬 gate 是**另一个**同步 Stop hook（stop-gate.sh），与本文件并列挂在
# settings.json 的 Stop 上。本文件只负责轻量入队（async），不阻塞。

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
QUEUE="$ROOT/.claude/memory/_review-queue"
mkdir -p "$QUEUE"

PAYLOAD="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  TS="$(date +%Y-%m-%dT%H-%M-%S)"
  printf '%s' "$PAYLOAD" > "$QUEUE/$TS-session-raw.json"
  echo '{}'
  exit 0
fi

# 防止 stop_hook_active 死循环
if [ "$(printf '%s' "$PAYLOAD" | jq -r '.stop_hook_active // false')" = "true" ]; then
  echo '{}'
  exit 0
fi

SESSION_ID="$(printf '%s' "$PAYLOAD" | jq -r '.session_id // "unknown"')"
TRANSCRIPT="$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // ""')"
CWD="$(printf '%s' "$PAYLOAD" | jq -r '.cwd // ""')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TS_FILE="$(date +%Y-%m-%d-%H%M%S)-$$-${RANDOM:-0}"

# 抓首条「真实」user prompt（跳过噪声 / tool_result），并 strip 标签（与 subagent-stop 同法）
RAW_INTENT=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  RAW_INTENT="$(jq -rs '
    def flatten:
      if type == "array" then (map(.text? // "") | join(" ")) else tostring end;
    def strip_noise:
      gsub("(?s)<(ide_opened_file|system-reminder|command-name|command-message|command-args|local-command-caveat|local-command-stdout|local-command-stderr)[^>]*>.*?</\\1>"; " ")
      | gsub("(?s)<(ide_opened_file|system-reminder)[^>]*/>"; " ")
      | gsub("<[^>]{1,40}>"; " ")
      | gsub("\\s+"; " ")
      | gsub("^\\s+|\\s+$"; "");
    [ .[]
      | select(.type? == "user" or .role? == "user" or (.message.role? == "user"))
      | (.message.content // .content // "")
      | flatten
      | strip_noise
      | select(. != "" and (length > 4))
    ][0] // ""
  ' "$TRANSCRIPT" 2>/dev/null || true)"
fi
USER_INTENT="$(printf '%s' "$RAW_INTENT" | head -c 200)"

# 过滤噪音：空意图不入队（session 噪音曾是 review-queue 最大来源）
if [ -z "$USER_INTENT" ]; then
  echo '{}'
  exit 0
fi

# 失败信号检测（喂经验回流引擎：失败→护栏）。grep 标记粗分 failure/normal。
SIGNAL="normal"
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  if grep -qiE '"is_error":[[:space:]]*true|traceback \(most recent|compilation (error|failed)|build failed|command not found|❌|STOP 报' "$TRANSCRIPT" 2>/dev/null; then
    SIGNAL="failure"
  fi
fi

OUT="$QUEUE/$TS_FILE-session.json"
jq -n \
  --arg ts "$TS" \
  --arg session "$SESSION_ID" \
  --arg transcript "$TRANSCRIPT" \
  --arg cwd "$CWD" \
  --arg intent "$USER_INTENT" \
  --arg signal "$SIGNAL" \
  '{
    type: "session",
    timestamp: $ts,
    session_id: $session,
    transcript_path: $transcript,
    cwd: $cwd,
    user_intent_snippet: $intent,
    signal: $signal,
    status: "pending"
  }' > "$OUT"

echo '{}'
