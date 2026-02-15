#!/usr/bin/env python3

from __future__ import annotations

import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]


BASELINE_REQUIRED_RUNBOOKS = [
    "docs/runbooks/update-agents-md.md",
    "docs/runbooks/update-domain-docs.md",
    "docs/runbooks/code-review.md",
    "docs/runbooks/review-findings.md",
    "docs/runbooks/address-review-findings.md",
    "docs/runbooks/verify-release.md",
    "docs/runbooks/record-evidence.md",
    "docs/runbooks/ci-failures.md",
    "docs/runbooks/escalation.md",
    "docs/runbooks/merge-change.md",
]


@dataclass(frozen=True)
class Finding:
    level: str  # "error" or "warning"
    file: str
    title: str
    msg: str


@dataclass(frozen=True)
class Frontmatter:
    title: Optional[str]
    use_when: Optional[str]
    called_from: List[str]
    keys: List[str]


def _env_flag(name: str, default: str = "0") -> bool:
    return os.environ.get(name, default) == "1"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _extract_frontmatter_block(text: str) -> Optional[str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[1:i])
    return None


def _parse_called_from_inline(value: str) -> List[str]:
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
            if val.startswith("["):
                called_from = _parse_called_from_inline(val)
                i += 1
                continue
            # YAML list form.
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


def _gh_annotate(f: Finding) -> None:
    # GitHub Actions annotation format. Safe elsewhere (just prints).
    if f.file:
        print(f"::{f.level} file={f.file},title={f.title}::{f.msg}")
    else:
        print(f"::{f.level} title={f.title}::{f.msg}")


def _emit(f: Finding) -> None:
    _gh_annotate(f)
    stream = sys.stderr if f.level == "error" else sys.stderr
    print(f"{f.level.upper()}: {f.msg}", file=stream)


def iter_runbooks(runbooks_dir: Path) -> List[Path]:
    if not runbooks_dir.exists():
        return []
    return sorted(runbooks_dir.rglob("*.md"))


def lint_runbook(path: Path, fail_missing_called_from: bool, fail_extra_keys: bool) -> List[Finding]:
    rel = str(path.relative_to(REPO_ROOT))
    text = _read_text(path)
    block = _extract_frontmatter_block(text)
    if block is None:
        return [
            Finding(
                level="error",
                file=rel,
                title="Runbook frontmatter",
                msg=f"Runbook '{rel}' must start with YAML frontmatter ('---').",
            )
        ]

    fm = _parse_frontmatter(block)
    findings: List[Finding] = []

    if not fm.title:
        findings.append(
            Finding(
                level="error",
                file=rel,
                title="Runbook frontmatter",
                msg=f"Runbook '{rel}' frontmatter must include a 'title:' field.",
            )
        )
    if not fm.use_when:
        findings.append(
            Finding(
                level="error",
                file=rel,
                title="Runbook frontmatter",
                msg=f"Runbook '{rel}' frontmatter must include a 'use_when:' field.",
            )
        )

    if "called_from" not in fm.keys or not fm.called_from:
        msg = (
            f"Runbook '{rel}' frontmatter should include non-empty 'called_from:' "
            f"(list of skills/steps where this runbook is applied)."
        )
        findings.append(
            Finding(
                level="error" if fail_missing_called_from else "warning",
                file=rel,
                title="Runbook frontmatter",
                msg=msg,
            )
        )

    allowed = {"title", "use_when", "called_from"}
    extras = sorted({k for k in fm.keys if k not in allowed})
    if extras:
        msg = (
            f"Runbook '{rel}' has extra frontmatter key(s): {', '.join(extras)}. "
            "Prefer keeping runbooks to {title,use_when,called_from} unless you have a strong reason."
        )
        findings.append(
            Finding(
                level="error" if fail_extra_keys else "warning",
                file=rel,
                title="Runbook frontmatter",
                msg=msg,
            )
        )

    return findings


def main(argv: Sequence[str]) -> int:
    fail_missing_called_from = _env_flag("HARNESS_FAIL_ON_MISSING_RUNBOOK_CALLED_FROM", "0")
    fail_extra_keys = _env_flag("HARNESS_FAIL_ON_EXTRA_RUNBOOK_FRONTMATTER", "0")

    runbooks_dir = REPO_ROOT / "docs" / "runbooks"

    errors = 0
    warnings = 0

    print("he-runbooks-lint: starting")
    print("Repro: python scripts/ci/he-runbooks-lint.py")

    for rb in BASELINE_REQUIRED_RUNBOOKS:
        if not (REPO_ROOT / rb).exists():
            errors += 1
            _emit(
                Finding(
                    level="error",
                    file=rb,
                    title="Required runbook missing",
                    msg=f"Missing required runbook: '{rb}'. Fix: create it (run he-bootstrap if this repo is not bootstrapped).",
                )
            )

    for path in iter_runbooks(runbooks_dir):
        for f in lint_runbook(path, fail_missing_called_from, fail_extra_keys):
            if f.level == "error":
                errors += 1
            else:
                warnings += 1
            _emit(f)

    if errors:
        print(f"he-runbooks-lint: FAIL ({errors} error(s), {warnings} warning(s))", file=sys.stderr)
        return 1

    print(f"he-runbooks-lint: OK ({warnings} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

