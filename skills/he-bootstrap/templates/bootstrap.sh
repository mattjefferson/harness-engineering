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
  scripts/ci \
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
copy_if_missing docs/design-docs/core-beliefs.md "docs/design-docs/core-beliefs.md"
copy_if_missing docs/DESIGN.md "docs/DESIGN.md"
copy_if_missing docs/FRONTEND.md "docs/FRONTEND.md"
copy_if_missing docs/PLANS.md "docs/PLANS.md"
copy_if_missing docs/PRODUCT_SENSE.md "docs/PRODUCT_SENSE.md"
copy_if_missing docs/RELIABILITY.md "docs/RELIABILITY.md"
copy_if_missing docs/SECURITY.md "docs/SECURITY.md"

# CI gates for domain docs + artifact structure (specs/plans/spikes).
copy_if_missing scripts/ci/he-docs-config.sh "scripts/ci/he-docs-config.sh"
copy_if_missing scripts/ci/he-docs-lint.sh "scripts/ci/he-docs-lint.sh"
copy_if_missing scripts/ci/he-docs-drift.sh "scripts/ci/he-docs-drift.sh"
copy_if_missing scripts/ci/he-specs-lint.sh "scripts/ci/he-specs-lint.sh"
copy_if_missing scripts/ci/he-plans-lint.sh "scripts/ci/he-plans-lint.sh"
copy_if_missing scripts/ci/he-spikes-lint.sh "scripts/ci/he-spikes-lint.sh"
copy_if_missing .github/workflows/harness-docs.yml ".github/workflows/harness-docs.yml"

# Make CI scripts runnable locally via ./scripts/ci/...
chmod +x \
  scripts/ci/he-docs-config.sh \
  scripts/ci/he-docs-lint.sh \
  scripts/ci/he-docs-drift.sh \
  scripts/ci/he-specs-lint.sh \
  scripts/ci/he-plans-lint.sh \
  scripts/ci/he-spikes-lint.sh \
  2>/dev/null || true
