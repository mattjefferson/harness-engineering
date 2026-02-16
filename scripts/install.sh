#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# install.sh — Sync repo skills into ~/.agents/skills and ~/.claude/skills.
# Use --project <path> to install into a project's local directories instead.
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── defaults ──────────────────────────────────────────────────────────────────
source_dir="$REPO_ROOT/skills"
project_dir=""
dry_run=false

usage() {
  cat <<EOF
Usage: install.sh [OPTIONS]

Install skills from this repo into agents and claude skill directories.

Options:
  --source <dir>     Source skills directory (default: <repo>/skills)
  --project <dir>    Install into a project's local .agents/skills and
                     .claude/skills instead of the global home directories
  --dry-run          Show what would be done without making changes

By default, skills are installed to:
  ~/.agents/skills
  ~/.claude/skills

With --project <dir>, skills are installed to:
  <dir>/.agents/skills
  <dir>/.claude/skills
EOF
  exit 0
}

# ── arg parsing ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      source_dir="$2"; shift 2 ;;
    --project)
      project_dir="$2"; shift 2 ;;
    --dry-run)
      dry_run=true; shift ;;
    --help|-h)
      usage ;;
    *)
      echo "Error: unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ── resolve paths ─────────────────────────────────────────────────────────────
source_dir="$(cd "$source_dir" 2>/dev/null && pwd)" || {
  echo "Error: Source directory not found: $source_dir" >&2
  exit 2
}

if [[ -n "$project_dir" ]]; then
  project_dir="$(cd "$project_dir" 2>/dev/null && pwd)" || {
    echo "Error: Project directory not found: $project_dir" >&2
    exit 2
  }
  agents_skills_dir="$project_dir/.agents/skills"
  claude_skills_dir="$project_dir/.claude/skills"
else
  agents_skills_dir="${AGENTS_HOME:-$HOME/.agents}/skills"
  claude_skills_dir="$HOME/.claude/skills"
fi

# ── discover skills ──────────────────────────────────────────────────────────
declare -a skill_names=()
for child in "$source_dir"/*/; do
  [[ -d "$child" ]] || continue
  [[ -f "$child/SKILL.md" ]] || continue
  skill_names+=("$(basename "$child")")
done

if [[ ${#skill_names[@]} -eq 0 ]]; then
  echo "Error: No installable skills found (expected SKILL.md in each skill dir)." >&2
  exit 2
fi

# ── print summary ────────────────────────────────────────────────────────────
echo "Source:  $source_dir"
echo "Targets:"
echo "  - $agents_skills_dir"
echo "  - $claude_skills_dir"
echo "Skills:"
for s in "${skill_names[@]}"; do
  echo "  - $s"
done

# ── helper: copy skill tree ─────────────────────────────────────────────────
copy_tree() {
  local src="$1" dst="$2"
  if $dry_run; then
    echo "[dry-run] copy '$src' -> '$dst'"
    return
  fi
  mkdir -p "$dst"
  cp -R "$src/." "$dst/"
}

# ── install ──────────────────────────────────────────────────────────────────
for target_dir in "$agents_skills_dir" "$claude_skills_dir"; do
  if $dry_run; then
    echo "[dry-run] mkdir -p '$target_dir'"
  else
    mkdir -p "$target_dir"
  fi

  for skill_name in "${skill_names[@]}"; do
    copy_tree "$source_dir/$skill_name" "$target_dir/$skill_name"
  done
done

echo "Install complete."
exit 0
