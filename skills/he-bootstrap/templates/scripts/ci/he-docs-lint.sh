#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${HARNESS_DOCS_CONFIG:-scripts/ci/he-docs-config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Error: he-docs-lint missing config '$CONFIG_FILE'." >&2
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
  local title="${2:-he-docs-lint}"
  local msg="${3:-}"
  errors=$((errors + 1))
  emit_gh_annotation "error" "$file" "$title" "$msg"
  echo "Error: $msg" >&2
}

add_warning() {
  local file="${1:-}"
  local title="${2:-he-docs-lint}"
  local msg="${3:-}"
  warnings=$((warnings + 1))
  emit_gh_annotation "warning" "$file" "$title" "$msg"
  echo "Warning: $msg" >&2
}

has_line() {
  local file="$1"
  local needle="$2"
  grep -Fqx -- "$needle" "$file"
}

check_required_docs() {
  local doc
  for doc in "${HARNESS_REQUIRED_DOCS[@]}"; do
    if [[ ! -f "$doc" ]]; then
      add_error "$doc" "Required doc missing" "Missing required doc: '$doc'. Fix: create it (run he-bootstrap if this repo is not bootstrapped) or adjust HARNESS_REQUIRED_DOCS in '$CONFIG_FILE'."
    fi
  done
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
  fm="$(
    awk '
      NR==1 { if ($0 != "---") exit 2; in_fm=1; next }
      in_fm==1 { if ($0 == "---") exit 0; print }
    ' "$file" 2>/dev/null || true
  )"

  if ! printf "%s\n" "$fm" | grep -Eq '^title:[[:space:]]*'; then
    add_error "$file" "Runbook frontmatter" "Runbook '$file' frontmatter must include a 'title:' field."
  fi
  if ! printf "%s\n" "$fm" | grep -Eq '^use_when:[[:space:]]*'; then
    add_error "$file" "Runbook frontmatter" "Runbook '$file' frontmatter must include a 'use_when:' field."
  fi
}

lint_runbooks_frontmatter() {
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

check_headings_for() {
  local file="$1"
  local var_name="$2"

  # Indirect array reference by name.
  # Use eval instead of namerefs so this script runs on macOS's default bash as well as CI.
  # shellcheck disable=SC2034,SC2140
  local -a headings=()
  eval "headings=(\"\${${var_name}[@]}\")"

  if [[ "${#headings[@]}" -eq 0 ]]; then
    add_error "$file" "Missing config headings" "No required headings configured for '$file' (variable '$var_name' is empty or undefined). Fix: define it in '$CONFIG_FILE'."
    return 0
  fi

  local h
  local -a missing=()
  for h in "${headings[@]}"; do
    if ! has_line "$file" "$h"; then
      missing+=("$h")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    local missing_joined
    missing_joined="$(printf "%s; " "${missing[@]}")"
    add_error "$file" "Missing headings" "Missing required headings in '$file': ${missing_joined%'; '}. Fix: add them or adjust '$var_name' in '$CONFIG_FILE'."

    # Print current headings to speed debugging without spamming annotations.
    echo "Info: headings currently present in '$file':" >&2
    grep -E '^##[[:space:]]+' "$file" >&2 || true
  fi
}

check_domain_doc_headings() {
  # Domain docs are created on-demand — only lint headings for docs that exist.
  [[ -f "docs/DATA.md" ]] && check_headings_for "docs/DATA.md" HARNESS_REQUIRED_HEADINGS_docs_DATA_md
  [[ -f "docs/SECURITY.md" ]] && check_headings_for "docs/SECURITY.md" HARNESS_REQUIRED_HEADINGS_docs_SECURITY_md
  [[ -f "docs/RELIABILITY.md" ]] && check_headings_for "docs/RELIABILITY.md" HARNESS_REQUIRED_HEADINGS_docs_RELIABILITY_md
  [[ -f "docs/FRONTEND.md" ]] && check_headings_for "docs/FRONTEND.md" HARNESS_REQUIRED_HEADINGS_docs_FRONTEND_md
  [[ -f "docs/DESIGN.md" ]] && check_headings_for "docs/DESIGN.md" HARNESS_REQUIRED_HEADINGS_docs_DESIGN_md
  [[ -f "docs/PRODUCT_SENSE.md" ]] && check_headings_for "docs/PRODUCT_SENSE.md" HARNESS_REQUIRED_HEADINGS_docs_PRODUCT_SENSE_md
  return 0
}

check_seed_markers() {
  local doc
  for doc in "${HARNESS_DOMAIN_DOCS[@]}"; do
    if [[ -f "$doc" ]] && grep -n "<!-- seed:" "$doc" >/dev/null 2>&1; then
      local msg="Template seed markers remain in '$doc'. Fix: replace/remove <!-- seed: ... --> blocks once this repo has real domain context."
      if [[ "$HARNESS_FAIL_ON_SEED_MARKERS" == "1" ]]; then
        add_error "$doc" "Seed markers present" "$msg (Set HARNESS_FAIL_ON_SEED_MARKERS=0 to warn-only.)"
      else
        add_warning "$doc" "Seed markers present" "$msg (Set HARNESS_FAIL_ON_SEED_MARKERS=1 to enforce.)"
      fi

      # Show the exact lines to speed up fixes without creating many annotations.
      echo "Info: seed marker locations in '$doc':" >&2
      grep -n "<!-- seed:" "$doc" >&2 || true
    fi
  done
}

check_generated_last_updated() {
  local file
  if [[ ! -d docs/generated ]]; then
    return 0
  fi

  shopt -s nullglob
  for file in docs/generated/*.md; do
    if [[ "$file" == "docs/generated/README.md" ]]; then
      continue
    fi
    # Agent scratchpad is intentionally wipeable and not a durable generated artifact.
    if [[ "$file" == "docs/generated/memory.md" ]]; then
      continue
    fi
    if ! grep -Eq '^[[:space:]]*-[[:space:]]*last_updated:[[:space:]]*' "$file"; then
      add_error "$file" "Missing last_updated" "Generated doc '$file' must include a 'last_updated' line. Fix: add e.g. '- last_updated: 2026-02-15 12:34'."
    fi
    if grep -Eq 'last_updated:[[:space:]]*<YYYY-' "$file"; then
      if [[ "$HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS" == "1" ]]; then
        add_error "$file" "Placeholder last_updated" "Generated doc '$file' has a placeholder last_updated value. Fix: replace with a real timestamp. (Set HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS=0 to warn-only.)"
      else
        add_warning "$file" "Placeholder last_updated" "Generated doc '$file' has a placeholder last_updated value. Fix: replace with a real timestamp. (Set HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS=1 to enforce.)"
      fi
    fi
  done
  shopt -u nullglob
}

main() {
  echo "he-docs-lint: starting (config: $CONFIG_FILE)"
  echo "Repro: bash scripts/ci/he-docs-lint.sh"
  check_required_docs
  check_required_runbooks
  lint_runbooks_frontmatter
  check_domain_doc_headings
  check_seed_markers
  check_generated_last_updated

  if [[ "$errors" -gt 0 ]]; then
    echo "he-docs-lint: FAIL ($errors error(s), $warnings warning(s))" >&2
    exit 1
  fi
  echo "he-docs-lint: OK ($warnings warning(s))"
}

main "$@"
