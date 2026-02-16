#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# install.sh — Sync repo skills into ~/.agents/skills, then install them into
# extra tool dirs.  Legacy ~/.codex/skills is removed safely when present.
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── defaults ──────────────────────────────────────────────────────────────────
source_dir="$REPO_ROOT/skills"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
declare -a extra_targets=()
no_claude=false
dry_run=false

# ── arg parsing ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      source_dir="$2"; shift 2 ;;
    --agents-home)
      agents_home="$2"; shift 2 ;;
    --target)
      extra_targets+=("$2"); shift 2 ;;
    --no-claude)
      no_claude=true; shift ;;
    --dry-run)
      dry_run=true; shift ;;
    *)
      echo "Error: unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ── resolve paths ─────────────────────────────────────────────────────────────
# Expand ~ but leave it to the shell (already handled by not quoting ~).
source_dir="$(cd "$source_dir" 2>/dev/null && pwd)" || {
  echo "Error: Source directory not found: $source_dir" >&2
  exit 2
}

agents_skills_dir="$agents_home/skills"
legacy_codex_skills_dir="$HOME/.codex/skills"

# ── legacy codex cleanup ─────────────────────────────────────────────────────
if [[ -d "$legacy_codex_skills_dir" ]]; then
  if $dry_run; then
    echo "[dry-run] remove legacy Codex skills dir '$legacy_codex_skills_dir'"
  elif command -v trash &>/dev/null; then
    echo "Removing legacy Codex skills dir with trash: $legacy_codex_skills_dir"
    trash "$legacy_codex_skills_dir"
  elif [[ -d "$HOME/.Trash" ]]; then
    timestamp="$(date -u +%Y%m%d-%H%M%S)"
    dest="$HOME/.Trash/codex-skills-$timestamp"
    echo "Moving legacy Codex skills dir to: $dest"
    mv "$legacy_codex_skills_dir" "$dest"
  else
    timestamp="$(date -u +%Y%m%d-%H%M%S)"
    mkdir -p "$HOME/.trash"
    dest="$HOME/.trash/codex-skills-$timestamp"
    echo "Moving legacy Codex skills dir to: $dest"
    mv "$legacy_codex_skills_dir" "$dest"
  fi
fi

# ── build targets list ────────────────────────────────────────────────────────
declare -a targets=()
if ! $no_claude; then
  targets+=("$HOME/.claude/skills")
fi
for t in "${extra_targets[@]+"${extra_targets[@]}"}"; do
  targets+=("$t")
done

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
echo "Source: $source_dir"
echo "Agents: $agents_skills_dir"
echo "Targets:"
if [[ ${#targets[@]} -eq 0 ]]; then
  echo "  - (none)"
else
  for t in "${targets[@]}"; do
    echo "  - $t"
  done
fi
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

# ── install into agents_home ─────────────────────────────────────────────────
if $dry_run; then
  echo "[dry-run] mkdir -p '$agents_skills_dir'"
else
  mkdir -p "$agents_skills_dir"
fi

for skill_name in "${skill_names[@]}"; do
  copy_tree "$source_dir/$skill_name" "$agents_skills_dir/$skill_name"
done

# ── install into extra targets ───────────────────────────────────────────────
for target in "${targets[@]+"${targets[@]}"}"; do
  for skill_name in "${skill_names[@]}"; do
    copy_tree "$agents_skills_dir/$skill_name" "$target/$skill_name"
  done
done

echo "Install complete."
exit 0
