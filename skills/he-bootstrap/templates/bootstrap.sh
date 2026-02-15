#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WITH_ARCHITECTURE=0

copy_if_missing() {
  local target="$1"
  local template_rel="$2"

  [ -f "$target" ] || cat "$SCRIPT_DIR/$template_rel" > "$target"
}

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--with-architecture]

Options:
  --with-architecture   Create ARCHITECTURE.md from template if missing
  -h, --help            Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --with-architecture)
      WITH_ARCHITECTURE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

mkdir -p \
  docs/specs docs/spikes \
  docs/plans/active docs/plans/completed \
  docs/design-docs docs/generated \
  docs/runbooks \
  scripts/ci \
  scripts/runbooks \
  .github/workflows

copy_if_missing AGENTS.md "AGENTS.md"
[ "$WITH_ARCHITECTURE" -eq 0 ] || copy_if_missing ARCHITECTURE.md "ARCHITECTURE.md"

copy_if_missing docs/specs/index.md "docs/specs/index.md"
copy_if_missing docs/plans/tech-debt-tracker.md "docs/plans/tech-debt-tracker.md"
copy_if_missing docs/specs/README.md "docs/specs/README.md"
copy_if_missing docs/spikes/README.md "docs/spikes/README.md"
copy_if_missing docs/plans/README.md "docs/plans/README.md"
copy_if_missing docs/generated/README.md "docs/generated/README.md"
copy_if_missing docs/generated/db-schema.md "docs/generated/db-schema.md"
copy_if_missing docs/design-docs/index.md "docs/design-docs/index.md"
copy_if_missing docs/PLANS.md "docs/PLANS.md"
copy_if_missing docs/DOMAIN_DOCS.md "docs/DOMAIN_DOCS.md"
copy_if_missing docs/generated/memory.md "docs/generated/memory.md"
copy_if_missing docs/runbooks/update-agents-md.md "docs/runbooks/update-agents-md.md"
copy_if_missing docs/runbooks/update-domain-docs.md "docs/runbooks/update-domain-docs.md"
copy_if_missing docs/runbooks/verify-release.md "docs/runbooks/verify-release.md"
copy_if_missing docs/runbooks/record-evidence.md "docs/runbooks/record-evidence.md"
copy_if_missing docs/runbooks/ci-failures.md "docs/runbooks/ci-failures.md"
copy_if_missing docs/runbooks/escalation.md "docs/runbooks/escalation.md"
copy_if_missing docs/runbooks/merge-change.md "docs/runbooks/merge-change.md"
copy_if_missing docs/runbooks/code-review.md "docs/runbooks/code-review.md"
copy_if_missing docs/runbooks/review-findings.md "docs/runbooks/review-findings.md"
copy_if_missing docs/runbooks/address-review-findings.md "docs/runbooks/address-review-findings.md"

# CI gates for domain docs + artifact structure (specs/plans/spikes).
copy_if_missing scripts/ci/he-docs-config.sh "scripts/ci/he-docs-config.sh"
copy_if_missing scripts/ci/he-docs-lint.sh "scripts/ci/he-docs-lint.sh"
copy_if_missing scripts/ci/he-docs-drift.sh "scripts/ci/he-docs-drift.sh"
copy_if_missing scripts/ci/he-specs-lint.sh "scripts/ci/he-specs-lint.sh"
copy_if_missing scripts/ci/he-plans-lint.sh "scripts/ci/he-plans-lint.sh"
copy_if_missing scripts/ci/he-spikes-lint.sh "scripts/ci/he-spikes-lint.sh"
copy_if_missing scripts/ci/he-runbooks-lint.sh "scripts/ci/he-runbooks-lint.sh"
copy_if_missing scripts/runbooks/select-runbooks.sh "scripts/runbooks/select-runbooks.sh"
copy_if_missing .github/workflows/harness-docs.yml ".github/workflows/harness-docs.yml"

# Make CI scripts runnable locally via ./scripts/ci/...
chmod +x \
  scripts/ci/he-docs-config.sh \
  scripts/ci/he-docs-lint.sh \
  scripts/ci/he-docs-drift.sh \
  scripts/ci/he-specs-lint.sh \
  scripts/ci/he-plans-lint.sh \
  scripts/ci/he-spikes-lint.sh \
  scripts/ci/he-runbooks-lint.sh \
  scripts/runbooks/select-runbooks.sh \
  2>/dev/null || true
