#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class Frontmatter:
    title: Optional[str]
    use_when: Optional[str]
    called_from: List[str]
    keys: List[str]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _extract_frontmatter_block(text: str) -> Optional[str]:
    # Strict: frontmatter must be the first block in the file.
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[1:i])
    return None


def _parse_called_from_from_inline_list(value: str) -> List[str]:
    # value is e.g. [a, b]
    inner = value.strip()
    if not inner.startswith("[") or not inner.endswith("]"):
        return []
    inner = inner[1:-1].strip()
    if not inner:
        return []
    parts = [p.strip() for p in inner.split(",")]
    return [p for p in parts if p]


def _parse_frontmatter(block: str) -> Frontmatter:
    title: Optional[str] = None
    use_when: Optional[str] = None
    called_from: List[str] = []
    keys: List[str] = []

    lines = block.splitlines()
    i = 0
    while i < len(lines):
        raw = lines[i]
        line = raw.strip()
        if not line or line.startswith("#"):
            i += 1
            continue

        if ":" not in line:
            i += 1
            continue

        k, v = line.split(":", 1)
        key = k.strip()
        val = v.strip()
        if key:
            keys.append(key)

        if key == "title":
            title = val.strip().strip('"').strip("'")
            i += 1
            continue
        if key == "use_when":
            use_when = val.strip().strip('"').strip("'")
            i += 1
            continue
        if key == "called_from":
            # Support inline: called_from: [a, b]
            if val.startswith("["):
                called_from = _parse_called_from_from_inline_list(val)
                i += 1
                continue

            # Support YAML list:
            # called_from:
            #   - he-review
            items: List[str] = []
            i += 1
            while i < len(lines):
                sub = lines[i]
                sub_stripped = sub.strip()
                if not sub_stripped:
                    i += 1
                    continue
                if ":" in sub_stripped and not sub_stripped.startswith("-"):
                    break
                if sub_stripped.startswith("-"):
                    item = sub_stripped[1:].strip().strip('"').strip("'")
                    if item:
                        items.append(item)
                i += 1
            called_from = items
            continue

        i += 1

    return Frontmatter(title=title, use_when=use_when, called_from=called_from, keys=keys)


def iter_runbooks(runbooks_dir: Path) -> Iterable[Path]:
    if not runbooks_dir.exists():
        return []
    # Allow subfolders; stable sort for deterministic behavior.
    return sorted(runbooks_dir.rglob("*.md"))


def matches(fm: Frontmatter, skill: str, step: Optional[str]) -> bool:
    if skill in fm.called_from:
        return True
    if step and step in fm.called_from:
        return True
    return False


def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(description="Select runbooks by called_from frontmatter.")
    p.add_argument("--skill", required=True, help="Skill name, e.g. he-review")
    p.add_argument("--step", required=False, help="Optional workflow step name")
    args = p.parse_args(argv)

    runbooks_dir = REPO_ROOT / "docs" / "runbooks"
    for path in iter_runbooks(runbooks_dir):
        text = _read_text(path)
        block = _extract_frontmatter_block(text)
        if block is None:
            continue
        fm = _parse_frontmatter(block)
        if matches(fm, args.skill, args.step):
            rel = path.relative_to(REPO_ROOT)
            print(str(rel))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

