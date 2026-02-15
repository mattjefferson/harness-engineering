#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${HARNESS_DOCS_CONFIG:-scripts/ci/he-docs-config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Error: he-plans-lint missing config '$CONFIG_FILE'." >&2
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
  local title="${2:-he-plans-lint}"
  local msg="${3:-}"
  errors=$((errors + 1))
  emit_gh_annotation "error" "$file" "$title" "$msg"
  echo "Error: $msg" >&2
}

add_warning() {
  local file="${1:-}"
  local title="${2:-he-plans-lint}"
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

frontmatter_value() {
  local frontmatter="$1"
  local key="$2"
  printf "%s\n" "$frontmatter" | awk -F':[[:space:]]*' -v k="$key" '$1==k{print $2; exit 0}'
}

has_line() {
  local file="$1"
  local needle="$2"
  grep -Fqx -- "$needle" "$file"
}

default_required_keys=(
  "slug"
  "status"
  "phase"
  "plan_mode"
  "priority"
  "owner"
)

default_required_headings=(
  "## Purpose / Big Picture"
  "## Progress"
  "## Surprises & Discoveries"
  "## Decision Log"
  "## Outcomes & Retrospective"
  "## Context and Orientation"
  "## Milestones"
  "## Plan of Work"
  "## Concrete Steps"
  "## Validation and Acceptance"
  "## Idempotence and Recovery"
  "## Artifacts and Notes"
  "## Interfaces and Dependencies"
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
      local msg="Plan '$file' contains placeholder token '$p'."
      if [[ "$fail_on" == "1" ]]; then
        add_error "$file" "Placeholder token" "$msg"
      else
        add_warning "$file" "Placeholder token" "$msg (Set HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS=1 to enforce.)"
      fi
      return 0
    fi
  done
}

check_progress_section() {
  local file="$1"

  local progress_lines
  progress_lines="$(awk '
    BEGIN { in_progress=0 }
    /^## Progress$/ { in_progress=1; next }
    /^## / { if (in_progress) exit; in_progress=0 }
    { if (in_progress) print }
  ' "$file")"

  if [[ -z "$progress_lines" ]]; then
    add_error "$file" "Missing Progress content" "Plan '$file' has an empty ## Progress section."
    return 0
  fi

  if ! printf "%s\n" "$progress_lines" | grep -Eq '^- \[[ xX]\] \([0-9]{4}-[0-9]{2}-[0-9]{2}[^)]*\) P[0-9]+'; then
    add_error "$file" "Progress format" "Plan '$file' must include timestamped progress checkboxes with IDs (e.g. '- [ ] (2026-02-15T12:00:00Z) P1 ...')."
  fi
}

check_checklists_only_in_progress() {
  local file="$1"

  if awk '
    BEGIN { in_progress=0; bad=0 }
    /^## Progress$/ { in_progress=1; next }
    /^## / { in_progress=0 }
    /^- \[[ xX]\]/ {
      if (!in_progress) {
        bad=1
      }
    }
    END { exit bad }
  ' "$file"; then
    return 0
  fi

  add_error "$file" "Checklist scope" "Plan '$file' contains checklist items outside ## Progress."
}

check_decision_log_shape() {
  local file="$1"

  local decision_lines
  decision_lines="$(awk '
    BEGIN { in_decisions=0 }
    /^## Decision Log$/ { in_decisions=1; next }
    /^## / { if (in_decisions) exit; in_decisions=0 }
    { if (in_decisions) print }
  ' "$file")"

  if [[ -z "$decision_lines" ]]; then
    add_error "$file" "Missing Decision Log content" "Plan '$file' has an empty ## Decision Log section."
    return 0
  fi

  if ! printf "%s\n" "$decision_lines" | grep -Eq '^- Decision:'; then
    add_error "$file" "Decision format" "Plan '$file' should record decisions using '- Decision:' entries."
  fi
}

check_revision_notes_shape() {
  local file="$1"

  local revision_lines
  revision_lines="$(awk '
    BEGIN { in_notes=0 }
    /^## Revision Notes$/ { in_notes=1; next }
    /^## / { if (in_notes) exit; in_notes=0 }
    { if (in_notes) print }
  ' "$file")"

  if [[ -z "$revision_lines" ]]; then
    add_error "$file" "Missing Revision Notes content" "Plan '$file' has an empty ## Revision Notes section."
    return 0
  fi

  if ! printf "%s\n" "$revision_lines" | grep -Eq '^- '; then
    add_error "$file" "Revision Notes format" "Plan '$file' should include at least one bullet in ## Revision Notes."
  fi
}

check_plan_file() {
  local file="$1"

  local frontmatter
  if ! frontmatter="$(extract_frontmatter "$file" 2>/dev/null)"; then
    add_error "$file" "Missing YAML frontmatter" "Plan '$file' must start with YAML frontmatter delimited by '---' lines."
    return 0
  fi

  local -a required_keys=()
  if declare -p HARNESS_REQUIRED_PLAN_FRONTMATTER_KEYS >/dev/null 2>&1 && [[ "${#HARNESS_REQUIRED_PLAN_FRONTMATTER_KEYS[@]}" -gt 0 ]]; then
    required_keys=("${HARNESS_REQUIRED_PLAN_FRONTMATTER_KEYS[@]}")
  else
    required_keys=("${default_required_keys[@]}")
  fi

  local k
  for k in "${required_keys[@]}"; do
    if ! frontmatter_has_key "$frontmatter" "$k"; then
      add_error "$file" "Missing frontmatter key" "Plan '$file' missing YAML frontmatter key '${k}:'."
    fi
  done

  local plan_mode
  plan_mode="$(frontmatter_value "$frontmatter" "plan_mode")"
  if [[ -n "$plan_mode" && "$plan_mode" != "lightweight" && "$plan_mode" != "execution" ]]; then
    add_error "$file" "Invalid plan_mode" "Plan '$file' has invalid plan_mode '$plan_mode' (must be 'lightweight' or 'execution')."
  fi

  local -a required_headings=()
  if declare -p HARNESS_REQUIRED_PLAN_HEADINGS >/dev/null 2>&1 && [[ "${#HARNESS_REQUIRED_PLAN_HEADINGS[@]}" -gt 0 ]]; then
    required_headings=("${HARNESS_REQUIRED_PLAN_HEADINGS[@]}")
  else
    required_headings=("${default_required_headings[@]}")
  fi

  local h
  for h in "${required_headings[@]}"; do
    if ! has_line "$file" "$h"; then
      add_error "$file" "Missing heading" "Plan '$file' missing required heading line '$h'."
    fi
  done

  check_progress_section "$file"
  check_checklists_only_in_progress "$file"
  check_decision_log_shape "$file"
  check_revision_notes_shape "$file"
  check_placeholders "$file"
}

main() {
  echo "he-plans-lint: starting (config: $CONFIG_FILE)"
  echo "Repro: bash scripts/ci/he-plans-lint.sh"

  if [[ ! -d docs/plans ]]; then
    echo "he-plans-lint: OK (docs/plans not present)"
    exit 0
  fi

  shopt -s nullglob
  local found=0
  local file

  if [[ -d docs/plans/active ]]; then
    for file in docs/plans/active/*.md; do
      found=1
      check_plan_file "$file"
    done
  fi

  local lint_completed="${HARNESS_LINT_COMPLETED_PLANS:-1}"
  if [[ "$lint_completed" == "1" && -d docs/plans/completed ]]; then
    for file in docs/plans/completed/*.md; do
      found=1
      check_plan_file "$file"
    done
  fi

  shopt -u nullglob

  if [[ "$found" -eq 0 ]]; then
    echo "he-plans-lint: OK (no plan files)"
    exit 0
  fi

  if [[ "$errors" -gt 0 ]]; then
    echo "he-plans-lint: FAIL ($errors error(s), $warnings warning(s))" >&2
    exit 1
  fi
  echo "he-plans-lint: OK ($warnings warning(s))"
}

main "$@"
