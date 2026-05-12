#!/usr/bin/env bash
# SessionStart hook
# 注入 USER.md 摘要 + SKILLS_INDEX 给 agent，让它不靠 CLAUDE.md 自觉去 Read。
# 输出 JSON 到 stdout，hookSpecificOutput.additionalContext 会被注入到 model context。
#
# stdin payload (Claude Code 提供): { session_id, transcript_path, cwd, hook_event_name, ... }

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
USER_MD="$ROOT/.claude/memory/USER.md"
SKILLS_IDX="$ROOT/.claude/memory/SKILLS_INDEX.md"

# 静默吞掉 stdin（Claude 不要求脚本读它，但 stdin 是开着的）
cat > /dev/null 2>&1 || true

# 拼接注入内容
{
  echo "## 自动注入：用户模型摘要"
  echo
  if [ -f "$USER_MD" ]; then
    # 只取 Identity / Working Style / Current Focus / Hot Context 这 4 节，截到 80 行
    awk '/^## (Identity|Working Style|Current Focus|Hot Context|Critical Constraints)/{p=1} /^---$/{p=0} p' "$USER_MD" | head -80
  else
    echo "(USER.md 不存在)"
  fi
  echo
  echo "## 自动注入：可复用 Skill 索引"
  echo
  if [ -f "$SKILLS_IDX" ]; then
    head -40 "$SKILLS_IDX"
  else
    echo "(SKILLS_INDEX.md 不存在)"
  fi
} > /tmp/agent-lab-session-start-context.txt

# 用 jq 安全打包成 JSON
if command -v jq >/dev/null 2>&1; then
  jq -Rs '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: .
    }
  }' < /tmp/agent-lab-session-start-context.txt
else
  # 降级：jq 没有时简单用 systemMessage
  echo '{"systemMessage":"SessionStart hook: jq missing, USER.md not injected"}'
fi
