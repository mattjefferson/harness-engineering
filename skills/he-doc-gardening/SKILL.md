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

1. Repeated review findings and regressions
2. Stale or contradictory docs
3. Dead links or outdated references
4. High-churn or complexity hotspots
5. Flaky test patterns

## Outputs

1. Update `docs/plans/tech-debt-tracker.md`
2. Update `docs/QUALITY_SCORE.md` trend notes
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

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-intake` for a cleanup initiative slug.
- Wait for the user's selection before proceeding to the next phase.
