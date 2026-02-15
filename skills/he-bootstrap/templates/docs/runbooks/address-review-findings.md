---
title: "Address Review Findings"
use_when: "You have review findings in an active plan and need a consistent process to fix, re-run review, and document what changed."
---

# Address Review Findings

## Workflow

1. Triage findings by priority.
2. For each `critical`/`high`, do one of:
   - fix it (preferred), or
   - escalate via `docs/runbooks/escalation.md` if behavior is ambiguous or risk is unclear.
3. For `medium`/`low`, either:
   - fix it, or
   - accept it explicitly in the plan with rationale and follow-up link.
4. Update evidence:
   - rerun the most relevant tests
   - update `Artifacts and Notes` with new proof
5. Update `Progress`, `Decision Log`, and `Revision Notes` in the plan to reflect what changed and why.
6. Re-run `he-review` if the change materially altered behavior or implementation.

## Re-entry Rule

If a review finding reveals a design-level mismatch with the plan's intent, re-enter `he-plan` (not just `he-implement`) and record the decision in the plan.

