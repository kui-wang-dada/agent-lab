#!/usr/bin/env bash
# Stop hook
# 主 session 结束时（用户离开、/clear、/compact）记录到 _review-queue/。
# 与 subagent-stop 区别：这条是"主对话"的元信息，curator 评估时优先级稍低
# （主对话覆盖面广，模式不如子 agent 任务集中）。

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
QUEUE="$ROOT/.claude/memory/_review-queue"
mkdir -p "$QUEUE"

PAYLOAD="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  TS="$(date +%Y-%m-%dT%H-%M-%S)"
  echo "$PAYLOAD" > "$QUEUE/$TS-session-raw.json"
  echo '{}'
  exit 0
fi

# 防止 stop_hook_active 死循环
if [ "$(echo "$PAYLOAD" | jq -r '.stop_hook_active // false')" = "true" ]; then
  echo '{}'
  exit 0
fi

SESSION_ID="$(echo "$PAYLOAD" | jq -r '.session_id // "unknown"')"
TRANSCRIPT="$(echo "$PAYLOAD" | jq -r '.transcript_path // ""')"
CWD="$(echo "$PAYLOAD" | jq -r '.cwd // ""')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TS_FILE="$(date +%Y-%m-%d-%H%M%S)"

# 抓主对话第一条 user message 前 200 字（和 subagent-stop 对称）
USER_INTENT=""
if [ -f "$TRANSCRIPT" ]; then
  USER_INTENT="$(jq -rs '
    [.[] | select(.role? == "user" or .type? == "user")][0]
    | (.message.content // .content // "")
    | if type == "array" then map(.text // "") | join(" ") else tostring end
  ' "$TRANSCRIPT" 2>/dev/null | head -c 200 || true)"
fi

# 过滤噪音：IDE 打开文件 / 空意图，不入队（session 噪音曾是 review-queue 最大来源）。
case "$USER_INTENT" in
  "<ide_opened_file>"*|"")
    echo '{}'
    exit 0
    ;;
esac

# 失败信号检测（与 subagent-stop 对称；喂经验回流引擎）。grep 标记粗分 failure/normal。
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
    signal: $signal
  }' > "$OUT"

echo '{}'
