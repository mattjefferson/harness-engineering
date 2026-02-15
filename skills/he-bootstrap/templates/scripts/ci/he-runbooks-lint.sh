#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${HARNESS_DOCS_CONFIG:-scripts/ci/he-docs-config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Error: he-runbooks-lint missing config '$CONFIG_FILE'." >&2
  echo "Fix: create it (bootstrap should do this) or set HARNESS_DOCS_CONFIG to a valid path." >&2
  exit 2
fi

errors=0
warnings=0

emit_gh_annotation() {
  local level="$1"
  local file="$2"
  local title="$3"
  local msg="$4"

  if [[ -n "$file" ]]; then
    echo "::${level} file=${file},title=${title}::${msg}"
  else
    echo "::${level} title=${title}::${msg}"
  fi
}

add_error() {
  local file="${1:-}"
  local title="${2:-he-runbooks-lint}"
  local msg="${3:-}"
  errors=$((errors + 1))
  emit_gh_annotation "error" "$file" "$title" "$msg"
  echo "Error: $msg" >&2
}

add_warning() {
  local file="${1:-}"
  local title="${2:-he-runbooks-lint}"
  local msg="${3:-}"
  warnings=$((warnings + 1))
  emit_gh_annotation "warning" "$file" "$title" "$msg"
  echo "Warning: $msg" >&2
}

check_required_runbooks() {
  if ! declare -p HARNESS_REQUIRED_RUNBOOKS >/dev/null 2>&1; then
    return 0
  fi

  local rb
  # shellcheck disable=SC2154
  for rb in "${HARNESS_REQUIRED_RUNBOOKS[@]}"; do
    if [[ ! -f "$rb" ]]; then
      add_error "$rb" "Required runbook missing" "Missing required runbook: '$rb'. Fix: create it (run he-bootstrap if this repo is not bootstrapped) or adjust HARNESS_REQUIRED_RUNBOOKS in '$CONFIG_FILE'."
    fi
  done
}

extract_frontmatter() {
  local file="$1"
  awk '
    NR==1 { if ($0 != "---") exit 2; in_fm=1; next }
    in_fm==1 { if ($0 == "---") exit 0; print }
  ' "$file" 2>/dev/null
}

lint_runbook_frontmatter() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if ! head -n 1 "$file" | grep -Fqx -- "---"; then
    add_error "$file" "Runbook frontmatter" "Runbook '$file' must start with YAML frontmatter ('---')."
    return 0
  fi

  local fm
  fm="$(extract_frontmatter "$file" || true)"

  if ! printf "%s\n" "$fm" | grep -Eq '^title:[[:space:]]*'; then
    add_error "$file" "Runbook frontmatter" "Runbook '$file' frontmatter must include a 'title:' field."
  fi
  if ! printf "%s\n" "$fm" | grep -Eq '^use_when:[[:space:]]*'; then
    add_error "$file" "Runbook frontmatter" "Runbook '$file' frontmatter must include a 'use_when:' field."
  fi

  # Runbooks currently standardize on a tiny frontmatter surface area. Allow extensions,
  # but default to warning so projects can evolve without breaking CI.
  local -a extra_keys=()
  local key
  while IFS= read -r key; do
    case "$key" in
      title|use_when) ;;
      *) extra_keys+=("$key") ;;
    esac
  done < <(printf "%s\n" "$fm" | sed -nE 's/^([A-Za-z0-9_-]+):.*$/\1/p' | sort -u)

  if [[ "${#extra_keys[@]}" -gt 0 ]]; then
    local joined
    joined="$(printf "%s, " "${extra_keys[@]}")"
    joined="${joined%, }"
    local msg="Runbook '$file' has extra frontmatter key(s): ${joined}. Prefer keeping runbooks to {title,use_when} unless you have a strong reason."
    if [[ "${HARNESS_FAIL_ON_EXTRA_RUNBOOK_FRONTMATTER:-0}" == "1" ]]; then
      add_error "$file" "Runbook frontmatter" "$msg (Set HARNESS_FAIL_ON_EXTRA_RUNBOOK_FRONTMATTER=0 to warn-only.)"
    else
      add_warning "$file" "Runbook frontmatter" "$msg (Set HARNESS_FAIL_ON_EXTRA_RUNBOOK_FRONTMATTER=1 to enforce.)"
    fi
  fi
}

lint_runbooks() {
  if [[ ! -d docs/runbooks ]]; then
    return 0
  fi

  shopt -s nullglob
  local file
  for file in docs/runbooks/*.md; do
    lint_runbook_frontmatter "$file"
  done
  shopt -u nullglob
}

main() {
  echo "he-runbooks-lint: starting (config: $CONFIG_FILE)"
  echo "Repro: bash scripts/ci/he-runbooks-lint.sh"
  check_required_runbooks
  lint_runbooks

  if [[ "$errors" -gt 0 ]]; then
    echo "he-runbooks-lint: FAIL ($errors error(s), $warnings warning(s))" >&2
    exit 1
  fi
  echo "he-runbooks-lint: OK ($warnings warning(s))"
}

main "$@"

