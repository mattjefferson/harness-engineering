#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${HARNESS_DOCS_CONFIG:-scripts/ci/he-docs-config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Error: he-spikes-lint missing config '$CONFIG_FILE'." >&2
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
  local title="${2:-he-spikes-lint}"
  local msg="${3:-}"
  errors=$((errors + 1))
  emit_gh_annotation "error" "$file" "$title" "$msg"
  echo "Error: $msg" >&2
}

add_warning() {
  local file="${1:-}"
  local title="${2:-he-spikes-lint}"
  local msg="${3:-}"
  warnings=$((warnings + 1))
  emit_gh_annotation "warning" "$file" "$title" "$msg"
  echo "Warning: $msg" >&2
}

extract_frontmatter() {
  local file="$1"
  awk '
    NR==1 { if($0!="---"){exit 1}; next }
    NR>1 {
      if($0=="---"){found=1; exit 0}
      print
    }
    END { if(!found){exit 1} }
  ' "$file"
}

frontmatter_has_key() {
  local frontmatter="$1"
  local key="$2"
  printf "%s\n" "$frontmatter" | grep -Eq "^${key}:[[:space:]]*"
}

has_line() {
  local file="$1"
  local needle="$2"
  grep -Fqx -- "$needle" "$file"
}

default_required_keys=(
  "slug"
  "status"
  "date"
  "owner"
  "timebox"
)

default_required_headings=(
  "## Context"
  "## Validation Goal"
  "## Approach"
  "## Findings"
  "## Decisions"
  "## Recommendation"
  "## Impact on Upstream Docs"
  "## Spike Code"
  "## Remaining Unknowns"
  "## Time Spent"
  "## Revision Notes"
)

check_placeholders() {
  local file="$1"

  local fail_on="${HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS:-0}"
  local -a patterns=()
  if declare -p HARNESS_ARTIFACT_PLACEHOLDER_PATTERNS >/dev/null 2>&1; then
    patterns=("${HARNESS_ARTIFACT_PLACEHOLDER_PATTERNS[@]}")
  else
    patterns=("<slug>" "<YYYY-" "<title>")
  fi

  local p
  for p in "${patterns[@]}"; do
    if grep -Fq -- "$p" "$file"; then
      local msg="Spike '$file' contains placeholder token '$p'."
      if [[ "$fail_on" == "1" ]]; then
        add_error "$file" "Placeholder token" "$msg"
      else
        add_warning "$file" "Placeholder token" "$msg (Set HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS=1 to enforce.)"
      fi
      return 0
    fi
  done
}

check_spike_file() {
  local file="$1"

  local frontmatter
  if ! frontmatter="$(extract_frontmatter "$file" 2>/dev/null)"; then
    add_error "$file" "Missing YAML frontmatter" "Spike '$file' must start with YAML frontmatter delimited by '---' lines."
    return 0
  fi

  local -a required_keys=()
  if declare -p HARNESS_REQUIRED_SPIKE_FRONTMATTER_KEYS >/dev/null 2>&1 && [[ "${#HARNESS_REQUIRED_SPIKE_FRONTMATTER_KEYS[@]}" -gt 0 ]]; then
    required_keys=("${HARNESS_REQUIRED_SPIKE_FRONTMATTER_KEYS[@]}")
  else
    required_keys=("${default_required_keys[@]}")
  fi

  local k
  for k in "${required_keys[@]}"; do
    if ! frontmatter_has_key "$frontmatter" "$k"; then
      add_error "$file" "Missing frontmatter key" "Spike '$file' missing YAML frontmatter key '${k}:'."
    fi
  done

  local -a required_headings=()
  if declare -p HARNESS_REQUIRED_SPIKE_HEADINGS >/dev/null 2>&1 && [[ "${#HARNESS_REQUIRED_SPIKE_HEADINGS[@]}" -gt 0 ]]; then
    required_headings=("${HARNESS_REQUIRED_SPIKE_HEADINGS[@]}")
  else
    required_headings=("${default_required_headings[@]}")
  fi

  local h
  for h in "${required_headings[@]}"; do
    if ! has_line "$file" "$h"; then
      add_error "$file" "Missing heading" "Spike '$file' missing required heading line '$h'."
    fi
  done

  check_placeholders "$file"
}

main() {
  echo "he-spikes-lint: starting (config: $CONFIG_FILE)"
  echo "Repro: bash scripts/ci/he-spikes-lint.sh"

  if [[ ! -d docs/spikes ]]; then
    echo "he-spikes-lint: OK (docs/spikes not present)"
    exit 0
  fi

  shopt -s nullglob
  local found=0
  local file
  for file in docs/spikes/*-spike.md; do
    found=1
    check_spike_file "$file"
  done
  shopt -u nullglob

  if [[ "$found" -eq 0 ]]; then
    echo "he-spikes-lint: OK (no spike files)"
    exit 0
  fi

  if [[ "$errors" -gt 0 ]]; then
    echo "he-spikes-lint: FAIL ($errors error(s), $warnings warning(s))" >&2
    exit 1
  fi
  echo "he-spikes-lint: OK ($warnings warning(s))"
}

main "$@"
