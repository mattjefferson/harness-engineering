#!/bin/bash
set -euo pipefail

# Bootstrap a repo for the harness-engineered workflow.

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
WITH_ARCHITECTURE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-architecture) WITH_ARCHITECTURE=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
TEMPLATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="$(pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
copy_if_missing() {
  local target_rel="$1"
  local template_rel="$2"
  local target="${TARGET_ROOT}/${target_rel}"
  local src="${TEMPLATE_ROOT}/${template_rel}"

  if [[ -e "$target" ]]; then
    return
  fi

  mkdir -p "$(dirname "$target")"
  cp "$src" "$target"
}

make_executable() {
  local path="${TARGET_ROOT}/$1"
  if [[ -f "$path" ]]; then
    chmod +x "$path"
  fi
}

# ---------------------------------------------------------------------------
# Create baseline directories
# ---------------------------------------------------------------------------
for dir in \
  docs/specs \
  docs/spikes \
  docs/plans/active \
  docs/plans/completed \
  docs/design-docs \
  docs/generated \
  docs/runbooks \
  scripts/ci \
  scripts/runbooks \
  .github/workflows; do
  mkdir -p "${TARGET_ROOT}/${dir}"
done

# ---------------------------------------------------------------------------
# Root-level files
# ---------------------------------------------------------------------------
copy_if_missing "AGENTS.md" "AGENTS.md"
if [[ "$WITH_ARCHITECTURE" == true ]]; then
  copy_if_missing "ARCHITECTURE.md" "ARCHITECTURE.md"
fi

# ---------------------------------------------------------------------------
# Documentation files
# ---------------------------------------------------------------------------
copy_if_missing "docs/specs/index.md" "docs/specs/index.md"
copy_if_missing "docs/plans/tech-debt-tracker.md" "docs/plans/tech-debt-tracker.md"
copy_if_missing "docs/specs/README.md" "docs/specs/README.md"
copy_if_missing "docs/spikes/README.md" "docs/spikes/README.md"
copy_if_missing "docs/plans/README.md" "docs/plans/README.md"
copy_if_missing "docs/generated/README.md" "docs/generated/README.md"
copy_if_missing "docs/generated/db-schema.md" "docs/generated/db-schema.md"
copy_if_missing "docs/design-docs/index.md" "docs/design-docs/index.md"
copy_if_missing "docs/PLANS.md" "docs/PLANS.md"
copy_if_missing "docs/DOMAIN_DOCS.md" "docs/DOMAIN_DOCS.md"
copy_if_missing "docs/generated/memory.md" "docs/generated/memory.md"

# ---------------------------------------------------------------------------
# Runbooks
# ---------------------------------------------------------------------------
for rb in \
  update-agents-md.md \
  update-domain-docs.md \
  verify-release.md \
  record-evidence.md \
  ci-failures.md \
  merge-change.md \
  code-review.md \
  review-findings.md \
  address-review-findings.md \
  validate-current-state.md \
  reproduce-bug.md \
  pull-request.md \
  respond-to-feedback.md; do
  copy_if_missing "docs/runbooks/${rb}" "docs/runbooks/${rb}"
done

# ---------------------------------------------------------------------------
# CI gates and scripts (.sh extensions)
# ---------------------------------------------------------------------------
copy_if_missing "scripts/ci/he-docs-config.json" "scripts/ci/he-docs-config.json"
copy_if_missing "scripts/ci/he-runbooks-lint.sh" "scripts/ci/he-runbooks-lint.sh"
copy_if_missing "scripts/ci/he-docs-lint.sh" "scripts/ci/he-docs-lint.sh"
copy_if_missing "scripts/ci/he-docs-drift.sh" "scripts/ci/he-docs-drift.sh"
copy_if_missing "scripts/ci/he-specs-lint.sh" "scripts/ci/he-specs-lint.sh"
copy_if_missing "scripts/ci/he-plans-lint.sh" "scripts/ci/he-plans-lint.sh"
copy_if_missing "scripts/ci/he-spikes-lint.sh" "scripts/ci/he-spikes-lint.sh"
copy_if_missing "scripts/runbooks/select-runbooks.sh" "scripts/runbooks/select-runbooks.sh"
copy_if_missing ".github/workflows/harness-docs.yml" ".github/workflows/harness-docs.yml"

# ---------------------------------------------------------------------------
# Make scripts executable (best-effort)
# ---------------------------------------------------------------------------
make_executable "scripts/ci/he-runbooks-lint.sh"
make_executable "scripts/ci/he-docs-lint.sh"
make_executable "scripts/ci/he-docs-drift.sh"
make_executable "scripts/ci/he-specs-lint.sh"
make_executable "scripts/ci/he-plans-lint.sh"
make_executable "scripts/ci/he-spikes-lint.sh"
make_executable "scripts/runbooks/select-runbooks.sh"

exit 0
