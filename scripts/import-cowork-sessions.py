#!/usr/bin/env python3
"""
把 Cowork 某个 space 下的所有 session 摘要导出成 markdown，喂给 kevin-curator 消化。

用法：
  python3 import-cowork-sessions.py <space-name>
  e.g.: python3 import-cowork-sessions.py media

输出到：agent-lab/.claude/memory/_review-queue/cowork-<space>-import-<date>.md
"""
import json
import sys
import os
from pathlib import Path
from datetime import datetime, timezone

COWORK_ROOT = Path.home() / "Library/Application Support/Claude/local-agent-mode-sessions"
AGENT_LAB = Path.home() / "Project/profile/project/agent-lab"
OUT_DIR = AGENT_LAB / ".claude/memory/_review-queue"

MAX_MSG_CHARS = 800       # 单条消息截断长度，防止 markdown 文件爆炸
MIN_USER_MSG_LEN = 15      # 太短的 user 消息（如"继续""ok"）跳过
SKIP_SYSTEM_REMINDERS = True  # 跳过 system-reminder 包裹的内容


def find_workspace():
    """找到唯一的 account/workspace 目录"""
    for account in COWORK_ROOT.iterdir():
        if not account.is_dir():
            continue
        for ws in account.iterdir():
            if ws.is_dir() and (ws / "spaces.json").exists():
                return ws
    raise FileNotFoundError("未找到 cowork workspace 目录")


def get_space_folder(workspace: Path, space_name: str) -> str:
    """从 spaces.json 找到指定 space 的 folder 路径"""
    spaces = json.loads((workspace / "spaces.json").read_text())["spaces"]
    for s in spaces:
        if s["name"] == space_name:
            folders = s.get("folders", [])
            if not folders:
                raise ValueError(f"space {space_name} 没有绑定 folder")
            return folders[0]["path"], s.get("instructions", "")
    raise ValueError(f"space {space_name} not found. 可用：{[s['name'] for s in spaces]}")


def find_sessions(workspace: Path, folder_path: str):
    """找出所有 cwd / userSelectedFolders 含指定 folder 的 session"""
    sessions = []
    for f in workspace.glob("local_*.json"):
        try:
            meta = json.loads(f.read_text())
        except Exception:
            continue
        selected = meta.get("userSelectedFolders", [])
        cwd = meta.get("cwd", "")
        if folder_path in selected or folder_path in cwd:
            sessions.append((f, meta))
    sessions.sort(key=lambda x: x[1].get("createdAt", 0))
    return sessions


def extract_text_from_content(content):
    """从 message.content 提取纯文本（跳过 tool_use / tool_result / thinking）"""
    if isinstance(content, str):
        return content.strip()
    if not isinstance(content, list):
        return ""
    parts = []
    for block in content:
        if not isinstance(block, dict):
            continue
        if block.get("type") == "text":
            parts.append(block.get("text", "").strip())
        # 跳过 thinking / tool_use / tool_result / image
    return "\n".join(p for p in parts if p)


def parse_session(session_meta_path: Path):
    """读取一个 session，返回 (元数据, 关键消息列表)"""
    audit_file = session_meta_path.parent / session_meta_path.stem / "audit.jsonl"
    if not audit_file.exists():
        return None

    messages = []
    with audit_file.open() as fh:
        for line in fh:
            try:
                evt = json.loads(line)
            except Exception:
                continue
            etype = evt.get("type")
            if etype not in ("user", "assistant"):
                continue
            msg = evt.get("message", {})
            content = msg.get("content")
            text = extract_text_from_content(content)
            if not text:
                continue
            # 跳过 system-reminder / tool-result-only 这种系统注入
            if SKIP_SYSTEM_REMINDERS and text.startswith("<system-reminder>"):
                continue
            role = "U" if etype == "user" else "A"
            if etype == "user" and len(text) < MIN_USER_MSG_LEN:
                continue
            if len(text) > MAX_MSG_CHARS:
                text = text[:MAX_MSG_CHARS] + "...[truncated]"
            messages.append((role, text))
    return messages


def ts_to_str(ts_ms):
    if not ts_ms:
        return "unknown"
    return datetime.fromtimestamp(ts_ms / 1000, tz=timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M")


def main():
    if len(sys.argv) < 2:
        print("用法: python3 import-cowork-sessions.py <space-name>")
        sys.exit(1)

    space_name = sys.argv[1]
    workspace = find_workspace()
    folder_path, space_instructions = get_space_folder(workspace, space_name)
    sessions = find_sessions(workspace, folder_path)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y-%m-%d")
    out_file = OUT_DIR / f"cowork-{space_name}-import-{today}.md"

    lines = [
        f"# Cowork [{space_name}] Session Import — {today}",
        "",
        f"> **Source**: `{workspace}`",
        f"> **Space folder**: `{folder_path}`",
        f"> **Session count**: {len(sessions)}",
        "",
        "## Cowork Space Instructions (Kevin 当时写给 cowork 自己的 system prompt)",
        "",
        "```",
        space_instructions.strip() or "(empty)",
        "```",
        "",
        "---",
        "",
        "## Sessions（按创建时间正序）",
        "",
    ]

    for i, (meta_path, meta) in enumerate(sessions, 1):
        title = meta.get("title", "(无标题)")
        created = ts_to_str(meta.get("createdAt"))
        updated = ts_to_str(meta.get("lastActivityAt"))
        initial = (meta.get("initialMessage") or "").strip()
        if len(initial) > 300:
            initial = initial[:300] + "..."

        lines.append(f"### {i}. [{created}] {title}")
        lines.append("")
        lines.append(f"- session: `{meta_path.stem}`")
        lines.append(f"- last activity: {updated}")
        lines.append(f"- model: {meta.get('model', 'unknown')}")
        if initial:
            lines.append(f"- 初始消息: {initial}")
        lines.append("")

        msgs = parse_session(meta_path) or []
        # 太长的 session 抽样：超过 30 条消息时只留前 10 + 后 10
        if len(msgs) > 30:
            sample = msgs[:10] + [("...", f"[省略中间 {len(msgs) - 20} 条消息]")] + msgs[-10:]
        else:
            sample = msgs

        if not sample:
            lines.append("_（无可读对话内容）_")
        else:
            lines.append("```")
            for role, text in sample:
                lines.append(f"[{role}] {text}")
                lines.append("")
            lines.append("```")
        lines.append("")
        lines.append("---")
        lines.append("")

    out_file.write_text("\n".join(lines))
    size_kb = out_file.stat().st_size / 1024
    print(f"✅ 写入 {out_file}")
    print(f"   {len(sessions)} sessions, {size_kb:.1f} KB")


if __name__ == "__main__":
    main()
