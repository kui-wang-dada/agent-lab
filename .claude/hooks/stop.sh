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

OUT="$QUEUE/$TS_FILE-session.json"
jq -n \
  --arg ts "$TS" \
  --arg session "$SESSION_ID" \
  --arg transcript "$TRANSCRIPT" \
  --arg cwd "$CWD" \
  '{
    type: "session",
    timestamp: $ts,
    session_id: $session,
    transcript_path: $transcript,
    cwd: $cwd
  }' > "$OUT"

echo '{}'
