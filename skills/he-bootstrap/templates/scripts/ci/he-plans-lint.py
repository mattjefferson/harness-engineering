#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIG_PATH = "scripts/ci/he-docs-config.json"


@dataclass(frozen=True)
class Finding:
    level: str
    file: str
    title: str
    msg: str


DEFAULT_REQUIRED_HEADINGS = [
    "## Purpose / Big Picture",
    "## Progress",
    "## Surprises & Discoveries",
    "## Decision Log",
    "## Outcomes & Retrospective",
    "## Context and Orientation",
    "## Milestones",
    "## Plan of Work",
    "## Concrete Steps",
    "## Validation and Acceptance",
    "## Idempotence and Recovery",
    "## Artifacts and Notes",
    "## Interfaces and Dependencies",
    "## Pull Request",
    "## Review Findings",
    "## Verify/Release Decision",
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


def _frontmatter_kv(frontmatter: str) -> Dict[str, str]:
    kv: Dict[str, str] = {}
    for raw in frontmatter.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        kv[k.strip()] = v.strip()
    return kv


def _has_exact_line(text: str, needle: str) -> bool:
    for line in text.splitlines():
        if line == needle:
            return True
    return False


def _section_lines(text: str, heading: str) -> List[str]:
    lines = text.splitlines()
    out: List[str] = []
    in_section = False
    for line in lines:
        if line == heading:
            in_section = True
            continue
        if in_section and line.startswith("## "):
            break
        if in_section:
            out.append(line)
    return out


def _check_placeholders(file_rel: str, text: str, patterns: List[str], fail: bool) -> List[Finding]:
    findings: List[Finding] = []
    for p in patterns:
        if p and p in text:
            msg = f"Plan '{file_rel}' contains placeholder token '{p}'."
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


def _check_progress(file_rel: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    progress_lines = _section_lines(text, "## Progress")
    if not any(line.strip() for line in progress_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Missing Progress content",
                msg=f"Plan '{file_rel}' has an empty ## Progress section.",
            )
        )
        return findings

    # - [ ] (2026-02-15T12:00:00Z) P1 ...
    rx = re.compile(r"^- \[[ xX]\] \([0-9]{4}-[0-9]{2}-[0-9]{2}[^)]*\) P[0-9]+")
    if not any(rx.search(line) for line in progress_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Progress format",
                msg=(
                    f"Plan '{file_rel}' must include timestamped progress checkboxes with IDs "
                    "(e.g. '- [ ] (2026-02-15T12:00:00Z) P1 ...')."
                ),
            )
        )
    return findings


def _check_checklists_only_in_progress(file_rel: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    lines = text.splitlines()
    in_progress = False
    bad = False
    for line in lines:
        if line == "## Progress":
            in_progress = True
            continue
        if line.startswith("## "):
            in_progress = False
        if re.match(r"^- \[[ xX]\]", line):
            if not in_progress:
                bad = True
                break
    if bad:
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Checklist scope",
                msg=f"Plan '{file_rel}' contains checklist items outside ## Progress.",
            )
        )
    return findings


def _check_decision_log_shape(file_rel: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    decision_lines = _section_lines(text, "## Decision Log")
    if not any(line.strip() for line in decision_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Missing Decision Log content",
                msg=f"Plan '{file_rel}' has an empty ## Decision Log section.",
            )
        )
        return findings

    if not any(line.startswith("- Decision:") for line in decision_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Decision format",
                msg=f"Plan '{file_rel}' should record decisions using '- Decision:' entries.",
            )
        )
    return findings


def _check_revision_notes_shape(file_rel: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    rev_lines = _section_lines(text, "## Revision Notes")
    if not any(line.strip() for line in rev_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Missing Revision Notes content",
                msg=f"Plan '{file_rel}' has an empty ## Revision Notes section.",
            )
        )
        return findings

    if not any(line.startswith("- ") for line in rev_lines):
        findings.append(
            Finding(
                level="error",
                file=file_rel,
                title="Revision Notes format",
                msg=f"Plan '{file_rel}' should include at least one bullet in ## Revision Notes.",
            )
        )
    return findings


def _check_plan(path: Path, cfg: Dict[str, object]) -> List[Finding]:
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
                msg=f"Plan '{rel}' must start with YAML frontmatter delimited by '---' lines.",
            )
        )
        return findings

    fm = _frontmatter_kv(fm_block)
    required_keys = cfg.get("required_plan_frontmatter_keys", [])
    if not isinstance(required_keys, list) or not required_keys:
        required_keys = []
    for k in required_keys:
        if isinstance(k, str) and k not in fm:
            findings.append(
                Finding(
                    level="error",
                    file=rel,
                    title="Missing frontmatter key",
                    msg=f"Plan '{rel}' missing YAML frontmatter key '{k}:'.",
                )
            )

    plan_mode = fm.get("plan_mode", "").strip()
    if plan_mode and plan_mode not in ("trivial", "lightweight", "execution"):
        findings.append(
            Finding(
                level="error",
                file=rel,
                title="Invalid plan_mode",
                msg=f"Plan '{rel}' has invalid plan_mode '{plan_mode}' (must be 'trivial', 'lightweight', or 'execution').",
            )
        )

    for h in DEFAULT_REQUIRED_HEADINGS:
        if not _has_exact_line(text, h):
            findings.append(
                Finding(
                    level="error",
                    file=rel,
                    title="Missing heading",
                    msg=f"Plan '{rel}' missing required heading line '{h}'.",
                )
            )

    findings.extend(_check_progress(rel, text))
    findings.extend(_check_checklists_only_in_progress(rel, text))
    findings.extend(_check_decision_log_shape(rel, text))
    findings.extend(_check_revision_notes_shape(rel, text))

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
        print(f"Error: he-plans-lint missing/invalid config: {e}", file=sys.stderr)
        return 2

    print("he-plans-lint: starting")
    print("Repro: python scripts/ci/he-plans-lint.py")

    plans_active = REPO_ROOT / "docs" / "plans" / "active"
    plans_completed = REPO_ROOT / "docs" / "plans" / "completed"

    files: List[Path] = []
    if plans_active.exists():
        files.extend(sorted(plans_active.glob("*.md")))

    lint_completed = bool(cfg.get("lint_completed_plans", True))
    if lint_completed and plans_completed.exists():
        files.extend(sorted(plans_completed.glob("*.md")))

    if not files:
        print("he-plans-lint: OK (no plan files)")
        return 0

    findings: List[Finding] = []
    for path in files:
        findings.extend(_check_plan(path, cfg))

    errors = 0
    warnings = 0
    for f in findings:
        if f.level == "error":
            errors += 1
        else:
            warnings += 1
        _emit(f)

    if errors:
        print(f"he-plans-lint: FAIL ({errors} error(s), {warnings} warning(s))", file=sys.stderr)
        return 1
    print(f"he-plans-lint: OK ({warnings} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
