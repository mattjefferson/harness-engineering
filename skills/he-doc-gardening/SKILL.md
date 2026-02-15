---
name: he-doc-gardening
description: Recurring doc-gardening agent that scans for stale or obsolete documentation that no longer matches real code behavior, then queues fix-up work.
argument-hint: "[optional area, subsystem, or repo-wide]"
---

# HE Doc Gardening

Run this skill periodically to keep docs accurate and aligned with shipped behavior.

## Frequency

- Weekly by default
- Also after large releases or high-review-noise periods

## Scan Targets

**Launch parallel subagents to scan each target area concurrently:**

1. Repeated review findings and regressions
2. Stale or contradictory docs
3. Dead links or outdated references
4. High-churn or complexity hotspots
5. Flaky test patterns
6. Stale generated context in `docs/generated/` (check `last_updated` timestamps)

Each subagent scans one area and returns a list of drift findings with priority. The main thread consolidates and queues fix-up work.

## Outputs

1. Update `docs/plans/tech-debt-tracker.md`
2. Refresh stale generated context files in `docs/generated/`
3. Create one or more doc-fix specs and plans:
   - `docs/specs/<slug>.md`
   - `docs/plans/active/<slug>.md`

Keep each doc-fix plan small and independently shippable.

Record drift findings with explicit priority.

## Doc-Gardening Rule

- Doc-gardening work should not block feature delivery unless a critical invariant is broken.
- Critical invariant violations must be escalated and prioritized immediately.

## Exit Gate

- Drift findings are documented
- Cleanup initiatives are queued as normal slug-based specs/plans
- Docs commit gate passes

## Transition

Default next phase is `he-spec` for a cleanup initiative slug.
