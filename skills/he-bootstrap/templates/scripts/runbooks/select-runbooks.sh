#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

usage() {
  cat <<'EOF'
Usage: select-runbooks.sh --skill <skill-name> [--step <workflow-step>]

Prints runbook paths (one per line) whose YAML frontmatter `called_from` includes
the requested skill (and optional workflow step).

Examples:
  bash scripts/runbooks/select-runbooks.sh --skill he-review
  bash scripts/runbooks/select-runbooks.sh --skill he-verify-release --step verify-release
EOF
}

SKILL=""
STEP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)
      SKILL="${2:-}"
      shift 2
      ;;
    --step)
      STEP="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$SKILL" ]]; then
  echo "Error: --skill is required" >&2
  usage >&2
  exit 2
fi

extract_frontmatter() {
  local file="$1"
  awk '
    NR==1 { if ($0 != "---") exit 2; in_fm=1; next }
    in_fm==1 { if ($0 == "---") exit 0; print }
  ' "$file" 2>/dev/null
}

extract_called_from_items() {
  # Input: frontmatter text on stdin. Output: one item per line.
  # Supports:
  # - called_from: [a, b]
  # - called_from:
  #     - a
  #     - b
  awk '
    BEGIN { in_list=0 }
    /^called_from:/ {
      if (index($0, "[") > 0) {
        # Inline list.
        line=$0
        sub(/^called_from:[[:space:]]*/, "", line)
        i=index(line, "[")
        if (i > 0) { line=substr(line, i+1) }
        j=index(line, "]")
        if (j > 0) { line=substr(line, 1, j-1) }
        gsub(/[[:space:]]*/, "", line)
        n=split(line, parts, ",")
        for (i=1; i<=n; i++) if (length(parts[i])>0) print parts[i]
        next
      }
    }
    /^called_from:[[:space:]]*$/ { in_list=1; next }
    in_list==1 {
      if ($0 ~ /^[A-Za-z0-9_-]+:/) { in_list=0; next }
      if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
        item=$0
        sub(/^[[:space:]]*-[[:space:]]+/, "", item)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", item)
        if (length(item)>0) print item
        next
      }
    }
  '
}

matches_called_from() {
  local file="$1"
  local fm items
  fm="$(extract_frontmatter "$file" || true)"
  items="$(printf "%s\n" "$fm" | extract_called_from_items || true)"

  if printf "%s\n" "$items" | grep -Fqx -- "$SKILL"; then
    return 0
  fi
  if [[ -n "$STEP" ]] && printf "%s\n" "$items" | grep -Fqx -- "$STEP"; then
    return 0
  fi
  return 1
}

if [[ ! -d docs/runbooks ]]; then
  exit 0
fi

while IFS= read -r file; do
  if matches_called_from "$file"; then
    printf "%s\n" "$file"
  fi
done < <(find docs/runbooks -type f -name "*.md" -print | LC_ALL=C sort)
