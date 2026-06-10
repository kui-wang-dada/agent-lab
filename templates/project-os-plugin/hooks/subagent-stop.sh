#!/usr/bin/env bash
# SubagentStop hook —— 项目 OS 模板（通用，实例化时无需改动）
#
# 子 agent 任务完成时，把 metadata 当场写到 _review-queue/，供 Stage3 事件驱动反哺消费。
# stdin payload: { session_id, transcript_path, cwd, hook_event_name, stop_hook_active, ... }
#
# ─────────────────────────────────────────────────────────────────────────────
# 本文件相对 dongjiaoshan 原版修了 3 处已验证 bug / 设计缺陷（复盘 workflow 锁定）：
#
# [BUG-1] agent 名 118/118 → "unknown"
#   原版只在 transcript_path 含 "subagents" 子串时取 basename，否则写死 "unknown"。
#   实测：本类环境 SubagentStop 收到的 transcript_path 多是主 session 的 <id>.jsonl
#   （根本不含 "subagents"），导致 131/131 全 unknown，反哺时无法按 agent 聚类。
#   修法：多源、按优先级推断，且**取不到时记 raw:<线索> 而非写死 unknown**——
#     1) 显式覆盖   $CLAUDE_SUBAGENT_NAME（harness 若提供）
#     2) 路径 basename  仅当是有意义的 .../subagents/<name> 且非纯 hash agent-<hex>
#     3) prompt 前缀   首条真实 user message 的 @kevin-xxx / @xxx
#     4) 关键词回退   按路由表 keyword 命中 coder/qa/product/designer/curator
#     5) raw:<basename|session 前 8 位>  —— 保留可追溯线索，不丢信息
#
# [BUG-2] user_intent 抓到 <ide_opened_file> 等噪声
#   原版取"第一条 user message"，但 IDE / 系统会往 user 角色塞 <ide_opened_file>
#   / <system-reminder> / <command-name> / tool_result 等噪声，常把真实意图挤掉。
#   修法：① 跳过 content 里全是这些标签 / tool_result 的伪 user message；
#         ② 抓到后再 strip 掉残留的 <...> 标签块与首尾空白，取前 200 字。
#
# [DESIGN] "攒队列等周巡" → 事件驱动雏形
#   原版只是把 metadata 堆进 queue，等 curator 周巡批量消费（复盘：~290-310 条从未被消费）。
#   改成写入即**轻量去重 + 标记**：按 (agent + 归一化 intent) 算指纹，当天已有同指纹 →
#   不再新建文件，只把已有条目 occurrences +1（事件驱动沉淀的雏形；真正的"沉一行
#   learnings + 人拍板"由 AI 在 closing 第 6 步做，见 .claude/CLAUDE.md §7）。
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
QUEUE="$ROOT/.claude/memory/_review-queue"
mkdir -p "$QUEUE"

PAYLOAD="$(cat)"

# jq 不在就降级：原样落 raw，不做任何解析
if ! command -v jq >/dev/null 2>&1; then
  TS="$(date +%Y-%m-%dT%H-%M-%S)"
  printf '%s' "$PAYLOAD" > "$QUEUE/$TS-subagent-raw.json"
  echo '{}'
  exit 0
fi

# 防 stop_hook_active 死循环（与 stop.sh 一致）
if [ "$(printf '%s' "$PAYLOAD" | jq -r '.stop_hook_active // false')" = "true" ]; then
  echo '{}'
  exit 0
fi

SESSION_ID="$(printf '%s' "$PAYLOAD" | jq -r '.session_id // "unknown"')"
TRANSCRIPT="$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // ""')"
CWD="$(printf '%s' "$PAYLOAD" | jq -r '.cwd // ""')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
# 文件名带 pid + 随机后缀，防同一秒内多个 subagent 几乎同时收尾时时间戳撞车互相覆盖
TS_FILE="$(date +%Y-%m-%d-%H%M%S)-$$-${RANDOM:-0}"
DAY="$(date +%Y-%m-%d)"

# ── 抓首条「真实」user prompt（跳过噪声 / tool_result），并 strip 标签 ──────────
# [BUG-2] 过滤逻辑：
#   - 把 array content 拍平成纯文本（只取 .text，丢 tool_result / image 等）
#   - 删掉 <ide_opened_file>...</...> / <system-reminder> / <command-name>
#     / <local-command-*> 等标签块（含闭合）与孤立的 <...> 标签
#   - 选第一条 strip 后非空且长度 > 4 的，作为意图
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

# ── 失败信号检测（喂经验回流引擎：失败→护栏）─────────────────────────────────
# 只粗分 failure / normal（grep 标记，cheap & 可靠）。更细的 reusable-pattern /
# fact 由 closing 第 6 步 / 反哺时读全文判定。type/lint gate（stop-gate.sh）拦下的
# 失败也会在 transcript 里留 "is_error":true，被这里捕获。
SIGNAL="normal"
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  if grep -qiE '"is_error":[[:space:]]*true|traceback \(most recent|compilation (error|failed)|build failed|command not found|❌|STOP 报' "$TRANSCRIPT" 2>/dev/null; then
    SIGNAL="failure"
  fi
fi

# ── [BUG-1] 多源、按优先级推断 agent 名（取不到记 raw:，绝不写死 unknown）────────
AGENT=""
AGENT_SRC=""

# 1) 显式覆盖
if [ -n "${CLAUDE_SUBAGENT_NAME:-}" ]; then
  AGENT="$CLAUDE_SUBAGENT_NAME"; AGENT_SRC="env"
