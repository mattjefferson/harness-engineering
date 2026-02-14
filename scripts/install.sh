#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/skills"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
AGENTS_SKILLS_DIR="$AGENTS_HOME/skills"
DRY_RUN=0
INCLUDE_CODEX=1
INCLUDE_CLAUDE=1

declare -a EXTRA_TARGETS=()

declare -a TARGETS=()

die() {
  echo "Error: $*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Sync repo skills into ~/.agents/skills, then install them into tool skill dirs.

Options:
  --source <dir>        Source skills directory (default: ./skills)
  --agents-home <dir>   Base .agents directory (default: ~/.agents)
  --target <dir>        Additional install target directory (repeatable)
  --no-codex            Skip ~/.codex/skills
  --no-claude           Skip ~/.claude/skills
  --dry-run             Print actions without copying
  -h, --help            Show this help
USAGE
}

copy_tree() {
  local src="$1"
  local dst="$2"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] cp -R '$src' '$dst'"
    return
  fi

  mkdir -p "$dst"
  cp -R "$src" "$dst"
}

install_skill_to_target() {
  local skill_name="$1"
  local target_root="$2"

  mkdir -p "$target_root"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] mkdir -p '$target_root/$skill_name'"
    echo "[dry-run] cp -R '$AGENTS_SKILLS_DIR/$skill_name/.' '$target_root/$skill_name/'"
    return
  fi

  mkdir -p "$target_root/$skill_name"
  cp -R "$AGENTS_SKILLS_DIR/$skill_name/." "$target_root/$skill_name/"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      [[ $# -ge 2 ]] || die "--source requires a value"
      SOURCE_DIR="$2"
      shift 2
      ;;
    --agents-home)
      [[ $# -ge 2 ]] || die "--agents-home requires a value"
      AGENTS_HOME="$2"
      AGENTS_SKILLS_DIR="$AGENTS_HOME/skills"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || die "--target requires a value"
      EXTRA_TARGETS+=("$2")
      shift 2
      ;;
    --no-codex)
      INCLUDE_CODEX=0
      shift
      ;;
    --no-claude)
      INCLUDE_CLAUDE=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

[[ -d "$SOURCE_DIR" ]] || die "Source directory not found: $SOURCE_DIR"

if [[ "$INCLUDE_CODEX" -eq 1 ]]; then
  TARGETS+=("$HOME/.codex/skills")
fi
if [[ "$INCLUDE_CLAUDE" -eq 1 ]]; then
  TARGETS+=("$HOME/.claude/skills")
fi
for t in "${EXTRA_TARGETS[@]}"; do
  TARGETS+=("$t")
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  die "No install targets selected"
fi

shopt -s nullglob
SKILL_DIRS=("$SOURCE_DIR"/*)
shopt -u nullglob

if [[ ${#SKILL_DIRS[@]} -eq 0 ]]; then
  die "No skill directories found in: $SOURCE_DIR"
fi

declare -a SKILL_NAMES=()
for skill_dir in "${SKILL_DIRS[@]}"; do
  [[ -d "$skill_dir" ]] || continue
  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    continue
  fi
  skill_name="$(basename "$skill_dir")"
  SKILL_NAMES+=("$skill_name")
done

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  die "No installable skills found (expected SKILL.md in each skill dir)"
fi

echo "Source: $SOURCE_DIR"
echo "Agents: $AGENTS_SKILLS_DIR"
echo "Targets:"
for t in "${TARGETS[@]}"; do
  echo "  - $t"
done
echo "Skills:"
for s in "${SKILL_NAMES[@]}"; do
  echo "  - $s"
done

mkdir -p "$AGENTS_SKILLS_DIR"

for skill_name in "${SKILL_NAMES[@]}"; do
  copy_tree "$SOURCE_DIR/$skill_name" "$AGENTS_SKILLS_DIR"
done

for target in "${TARGETS[@]}"; do
  for skill_name in "${SKILL_NAMES[@]}"; do
    install_skill_to_target "$skill_name" "$target"
  done
done

echo "Install complete."
