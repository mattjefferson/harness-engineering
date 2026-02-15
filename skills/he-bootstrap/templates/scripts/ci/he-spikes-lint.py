#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIG_PATH = "scripts/ci/he-docs-config.json"


@dataclass(frozen=True)
class Finding:
    level: str
    file: str
    title: str
    msg: str


DEFAULT_REQUIRED_HEADINGS = [
    "## Context",
    "## Validation Goal",
    "## Approach",
    "## Findings",
    "## Decisions",
    "## Recommendation",
    "## Impact on Upstream Docs",
    "## Spike Code",
    "## Remaining Unknowns",
    "## Time Spent",
    "## Revision Notes",
]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _load_config() -> Dict[str, object]:
    config_path = os.environ.get("HARNESS_DOCS_CONFIG", DEFAULT_CONFIG_PATH)
    path = REPO_ROOT / config_path
    if not path.exists():
        raise FileNotFoundError(
            f"Missing config '{config_path}'. Fix: create it (bootstrap should do this) or set HARNESS_DOCS_CONFIG."
        )
    data = json.loads(_read_text(path))
    if not isinstance(data, dict):
        raise ValueError("Config must be a JSON object.")
    return data


def _gh_annotate(f: Finding) -> None:
    if f.file:
        print(f"::{f.level} file={f.file},title={f.title}::{f.msg}")
    else:
        print(f"::{f.level} title={f.title}::{f.msg}")


def _emit(f: Finding) -> None:
    _gh_annotate(f)
    print(f"{f.level.upper()}: {f.msg}", file=sys.stderr)


def _extract_frontmatter(text: str) -> Optional[str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[1:i])
    return None


def _frontmatter_keys(frontmatter: str) -> List[str]:
    keys: List[str] = []
    for raw in frontmatter.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        k, _ = line.split(":", 1)
        keys.append(k.strip())
    return keys


def _has_exact_line(text: str, needle: str) -> bool:
    for line in text.splitlines():
        if line == needle:
            return True
    return False


def _check_placeholders(file_rel: str, text: str, patterns: List[str], fail: bool) -> List[Finding]:
    findings: List[Finding] = []
    for p in patterns:
        if p and p in text:
            msg = f"Spike '{file_rel}' contains placeholder token '{p}'."
            findings.append(
                Finding(
                    level="error" if fail else "warning",
                    file=file_rel,
                    title="Placeholder token",
                    msg=msg if fail else f"{msg} (Set HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS=1 to enforce.)",
                )
            )
            break
    return findings


def _check_spike(path: Path, cfg: Dict[str, object]) -> List[Finding]:
    rel = str(path.relative_to(REPO_ROOT))
    text = _read_text(path)

    findings: List[Finding] = []
    fm_block = _extract_frontmatter(text)
    if fm_block is None:
        findings.append(
            Finding(
                level="error",
                file=rel,
                title="Missing YAML frontmatter",
                msg=f"Spike '{rel}' must start with YAML frontmatter delimited by '---' lines.",
            )
        )
        return findings

    fm_keys = set(_frontmatter_keys(fm_block))
    required_keys = cfg.get("required_spike_frontmatter_keys", [])
    if not isinstance(required_keys, list) or not required_keys:
        required_keys = []
    for k in required_keys:
        if isinstance(k, str) and k not in fm_keys:
            findings.append(
                Finding(
                    level="error",
                    file=rel,
                    title="Missing frontmatter key",
                    msg=f"Spike '{rel}' missing YAML frontmatter key '{k}:'.",
                )
            )

    for h in DEFAULT_REQUIRED_HEADINGS:
        if not _has_exact_line(text, h):
            findings.append(
                Finding(
                    level="error",
                    file=rel,
                    title="Missing heading",
                    msg=f"Spike '{rel}' missing required heading line '{h}'.",
                )
            )

    patterns = cfg.get("artifact_placeholder_patterns", [])
    if not isinstance(patterns, list):
        patterns = []
    fail_ph = os.environ.get("HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS", "0") == "1"
    findings.extend(_check_placeholders(rel, text, [p for p in patterns if isinstance(p, str)], fail_ph))
    return findings


def main(argv: Sequence[str]) -> int:
    try:
        cfg = _load_config()
    except Exception as e:
        print(f"Error: he-spikes-lint missing/invalid config: {e}", file=sys.stderr)
        return 2

    print("he-spikes-lint: starting")
    print("Repro: python scripts/ci/he-spikes-lint.py")

    spikes_dir = REPO_ROOT / "docs" / "spikes"
    if not spikes_dir.exists():
        print("he-spikes-lint: OK (docs/spikes not present)")
        return 0

    files = sorted(spikes_dir.glob("*-spike.md"))
    if not files:
        print("he-spikes-lint: OK (no spike files)")
        return 0

    findings: List[Finding] = []
    for path in files:
        findings.extend(_check_spike(path, cfg))

    errors = 0
    warnings = 0
    for f in findings:
        if f.level == "error":
            errors += 1
        else:
            warnings += 1
        _emit(f)

    if errors:
        print(f"he-spikes-lint: FAIL ({errors} error(s), {warnings} warning(s))", file=sys.stderr)
        return 1
    print(f"he-spikes-lint: OK ({warnings} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