fi

# 2) 路径 basename —— 仅当是有意义的 subagents/<name> 且非纯 hash（agent-<hex>）
if [ -z "$AGENT" ] && [ -n "$TRANSCRIPT" ] && [[ "$TRANSCRIPT" == *subagents* ]]; then
  BN="$(basename "$TRANSCRIPT" .jsonl)"
  if [ -n "$BN" ] && ! printf '%s' "$BN" | grep -qiE '^agent-[0-9a-f]{6,}$'; then
    AGENT="$BN"; AGENT_SRC="path"
  fi
fi

# 3) prompt 前缀 @kevin-xxx / @xxx（本 OS 路由约定：意图常以 @前缀派单）
if [ -z "$AGENT" ] && [ -n "$USER_INTENT" ]; then
  PFX="$(printf '%s' "$USER_INTENT" \
    | grep -oiE '^@(kevin-)?[a-z][a-z0-9_-]+' \
    | head -1 | sed -E 's/^@(kevin-)?//' || true)"
  if [ -n "$PFX" ]; then AGENT="$PFX"; AGENT_SRC="prefix"; fi
fi

# 4) 关键词回退（按 .claude/CLAUDE.md §1 路由表的心智模式粗分；命中即停）
if [ -z "$AGENT" ] && [ -n "$USER_INTENT" ]; then
  LC="$(printf '%s' "$USER_INTENT" | tr '[:upper:]' '[:lower:]')"
  case "$LC" in
    *测试*|*test*|*e2e*|*回归*|*失败用例*|*testing-ai*)            AGENT="qa"; AGENT_SRC="keyword" ;;
    *prd*|*需求*|*用户故事*|*字段歧义*|*adr*草拟*|*feature*评估*)   AGENT="product"; AGENT_SRC="keyword" ;;
    *mockup*|*figma*|*视觉*|*配色*|*ui*稿*|*中保真*|*截图锚定*)     AGENT="designer"; AGENT_SRC="keyword" ;;
    *周巡*|*curator*|*抽*skill*|*整合*facts*)                      AGENT="curator"; AGENT_SRC="keyword" ;;
    *代码*|*重构*|*架构*|*契约*|*调试*|*coder*|*实现*|*api*|*数据库*) AGENT="coder"; AGENT_SRC="keyword" ;;
  esac
fi

# 5) 兜底：记 raw 线索（保留可追溯性，不丢信息）
#    transcript 文件确实存在才用其 basename；否则路径无意义，退回 session 前 8 位。
if [ -z "$AGENT" ]; then
  if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    AGENT="raw:$(basename "$TRANSCRIPT" .jsonl)"
  else
    AGENT="raw:${SESSION_ID:0:8}"
  fi
  AGENT_SRC="raw"
fi

# ── [DESIGN] 写入即轻量去重 + 标记（事件驱动雏形，不再纯攒队列）─────────────────
# 指纹 = 当天 + agent + 归一化 intent（去空白/小写，前 120 字）。当天已有同指纹 →
# 把已有条目 occurrences +1（标记"又见一次"），不新建文件。
NORM="$(printf '%s' "$USER_INTENT" | tr '[:upper:]' '[:lower:]' | tr -s ' ' | head -c 120)"
FP="$(printf '%s|%s|%s' "$DAY" "$AGENT" "$NORM" | shasum 2>/dev/null | awk '{print $1}')"
[ -z "$FP" ] && FP="$(printf '%s|%s|%s' "$DAY" "$AGENT" "$NORM" | md5 2>/dev/null || echo "$TS_FILE")"

EXISTING=""
for f in "$QUEUE"/${DAY}-*-subagent.json; do
  [ -e "$f" ] || continue
  if [ "$(jq -r '.fingerprint // ""' "$f" 2>/dev/null)" = "$FP" ]; then
    EXISTING="$f"; break
  fi
done

if [ -n "$EXISTING" ]; then
  # 已见过同类 → occurrences +1，更新 last_seen，不新建
  TMP="$(mktemp -t projectos-subagent.XXXXXX)"
  trap 'rm -f "$TMP"' EXIT
  # occurrences +1；若本次是 failure，把条目升级为 failure（失败比重复更值得 curator 看）
  jq --arg ts "$TS" --arg signal "$SIGNAL" \
    '.occurrences = ((.occurrences // 1) + 1) | .last_seen = $ts
     | (if $signal == "failure" then .signal = "failure" else . end)' \
    "$EXISTING" > "$TMP" && mv "$TMP" "$EXISTING"
  echo '{}'
  exit 0
fi

OUT="$QUEUE/$TS_FILE-subagent.json"
jq -n \
  --arg ts "$TS" \
  --arg session "$SESSION_ID" \
  --arg agent "$AGENT" \
  --arg agent_src "$AGENT_SRC" \
  --arg transcript "$TRANSCRIPT" \
  --arg cwd "$CWD" \
  --arg intent "$USER_INTENT" \
  --arg fp "$FP" \
  --arg signal "$SIGNAL" \
  '{
    type: "subagent",
    timestamp: $ts,
    last_seen: $ts,
    occurrences: 1,
    fingerprint: $fp,
    session_id: $session,
    agent: $agent,
    agent_inferred_from: $agent_src,
    transcript_path: $transcript,
    cwd: $cwd,
    user_intent_snippet: $intent,
    signal: $signal,
    status: "pending"
  }' > "$OUT"

echo '{}'
