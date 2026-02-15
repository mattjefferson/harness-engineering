#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import os
import shutil
import subprocess
import sys
from pathlib import Path


def _die(msg: str, code: int = 1) -> int:
    print(f"Error: {msg}", file=sys.stderr)
    return code


def _fmt_path(p: Path) -> str:
    return str(p.expanduser())


def _run(cmd: list[str], *, dry_run: bool) -> int:
    if dry_run:
        print("[dry-run]", " ".join(cmd))
        return 0
    subprocess.run(cmd, check=True)
    return 0


def _safe_remove_dir(path: Path, *, dry_run: bool) -> None:
    if not path.exists():
        return

    if dry_run:
        print(f"[dry-run] remove legacy Codex skills dir '{_fmt_path(path)}'")
        return

    trash_cmd = shutil.which("trash")
    if trash_cmd:
        print(f"Removing legacy Codex skills dir with trash: {_fmt_path(path)}")
        subprocess.run([trash_cmd, _fmt_path(path)], check=True)
        return

    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d-%H%M%S")
    home = Path.home()
    mac_trash = home / ".Trash"
    if mac_trash.is_dir():
        dest = mac_trash / f"codex-skills-{timestamp}"
        print(f"Moving legacy Codex skills dir to: {_fmt_path(dest)}")
        shutil.move(_fmt_path(path), _fmt_path(dest))
        return

    # Cross-platform fallback: move to a local tombstone directory under home.
    tombstone_root = home / ".trash"
    tombstone_root.mkdir(parents=True, exist_ok=True)
    dest = tombstone_root / f"codex-skills-{timestamp}"
    print(f"Moving legacy Codex skills dir to: {_fmt_path(dest)}")
    shutil.move(_fmt_path(path), _fmt_path(dest))


def _copy_tree(src: Path, dst: Path, *, dry_run: bool) -> None:
    if dry_run:
        print(f"[dry-run] copy '{_fmt_path(src)}' -> '{_fmt_path(dst)}'")
        return

    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(_fmt_path(src), _fmt_path(dst), dirs_exist_ok=True)


def main(argv: list[str]) -> int:
    repo_root = Path(__file__).resolve().parent.parent

    parser = argparse.ArgumentParser(
        prog="install.py",
        description=(
            "Sync repo skills into ~/.agents/skills, then install them into extra tool dirs. "
            "Legacy ~/.codex/skills is removed safely when present."
        ),
    )
    parser.add_argument(
        "--source",
        default=_fmt_path(repo_root / "skills"),
        help="Source skills directory (default: <repo>/skills).",
    )
    parser.add_argument(
        "--agents-home",
        default=os.environ.get("AGENTS_HOME", _fmt_path(Path.home() / ".agents")),
        help="Base .agents directory (default: ~/.agents or $AGENTS_HOME).",
    )
    parser.add_argument(
        "--target",
        action="append",
        default=[],
        help="Additional install target directory (repeatable).",
    )
    parser.add_argument(
        "--no-claude",
        action="store_true",
        help="Skip sync to ~/.claude/skills.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions without copying.",
    )

    args = parser.parse_args(argv)

    source_dir = Path(args.source).expanduser().resolve()
    agents_home = Path(args.agents_home).expanduser().resolve()
    agents_skills_dir = agents_home / "skills"
    legacy_codex_skills_dir = Path.home() / ".codex" / "skills"

    if not source_dir.is_dir():
        return _die(f"Source directory not found: {_fmt_path(source_dir)}", 2)

    _safe_remove_dir(legacy_codex_skills_dir, dry_run=args.dry_run)

    targets: list[Path] = []
    if not args.no_claude:
        targets.append(Path.home() / ".claude" / "skills")
    targets.extend(Path(t).expanduser().resolve() for t in args.target)

    skill_names: list[str] = []
    for child in sorted(source_dir.iterdir()):
        if not child.is_dir():
            continue
        if not (child / "SKILL.md").is_file():
            continue
        skill_names.append(child.name)

    if not skill_names:
        return _die("No installable skills found (expected SKILL.md in each skill dir).", 2)

    print(f"Source: {_fmt_path(source_dir)}")
    print(f"Agents: {_fmt_path(agents_skills_dir)}")
    print("Targets:")
    if not targets:
        print("  - (none)")
    else:
        for t in targets:
            print(f"  - {_fmt_path(t)}")
    print("Skills:")
    for s in skill_names:
        print(f"  - {s}")

    if args.dry_run:
        print(f"[dry-run] mkdir -p '{_fmt_path(agents_skills_dir)}'")
    else:
        agents_skills_dir.mkdir(parents=True, exist_ok=True)

    for skill_name in skill_names:
        _copy_tree(source_dir / skill_name, agents_skills_dir / skill_name, dry_run=args.dry_run)

    for target in targets:
        for skill_name in skill_names:
            _copy_tree(agents_skills_dir / skill_name, target / skill_name, dry_run=args.dry_run)

    print("Install complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

