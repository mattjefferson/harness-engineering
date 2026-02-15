#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import stat
from pathlib import Path


def copy_if_missing(target_root: Path, template_root: Path, target_rel: str, template_rel: str) -> None:
    target = target_root / target_rel
    if target.exists():
        return
    src = template_root / template_rel
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")


def make_executable_if_present(path: Path) -> None:
    try:
        if not path.exists():
            return
        mode = path.stat().st_mode
        path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    except Exception:
        # Best-effort. Windows and some filesystems may not support chmod semantics.
        return


def main() -> int:
    p = argparse.ArgumentParser(description="Bootstrap a repo for the harness-engineered workflow.")
    p.add_argument("--with-architecture", action="store_true", help="Create ARCHITECTURE.md if missing")
    args = p.parse_args()

    template_root = Path(__file__).resolve().parent
    target_root = Path.cwd()

    # Create baseline directories.
    for rel in (
        "docs/specs",
        "docs/spikes",
        "docs/plans/active",
        "docs/plans/completed",
        "docs/design-docs",
        "docs/generated",
        "docs/runbooks",
        "scripts/ci",
        "scripts/runbooks",
        ".github/workflows",
    ):
        (target_root / rel).mkdir(parents=True, exist_ok=True)

    copy_if_missing(target_root, template_root, "AGENTS.md", "AGENTS.md")
    if args.with_architecture:
        copy_if_missing(target_root, template_root, "ARCHITECTURE.md", "ARCHITECTURE.md")

    copy_if_missing(target_root, template_root, "docs/specs/index.md", "docs/specs/index.md")
    copy_if_missing(target_root, template_root, "docs/plans/tech-debt-tracker.md", "docs/plans/tech-debt-tracker.md")
    copy_if_missing(target_root, template_root, "docs/specs/README.md", "docs/specs/README.md")
    copy_if_missing(target_root, template_root, "docs/spikes/README.md", "docs/spikes/README.md")
    copy_if_missing(target_root, template_root, "docs/plans/README.md", "docs/plans/README.md")
    copy_if_missing(target_root, template_root, "docs/generated/README.md", "docs/generated/README.md")
    copy_if_missing(target_root, template_root, "docs/generated/db-schema.md", "docs/generated/db-schema.md")
    copy_if_missing(target_root, template_root, "docs/design-docs/index.md", "docs/design-docs/index.md")
    copy_if_missing(target_root, template_root, "docs/PLANS.md", "docs/PLANS.md")
    copy_if_missing(target_root, template_root, "docs/DOMAIN_DOCS.md", "docs/DOMAIN_DOCS.md")
    copy_if_missing(target_root, template_root, "docs/generated/memory.md", "docs/generated/memory.md")

    for rb in (
        "update-agents-md.md",
        "update-domain-docs.md",
        "verify-release.md",
        "record-evidence.md",
        "ci-failures.md",
        "escalation.md",
        "merge-change.md",
        "code-review.md",
        "review-findings.md",
        "address-review-findings.md",
        "validate-current-state.md",
        "reproduce-bug.md",
        "pull-request.md",
        "respond-to-feedback.md",
    ):
        copy_if_missing(target_root, template_root, f"docs/runbooks/{rb}", f"docs/runbooks/{rb}")

    # CI gates for domain docs + artifact structure (specs/plans/spikes) + runbooks.
    copy_if_missing(target_root, template_root, "scripts/ci/he-docs-config.json", "scripts/ci/he-docs-config.json")
    copy_if_missing(target_root, template_root, "scripts/ci/he-runbooks-lint.py", "scripts/ci/he-runbooks-lint.py")
    copy_if_missing(target_root, template_root, "scripts/ci/he-docs-lint.py", "scripts/ci/he-docs-lint.py")
    copy_if_missing(target_root, template_root, "scripts/ci/he-docs-drift.py", "scripts/ci/he-docs-drift.py")
    copy_if_missing(target_root, template_root, "scripts/ci/he-specs-lint.py", "scripts/ci/he-specs-lint.py")
    copy_if_missing(target_root, template_root, "scripts/ci/he-plans-lint.py", "scripts/ci/he-plans-lint.py")
    copy_if_missing(target_root, template_root, "scripts/ci/he-spikes-lint.py", "scripts/ci/he-spikes-lint.py")
    copy_if_missing(target_root, template_root, "scripts/runbooks/select-runbooks.py", "scripts/runbooks/select-runbooks.py")
    copy_if_missing(target_root, template_root, ".github/workflows/harness-docs.yml", ".github/workflows/harness-docs.yml")

    # Make runnable locally (best-effort).
    for rel in (
        "scripts/ci/he-runbooks-lint.py",
        "scripts/ci/he-docs-lint.py",
        "scripts/ci/he-docs-drift.py",
        "scripts/ci/he-specs-lint.py",
        "scripts/ci/he-plans-lint.py",
        "scripts/ci/he-spikes-lint.py",
        "scripts/runbooks/select-runbooks.py",
    ):
        make_executable_if_present(target_root / rel)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
