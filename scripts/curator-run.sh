#!/bin/zsh
# curator 周巡 wrapper —— 由 launchd (com.kevin.agent-lab-curator) 触发
#
# 为什么需要 wrapper 而不是 plist 直接调 claude：
#   1. launchd 的 StartCalendarInterval 在 Mac 睡眠时错过【不补跑】。本机 sleep=30min，
#      周日 21:30 不保证醒着。故 plist 配周日/周一/周二三个触发点，靠本脚本【幂等】保证
#      一周只真跑一次（锚定 ISO 周号，不随补跑漂移）。
#   2. headless 写 .claude/ 是 protected path，必须 --dangerously-skip-permissions
#      （Claude Code ≥ 2.1.126 才允许）。

PROJ="/Users/wkui/Project/profile/project/agent-lab"
STAMP="$PROJ/logs/.last-curator-week"
THIS_WEEK=$(date +%G-%V)   # ISO 年-周号，如 2026-23

if [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$THIS_WEEK" ]; then
  echo "[$(date '+%F %T')] 本周 ($THIS_WEEK) 已跑过，跳过"
  exit 0
fi

echo "[$(date '+%F %T')] ===== 触发 curator 周巡 ($THIS_WEEK) ====="
cd "$PROJ" || { echo "cd 失败"; exit 1; }

/opt/homebrew/bin/claude -p "$(cat "$PROJ/scripts/curator-prompt.txt")" --dangerously-skip-permissions
RC=$?

if [ $RC -eq 0 ]; then
  echo "$THIS_WEEK" > "$STAMP"
  echo "[$(date '+%F %T')] ===== 周巡完成 (exit 0)，已标记本周 ====="
else
  echo "[$(date '+%F %T')] !!!!! 周巡失败 (exit $RC)，未标记，下个触发日 (周一/周二) 会重试 !!!!!"
fi
