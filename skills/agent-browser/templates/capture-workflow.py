#!/usr/bin/env python3
"""
Template: Content Capture Workflow
Purpose: Extract content from web pages (text, screenshots, PDF)
Usage: python capture-workflow.py <url> [output-dir]

Outputs:
  - page-full.png: Full page screenshot
  - page-structure.txt: Page element structure with refs
  - page-text.txt: All text content
  - page.pdf: PDF version

Optional: Load auth state for protected pages.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def _run(cmd: list[str], *, capture: bool = False) -> str:
    if capture:
        out = subprocess.check_output(cmd, text=True)
        return out.strip()
    subprocess.run(cmd, check=True)
    return ""


def main(argv: list[str]) -> int:
    if not argv:
        print("Usage: python capture-workflow.py <url> [output-dir]", file=sys.stderr)
        return 2

    target_url = argv[0]
    output_dir = Path(argv[1] if len(argv) > 1 else ".").resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Capturing: {target_url}")
    print(f"Output dir: {output_dir}")

    # Optional: Load authentication state
    # state_path = Path("./auth-state.json")
    # if state_path.is_file():
    #     print("Loading authentication state...")
    #     _run(["agent-browser", "state", "load", str(state_path)])

    _run(["agent-browser", "open", target_url])
    _run(["agent-browser", "wait", "--load", "networkidle"])

    title = _run(["agent-browser", "get", "title"], capture=True)
    url = _run(["agent-browser", "get", "url"], capture=True)
    print(f"Title: {title}")
    print(f"URL: {url}")

    full_png = output_dir / "page-full.png"
    structure_txt = output_dir / "page-structure.txt"
    text_txt = output_dir / "page-text.txt"
    page_pdf = output_dir / "page.pdf"

    _run(["agent-browser", "screenshot", "--full", str(full_png)])
    print(f"Saved: {full_png}")

    structure = _run(["agent-browser", "snapshot", "-i"], capture=True)
    structure_txt.write_text(structure + "\n", encoding="utf-8")
    print(f"Saved: {structure_txt}")

    body_text = _run(["agent-browser", "get", "text", "body"], capture=True)
    text_txt.write_text(body_text + "\n", encoding="utf-8")
    print(f"Saved: {text_txt}")

    _run(["agent-browser", "pdf", str(page_pdf)])
    print(f"Saved: {page_pdf}")

    # Optional: Extract specific elements using refs from structure
    # main_content = _run(["agent-browser", "get", "text", "@e5"], capture=True)
    # (output_dir / "main-content.txt").write_text(main_content + "\n", encoding="utf-8")

    _run(["agent-browser", "close"])

    print("")
    print("Capture complete:")
    for p in sorted(output_dir.iterdir()):
        print(f"  - {p.name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

