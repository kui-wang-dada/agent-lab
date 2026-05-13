#!/usr/bin/env python3
"""
Markdown deck → PDF（16:9 横版幻灯片）

用法:
    python3 scripts/build-deck-pdf.py docs/hermes-clone-deck.md

输出:
    docs/hermes-clone-deck.pdf

切片规则:
    HTML <hr> (即 markdown 的 ---) 作为分页符。
"""

import re
import sys
from pathlib import Path

import markdown
from weasyprint import HTML, CSS


SLIDE_CSS = """
@page {
    size: 13.33in 8in;          /* 略加高的 16:10，演示和 PDF 阅读两不误 */
    margin: 0.5in 0.8in;
    @bottom-right {
        content: counter(page) " / " counter(pages);
        font-family: "PingFang SC", "Helvetica Neue", sans-serif;
        font-size: 10pt;
        color: #999;
    }
    @bottom-left {
        content: "Kevin Wang · 2026-05";
        font-family: "PingFang SC", "Helvetica Neue", sans-serif;
        font-size: 10pt;
        color: #999;
    }
}

* {
    box-sizing: border-box;
}

body {
    font-family: "PingFang SC", "Helvetica Neue", "Hiragino Sans", sans-serif;
    color: #1a1a1a;
    line-height: 1.25;
    font-size: 12.5pt;
}

/* 每个 hr 触发分页 */
hr {
    page-break-after: always;
    border: none;
    margin: 0;
    height: 0;
    visibility: hidden;
}

h1 {
    font-size: 26pt;
    font-weight: 600;
    color: #c47f3a;          /* 暖色调 */
    margin: 0 0 0.25em 0;
    border-bottom: 3px solid #c47f3a;
    padding-bottom: 0.15em;
}

h2 {
    font-size: 16pt;
    font-weight: 500;
    color: #2c3e50;
    margin: 0.4em 0 0.2em 0;
}

h3 {
    font-size: 13pt;
    font-weight: 500;
    color: #34495e;
    margin: 0.35em 0 0.15em 0;
}

p {
    margin: 0.25em 0;
}

ul, ol {
    margin: 0.3em 0;
    padding-left: 1.4em;
}

li {
    margin: 0.1em 0;
}

li > strong {
    color: #c47f3a;
}

blockquote {
    border-left: 4px solid #c47f3a;
    background: #faf6ef;
    padding: 0.35em 0.7em;
    margin: 0.3em 0;
    font-style: italic;
    color: #555;
    /* 允许跨页拆分，避免和 H2 标签分离 */
    page-break-inside: auto;
    break-inside: auto;
    orphans: 2;
    widows: 2;
}

blockquote p {
    margin: 0.15em 0;
}

code {
    font-family: "JetBrains Mono", "SF Mono", Menlo, "PingFang SC", monospace;
    background: #f4f1ec;
    padding: 0.1em 0.3em;
    border-radius: 3px;
    font-size: 0.9em;
}

pre {
    background: #1e1e1e;
    color: #e8e3d8;
    padding: 0.5em 0.7em;
    border-radius: 6px;
    overflow-x: auto;
    line-height: 1.15;
    font-size: 9pt;
    margin: 0.3em 0;
    white-space: pre;
}

pre code {
    background: transparent;
    color: inherit;
    padding: 0;
    font-size: inherit;
    border-radius: 0;
    /* CJK 在前防止 Menlo 用 .notdef 阻断 fallback */
    font-family: "PingFang SC", "Hiragino Sans GB", "Menlo", monospace;
}

/* 表格（如有）*/
table {
    border-collapse: collapse;
    margin: 0.5em 0;
    width: 100%;
    font-size: 12pt;
}
th, td {
    border: 1px solid #ddd;
    padding: 0.4em 0.6em;
    text-align: left;
}
th {
    background: #f4f1ec;
    font-weight: 600;
}

/* 封面页特殊样式（第一个 slide） */
body > h1:first-of-type {
    margin-top: 1.5in;
    text-align: center;
    font-size: 42pt;
    border: none;
    padding: 0;
}

body > h1:first-of-type + h2 {
    text-align: center;
    color: #888;
    font-size: 22pt;
    margin-top: 0.3em;
}

/* 最后一页"谢谢"放大居中（body 的最后一个 p）*/
body > p:last-child {
    text-align: center;
    font-size: 36pt;
    margin-top: 2.5in;
    color: #c47f3a;
    font-weight: 600;
}
"""


def build(md_path: Path, out_path: Path) -> None:
    md_text = md_path.read_text(encoding="utf-8")

    # 去掉 frontmatter（--- 开头的 YAML 块）
    md_text = re.sub(r"^---\n.*?\n---\n", "", md_text, count=1, flags=re.DOTALL)

    # 去掉 HTML 注释（<!-- Slide x/y --> 之类）
    md_text = re.sub(r"<!--.*?-->", "", md_text, flags=re.DOTALL)

    html_body = markdown.markdown(
        md_text,
        extensions=["fenced_code", "tables", "codehilite"],
    )

    full_html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <title>{md_path.stem}</title>
</head>
<body>
{html_body}
</body>
</html>
"""

    HTML(string=full_html, base_url=str(md_path.parent)).write_pdf(
        str(out_path),
        stylesheets=[CSS(string=SLIDE_CSS)],
    )

    pages = full_html.count("<hr") + 1
    size_kb = out_path.stat().st_size / 1024
    print(f"✅ {out_path}  ({pages} pages, {size_kb:.1f} KB)")


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: build-deck-pdf.py <input.md> [output.pdf]")
        sys.exit(1)

    md_path = Path(sys.argv[1])
    if not md_path.exists():
        print(f"❌ {md_path} not found")
        sys.exit(1)

    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else md_path.with_suffix(".pdf")
    build(md_path, out_path)


if __name__ == "__main__":
    main()
