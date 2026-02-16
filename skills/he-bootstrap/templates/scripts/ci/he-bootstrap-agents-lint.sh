#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BOOTSTRAP_SCRIPT="${TEMPLATE_ROOT}/bootstrap.sh"

MARKER_START="<!-- he-bootstrap:start -->"
MARKER_END="<!-- he-bootstrap:end -->"

fail() {
  echo "he-bootstrap-agents-lint: $1" >&2
  exit 1
}

count_occurrences() {
  local needle="$1"
  local file="$2"
  grep -Foc "$needle" "$file" || true
}

cleanup_dir() {
  local path="$1"
  if command -v trash >/dev/null 2>&1; then
    trash "$path" >/dev/null 2>&1 || true
  else
    if [[ -d "${HOME}/.Trash" ]]; then
      mv "$path" "${HOME}/.Trash/he-bootstrap-agents-lint-$$" >/dev/null 2>&1 || true
    fi
  fi
}

[[ -x "$BOOTSTRAP_SCRIPT" || -f "$BOOTSTRAP_SCRIPT" ]] || fail "bootstrap script not found at ${BOOTSTRAP_SCRIPT}"

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/he-bootstrap-agents-lint.XXXXXX")"
trap 'cleanup_dir "$WORK_DIR"' EXIT

MISSING_REPO="${WORK_DIR}/missing-agents"
mkdir -p "$MISSING_REPO"
(
  cd "$MISSING_REPO"
  bash "$BOOTSTRAP_SCRIPT"
)

[[ -f "${MISSING_REPO}/AGENTS.md" ]] || fail "expected AGENTS.md to be created when missing"
grep -Fq "## Golden Principles" "${MISSING_REPO}/AGENTS.md" || fail "expected Golden Principles section in generated AGENTS.md"

EXISTING_REPO="${WORK_DIR}/existing-agents"
mkdir -p "$EXISTING_REPO"
printf '# Existing AGENTS\nCustom flow line without trailing newline' > "${EXISTING_REPO}/AGENTS.md"
(
  cd "$EXISTING_REPO"
  bash "$BOOTSTRAP_SCRIPT"
)

grep -Fq "Custom flow line without trailing newline" "${EXISTING_REPO}/AGENTS.md" || fail "existing AGENTS.md content should be preserved"
[[ "$(count_occurrences "$MARKER_START" "${EXISTING_REPO}/AGENTS.md")" -eq 1 ]] || fail "expected one managed start marker after first bootstrap run"
[[ "$(count_occurrences "$MARKER_END" "${EXISTING_REPO}/AGENTS.md")" -eq 1 ]] || fail "expected one managed end marker after first bootstrap run"

(
  cd "$EXISTING_REPO"
  bash "$BOOTSTRAP_SCRIPT"
)

[[ "$(count_occurrences "$MARKER_START" "${EXISTING_REPO}/AGENTS.md")" -eq 1 ]] || fail "managed start marker should not duplicate across reruns"
[[ "$(count_occurrences "$MARKER_END" "${EXISTING_REPO}/AGENTS.md")" -eq 1 ]] || fail "managed end marker should not duplicate across reruns"

echo "he-bootstrap-agents-lint: PASS"
