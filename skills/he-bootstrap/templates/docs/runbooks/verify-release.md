---
title: "Verify/Release"
use_when: "Running he-verify-release to decide GO/NO-GO with evidence, rollback readiness, and post-release checks recorded in the active plan."
---

# Verify/Release

This runbook is the evolving, repo-specific checklist for the verify/release gate. The skill `he-verify-release` enforces the stable invariants; this document carries the details that change per project.

## Inputs

- Active plan: `docs/plans/active/<slug>.md` (must contain `## Verify/Release Decision`)
- Review findings section in the plan (populated by `he-review`)

## Required Outputs (Write Into The Plan)

Fill in `## Verify/Release Decision` with:

- decision: `GO` or `NO-GO`
- date:
- open findings by priority (if any):
- evidence: links/paths to test output and E2E artifacts
- rollback: exact steps or pointers
- post-release checks: exact checks/queries/URLs
- owner:

## Verification Ladder (Customize Per Repo)

Define the repo's minimum ladder here. Keep it short and ordered.

1. Fast checks: format/lint/typecheck (if applicable)
2. Targeted tests for changed area
3. Full relevant suite (unit/e2e)
4. Manual/E2E scenario (required for user-visible changes)

Document the exact commands for this repo:

    # From repo root:
    <command>

## Evidence Requirements

- Prefer evidence that a reviewer can reproduce (commands + short transcripts).
- For UI changes, include screenshots or a short recording (see `docs/runbooks/record-evidence.md`).
- For regressions, include a "before vs after" behavior description in plain language.

## Rollback And Recovery

Record the rollback plan for this repo:

- What to revert (commit/flag/config)
- How to detect failure
- How to restore service/data (if relevant)

## Post-Release Checks

Record the minimum set of checks to run after merge/release:

- health checks / smoke path
- key metrics / dashboards (if any)
- error logs / alerts (if any)

## Escalation Triggers

If any of these apply, stop and escalate (see `docs/runbooks/escalation.md`):

- Unclear risk to users/data
- Flaky or non-deterministic failures
- Rollback steps are missing or untested
- Evidence is incomplete but time pressure exists

