#!/usr/bin/env bash
# SubagentStop hook
# 子 agent 任务完成时，把 metadata 写到 _review-queue/，让 curator 周巡评估"是否抽 skill"。
#
# stdin payload: { session_id, transcript_path, cwd, hook_event_name, ... }
# transcript_path 指向本次子 agent 的对话 JSONL，curator 评估时再读全文。

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
QUEUE="$ROOT/.claude/memory/_review-queue"
mkdir -p "$QUEUE"

# 读 stdin
PAYLOAD="$(cat)"

# jq 不在就降级
if ! command -v jq >/dev/null 2>&1; then
  TS="$(date +%Y-%m-%dT%H-%M-%S)"
  echo "$PAYLOAD" > "$QUEUE/$TS-subagent-raw.json"
  echo '{}'
  exit 0
fi

# 提取关键字段（容错：缺字段填 "unknown"）
SESSION_ID="$(echo "$PAYLOAD" | jq -r '.session_id // "unknown"')"
TRANSCRIPT="$(echo "$PAYLOAD" | jq -r '.transcript_path // ""')"
CWD="$(echo "$PAYLOAD" | jq -r '.cwd // ""')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TS_FILE="$(date +%Y-%m-%d-%H%M%S)"

# 从 transcript 文件名推断 agent 名（路径里通常有 subagents/agent-XXX.jsonl）
AGENT="unknown"
if [ -n "$TRANSCRIPT" ] && [[ "$TRANSCRIPT" == *subagents* ]]; then
  AGENT="$(basename "$TRANSCRIPT" .jsonl)"
fi

# 从 transcript 抓第一条 user message 的前 200 字（粗糙但够用，curator 会重读全文）
# 用 jq 直接解析 JSONL，跨平台（macOS 没有 tac，避免依赖）
USER_INTENT=""
if [ -f "$TRANSCRIPT" ]; then
  USER_INTENT="$(jq -rs '
    [.[] | select(.role? == "user" or .type? == "user")][0]
    | (.message.content // .content // "")
    | if type == "array" then map(.text // "") | join(" ") else tostring end
  ' "$TRANSCRIPT" 2>/dev/null | head -c 200 || true)"
fi

# 写入 queue
OUT="$QUEUE/$TS_FILE-subagent.json"
jq -n \
  --arg ts "$TS" \
  --arg session "$SESSION_ID" \
  --arg agent "$AGENT" \
  --arg transcript "$TRANSCRIPT" \
  --arg cwd "$CWD" \
  --arg intent "$USER_INTENT" \
  '{
    type: "subagent",
    timestamp: $ts,
    session_id: $session,
    agent: $agent,
    transcript_path: $transcript,
    cwd: $cwd,
    user_intent_snippet: $intent
  }' > "$OUT"

# 静默成功
echo '{}'
