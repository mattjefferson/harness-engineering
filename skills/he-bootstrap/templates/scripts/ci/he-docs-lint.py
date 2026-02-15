#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIG_PATH = "scripts/ci/he-docs-config.json"


@dataclass(frozen=True)
class Finding:
    level: str  # "error" or "warning"
    file: str
    title: str
    msg: str


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _env_flag(name: str, default: str = "0") -> bool:
    return os.environ.get(name, default) == "1"


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


def _has_exact_line(path: Path, needle: str) -> bool:
    for line in _read_text(path).splitlines():
        if line.rstrip("\n") == needle:
            return True
    return False


def _check_required_docs(cfg: Dict[str, object]) -> List[Finding]:
    findings: List[Finding] = []
    required = cfg.get("required_docs", [])
    if not isinstance(required, list):
        return findings
    for doc in required:
        if not isinstance(doc, str):
            continue
        if not (REPO_ROOT / doc).exists():
            findings.append(
                Finding(
                    level="error",
                    file=doc,
                    title="Required doc missing",
                    msg=f"Missing required doc: '{doc}'. Fix: create it (run he-bootstrap if this repo is not bootstrapped) or adjust required_docs in config.",
                )
            )
    return findings


def _check_domain_doc_headings(cfg: Dict[str, object]) -> List[Finding]:
    findings: List[Finding] = []
    required_headings = cfg.get("required_headings", {})
    if not isinstance(required_headings, dict):
        return findings

    for doc, headings in required_headings.items():
        if not isinstance(doc, str):
            continue
        path = REPO_ROOT / doc
        if not path.exists():
            continue  # on-demand domain docs
        if not isinstance(headings, list) or not headings:
            findings.append(
                Finding(
                    level="error",
                    file=doc,
                    title="Missing config headings",
                    msg=f"No required headings configured for '{doc}'. Fix: add required_headings['{doc}'] in config or remove the entry.",
                )
            )
            continue

        missing = [h for h in headings if isinstance(h, str) and not _has_exact_line(path, h)]
        if missing:
            joined = "; ".join(missing)
            findings.append(
                Finding(
                    level="error",
                    file=doc,
                    title="Missing headings",
                    msg=f"Missing required headings in '{doc}': {joined}. Fix: add them.",
                )
            )
    return findings


def _check_seed_markers(cfg: Dict[str, object]) -> List[Finding]:
    findings: List[Finding] = []
    fail = _env_flag("HARNESS_FAIL_ON_SEED_MARKERS", "0")
    domain_docs = cfg.get("domain_docs", [])
    if not isinstance(domain_docs, list):
        return findings

    for doc in domain_docs:
        if not isinstance(doc, str):
            continue
        path = REPO_ROOT / doc
        if not path.exists():
            continue
        text = _read_text(path)
        if "<!-- seed:" not in text:
            continue
        msg = f"Template seed markers remain in '{doc}'. Fix: replace/remove <!-- seed: ... --> blocks once this repo has real domain context."
        findings.append(
            Finding(
                level="error" if fail else "warning",
                file=doc,
                title="Seed markers present",
                msg=msg,
            )
        )
    return findings


def _check_generated_last_updated() -> List[Finding]:
    findings: List[Finding] = []
    gen_dir = REPO_ROOT / "docs" / "generated"
    if not gen_dir.exists():
        return findings

    fail = _env_flag("HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS", "0")
    for path in sorted(gen_dir.glob("*.md")):
        rel = str(path.relative_to(REPO_ROOT))
        if rel in ("docs/generated/README.md", "docs/generated/memory.md"):
            continue
        text = _read_text(path)
        if not re.search(r"^[ \t]*-[ \t]*last_updated:[ \t]*", text, flags=re.MULTILINE):
            findings.append(
                Finding(
                    level="error",
                    file=rel,
                    title="Missing last_updated",
                    msg=f"Generated doc '{rel}' must include a 'last_updated' line. Fix: add e.g. '- last_updated: 2026-02-15 12:34'.",
                )
            )
        if re.search(r"last_updated:[ \t]*<YYYY-", text):
            findings.append(
                Finding(
                    level="error" if fail else "warning",
                    file=rel,
                    title="Placeholder last_updated",
                    msg=f"Generated doc '{rel}' has a placeholder last_updated value. Fix: replace with a real timestamp.",
                )
            )
    return findings


def main(argv: Sequence[str]) -> int:
    try:
        cfg = _load_config()
    except Exception as e:
        print(f"Error: he-docs-lint missing/invalid config: {e}", file=sys.stderr)
        return 2

    print("he-docs-lint: starting")
    print("Repro: python scripts/ci/he-docs-lint.py")

    findings: List[Finding] = []
    findings.extend(_check_required_docs(cfg))

    # Runbooks lint is its own script. Fail fast if it fails.
    runbooks = subprocess.run(
        [sys.executable, "scripts/ci/he-runbooks-lint.py"],
        cwd=str(REPO_ROOT),
    )
    if runbooks.returncode != 0:
        return 1

    findings.extend(_check_domain_doc_headings(cfg))
    findings.extend(_check_seed_markers(cfg))
    findings.extend(_check_generated_last_updated())

    errors = 0
    warnings = 0
    for f in findings:
        if f.level == "error":
            errors += 1
        else:
            warnings += 1
        _emit(f)

    if errors:
        print(f"he-docs-lint: FAIL ({errors} error(s), {warnings} warning(s))", file=sys.stderr)
        return 1

    print(f"he-docs-lint: OK ({warnings} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
