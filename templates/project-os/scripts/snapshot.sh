#!/usr/bin/env bash
# snapshot.sh — 客户原始材料加锁（接料 Step0 的 P1，dongjiaoshan 漏做的那条）
#
# 为什么要它：origin/ 是只读基线，但客户偶尔"偷偷改了 xlsx 又发一版同名文件"。
# 不留 md5 基线，AI 会拿新版当旧版用，引发隐性 schema 漂移（dongjiaoshan 多次 CR 的根因）。
# 用法：
#   ./snapshot.sh baseline   # 接料完成 / 客户给新材料时，存当前 origin/ 的 md5 基线
#   ./snapshot.sh check      # 任何时候（建议 §0 自检 / 每日开工跑），diff 不一致 → 提示开 CR
set -euo pipefail

ORIGIN="$(cd "$(dirname "$0")/../doc/origin" && pwd)"   # 客户原始材料目录（只读）
BASELINE="$ORIGIN/.md5.baseline"                          # 基线指纹（纳入 git，可审计）

snapshot() {  # 对 origin/ 下原始材料算 md5（排除衍生品 _analysis/ 和基线文件自身）
  find "$ORIGIN" -type f ! -path '*/_analysis/*' ! -name '.md5.baseline' -print0 \
    | sort -z | xargs -0 md5sum | sed "s#$ORIGIN/##"
}

case "${1:-check}" in
  baseline) snapshot > "$BASELINE"; echo "✅ 基线已存：$BASELINE（$(wc -l < "$BASELINE") 个文件）" ;;
  check)
    [ -f "$BASELINE" ] || { echo "⚠️ 无基线，先跑：$0 baseline"; exit 1; }
    if diff <(snapshot) "$BASELINE" >/tmp/origin_diff.$$ 2>&1; then
      echo "✅ origin/ 与基线一致，无偷改"
    else
      echo "🚨 origin/ 与基线不一致！客户可能改了原始材料 → 必须走 CR（doc/changes.md）再用新版："
      cat /tmp/origin_diff.$$; rm -f /tmp/origin_diff.$$; exit 2
    fi ;;
  *) echo "用法：$0 {baseline|check}"; exit 1 ;;
esac
