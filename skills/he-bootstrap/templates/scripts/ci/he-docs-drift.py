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


def _run_git(args: List[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=str(REPO_ROOT),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def _git_has_head_parent() -> bool:
    p = _run_git(["rev-parse", "-q", "--verify", "HEAD~1"])
    return p.returncode == 0


def _changed_files(diff_range: str) -> List[str]:
    if diff_range:
        p = _run_git(["diff", "--name-only", diff_range])
        out = p.stdout
    else:
        p = _run_git(["diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD"])
        out = p.stdout
    return [line.strip() for line in out.splitlines() if line.strip()]


def main(argv: Sequence[str]) -> int:
    try:
        cfg = _load_config()
    except Exception as e:
        print(f"Error: he-docs-drift missing/invalid config: {e}", file=sys.stderr)
        return 2

    base_ref = os.environ.get("GITHUB_BASE_REF", "")
    head_ref = os.environ.get("GITHUB_HEAD_REF", "")

    if base_ref:
        diff_range = f"origin/{base_ref}...HEAD"
    else:
        diff_range = "HEAD~1...HEAD" if _git_has_head_parent() else ""

    print("he-docs-drift: starting", file=sys.stderr)
    print("Repro: python scripts/ci/he-docs-drift.py", file=sys.stderr)
    if base_ref:
        print(f"PR context: base_ref='{base_ref}' head_ref='{head_ref}' diff='{diff_range}'", file=sys.stderr)
    else:
        print(f"Local context: diff='{diff_range}'", file=sys.stderr)

    changed = _changed_files(diff_range)
    if not changed:
        print("he-docs-drift: no changes detected")
        return 0

    changed_docs = {p for p in changed if p.startswith("docs/")}

    drift_rules = cfg.get("drift_rules", [])
    if not isinstance(drift_rules, list):
        drift_rules = []

    missing = 0
    for rule in drift_rules:
        if not isinstance(rule, dict):
            continue
        regex = rule.get("regex")
        doc = rule.get("doc")
        if not isinstance(regex, str) or not isinstance(doc, str):
            continue

        try:
            rx = re.compile(regex)
        except re.error:
            print(f"Error: invalid drift rule regex: {regex}", file=sys.stderr)
            missing = 1
            continue

        matching = [p for p in changed if rx.search(p)]
        if not matching:
            continue

        if doc not in changed_docs:
            sample = "\n".join(f"- {p}" for p in matching[:10])
            print(
                f"::error file={doc},title=Docs drift gate::Missing required doc update '{doc}' when files match /{regex}/ (see job logs for matching files)."
            )
            print(f"Missing doc update: '{doc}' should change when files match /{regex}/.", file=sys.stderr)
            print("Matching files (up to 10):", file=sys.stderr)
            print(sample, file=sys.stderr)
            print(
                f"Fix: update '{doc}' in this PR, or edit drift_rules in '{DEFAULT_CONFIG_PATH}' (or HARNESS_DOCS_CONFIG) if this mapping is wrong.",
                file=sys.stderr,
            )
            missing = 1

    if missing:
        print("Error: docs drift gate failed (see missing doc updates above)", file=sys.stderr)
        return 1

    print("he-docs-drift: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

