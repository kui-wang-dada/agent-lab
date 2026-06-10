#!/usr/bin/env bash
# Stop-gate hook —— type/lint 硬 gate（同步、可阻塞）。SP2 验证骨干 #1 落地。
#
# 强默认 + 可关：读 `.claude/verify-cmd`（一行 = 校验命令，# 开头是注释）。
#   - 文件缺 / 空 → gate 关（降级为 closing audit 一次性扫）——慢栈（mvn compile）默认走这条。
#   - 文件有命令 → 每次 turn 结束跑；非零退出 → block，把输出喂回 AI 让它当场修闭环。
# 快栈（tsc --noEmit / vue-tsc / eslint）建议开（cp verify-cmd.example verify-cmd 并按栈填）。
#
# 与 stop.sh（async 入队）并列挂在 settings.json 的 Stop 上：本文件同步先跑，可拦截。

set -uo pipefail   # 不用 -e：校验命令失败是预期路径，要自己处理 RC

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
CMD_FILE="$ROOT/.claude/verify-cmd"

PAYLOAD="$(cat)"

# jq 缺 → 不阻塞（gate 是增益，不因环境缺失把人卡死）
command -v jq >/dev/null 2>&1 || { echo '{}'; exit 0; }

# 防死循环：gate 已触发过一轮 continuation → 放行
if [ "$(printf '%s' "$PAYLOAD" | jq -r '.stop_hook_active // false')" = "true" ]; then
  echo '{}'; exit 0
fi

# 未配置校验命令 → 关（降级 closing audit）
[ -s "$CMD_FILE" ] || { echo '{}'; exit 0; }
VERIFY_CMD="$(grep -vE '^[[:space:]]*#' "$CMD_FILE" | grep -vE '^[[:space:]]*$' | head -1)"
[ -n "$VERIFY_CMD" ] || { echo '{}'; exit 0; }

# 跑校验（项目根）。eval 允许 `tsc --noEmit && eslint .` 这类组合命令；
# verify-cmd 是项目主自己的本地配置文件，非外部输入。
OUT="$(cd "$ROOT" && eval "$VERIFY_CMD" 2>&1)"
RC=$?

if [ "$RC" -eq 0 ]; then
  echo '{}'; exit 0
fi

# 失败 → block，喂回尾部输出（截断防爆 context）
# 用 printf %s 占位，避免 $VAR 紧贴中文标点时变量名被多字节字符吞进去（C locale 坑）
TAIL="$(printf '%s' "$OUT" | tail -c 1500)"
REASON="$(printf 'type/lint gate 失败（命令: %s, exit %s）。修完再结束本轮:\n%s' "$VERIFY_CMD" "$RC" "$TAIL")"
jq -n --arg r "$REASON" '{decision:"block", reason:$r}'
exit 0
