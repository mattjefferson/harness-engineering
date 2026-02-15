#!/usr/bin/env bash
set -euo pipefail

# Repo-specific knobs for he-docs CI. Override by editing this file in the target repo.

# Required docs outside plans/specs.
HARNESS_REQUIRED_DOCS=(
  "AGENTS.md"
  "docs/PLANS.md"
  "docs/DESIGN.md"
  "docs/FRONTEND.md"
  "docs/PRODUCT_SENSE.md"
  "docs/QUALITY_SCORE.md"
  "docs/RELIABILITY.md"
  "docs/SECURITY.md"
  "docs/references/README.md"
)

# Required headings per doc (exact heading lines, including the leading ##).
HARNESS_REQUIRED_HEADINGS_docs_SECURITY_md=(
  "## Threat Model"
  "## Auth Model"
  "## Data Sensitivity"
  "## Compliance"
  "## Controls"
)

HARNESS_REQUIRED_HEADINGS_docs_RELIABILITY_md=(
  "## Reliability Goals"
  "## Failure Modes"
  "## Monitoring"
  "## Operational Guardrails"
)

HARNESS_REQUIRED_HEADINGS_docs_QUALITY_SCORE_md=(
  "## Current State"
  "## Quality Bar"
  "## Test Strategy"
  "## Guardrails"
)

HARNESS_REQUIRED_HEADINGS_docs_FRONTEND_md=(
  "## Stack"
  "## Conventions"
  "## Component Architecture"
  "## Performance"
  "## Accessibility"
)

HARNESS_REQUIRED_HEADINGS_docs_DESIGN_md=(
  "## Design Principles"
  "## Visual Direction"
  "## Interaction Standards"
)

HARNESS_REQUIRED_HEADINGS_docs_PRODUCT_SENSE_md=(
  "## Target Users"
  "## Key Outcomes"
  "## Decision Heuristics"
  "## Quality Criteria"
)

# If 1, fail PRs when template markers remain in domain docs.
HARNESS_FAIL_ON_SEED_MARKERS="${HARNESS_FAIL_ON_SEED_MARKERS:-0}"

# If 1, fail PRs when generated docs have placeholder last_updated values.
HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS="${HARNESS_FAIL_ON_GENERATED_PLACEHOLDERS:-0}"

# If 1, fail when specs/plans/spikes contain placeholder tokens.
HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS="${HARNESS_FAIL_ON_ARTIFACT_PLACEHOLDERS:-0}"

# Placeholder tokens to detect in specs/plans/spikes.
HARNESS_ARTIFACT_PLACEHOLDER_PATTERNS=(
  "<slug>"
  "<YYYY-"
  "<title>"
)

# If 1, lint completed plans as well as active.
HARNESS_LINT_COMPLETED_PLANS="${HARNESS_LINT_COMPLETED_PLANS:-1}"

# Required YAML frontmatter keys (override per repo if desired).
HARNESS_REQUIRED_SPEC_FRONTMATTER_KEYS=(
  "slug"
  "status"
  "date"
  "owner"
  "plan_mode"
  "spike_recommended"
  "priority"
)

HARNESS_REQUIRED_PLAN_FRONTMATTER_KEYS=(
  "slug"
  "status"
  "phase"
  "plan_mode"
  "priority"
  "owner"
)

HARNESS_REQUIRED_SPIKE_FRONTMATTER_KEYS=(
  "slug"
  "status"
  "date"
  "owner"
  "timebox"
)

# Drift rules: if any changed file matches the regex, require touching the doc path.
# Format: "<regex>::<doc_path>"
HARNESS_DRIFT_RULES=(
  # CI changes should update quality docs.
  "^\\.github/workflows/|^scripts/ci/::docs/QUALITY_SCORE.md"

  # Security-sensitive areas should update security docs.
  "(^auth/|/auth/|^middleware/|/middleware/|(^|/)security/|(^|/)permissions/)::docs/SECURITY.md"

  # Infra/ops changes should update reliability docs.
  "(^infra/|^ops/|^deploy/|^terraform/|^k8s/|^helm/|(^|/)monitoring/|(^|/)alerts/)::docs/RELIABILITY.md"

  # Frontend config changes should update frontend docs.
  "(^package\\.json$|^pnpm-lock\\.yaml$|^yarn\\.lock$|^bun\\.lockb$|^tsconfig\\.json$|^vite\\.config\\.|^next\\.config\\.)::docs/FRONTEND.md"
)
