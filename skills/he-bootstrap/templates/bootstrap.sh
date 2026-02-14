#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WITH_ARCHITECTURE=0

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

mkdir -p docs/specs docs/plans/active docs/plans/completed docs/generated/runs docs/references

[ -f AGENTS.md ] || cat "$SCRIPT_DIR/AGENTS.md" > AGENTS.md
[ "$WITH_ARCHITECTURE" -eq 0 ] || [ -f ARCHITECTURE.md ] || cat "$SCRIPT_DIR/ARCHITECTURE.md" > ARCHITECTURE.md

[ -f docs/plans/tech-debt-tracker.md ] || cat > docs/plans/tech-debt-tracker.md <<'EOF'
# Tech Debt Tracker

| date | slug | issue pattern | impact | prevention action | priority | owner | status |
|---|---|---|---|---|---|---|---|
EOF

[ -f docs/specs/README.md ] || cat > docs/specs/README.md <<'EOF'
# Specs

Store initiative specs here using one file per slug.
EOF

[ -f docs/plans/README.md ] || cat > docs/plans/README.md <<'EOF'
# Plans

Active plans: docs/plans/active/<slug>.md
Completed plans: docs/plans/completed/<slug>.md
EOF

[ -f docs/generated/README.md ] || cat > docs/generated/README.md <<'EOF'
# Generated State

Machine-written runtime state:
- docs/generated/runs/<slug>/run.json
- docs/generated/runs/<slug>/tasks/<task-id>.json
- docs/generated/runs/<slug>/events.ndjson
EOF

[ -f docs/references/README.md ] || cat > docs/references/README.md <<'EOF'
# References

Place concise, agent-friendly framework/tool references here.
EOF
