---
title: "Code Review"
use_when: "Running he-review to perform structured review fanout, write Review Findings into the active plan, and decide whether the work can proceed to verify/release."
called_from:
  - he-review
---

# Code Review

This runbook is the repo-specific playbook for reviews. The skill `he-review` enforces stable gates (fanout, findings format, and priority blocking). This document carries the details that change per project.

Runbooks must not waive non-negotiable gates enforced by the skill (for example: security/data review and the critical/high priority block).

## Inputs

- Active plan: `docs/plans/active/<slug>.md` (must contain `## Review Findings`)
- Current branch diff and test evidence (local or CI)

## Output (Write Into The Plan)

Populate `## Review Findings` with:

- a prioritized list of findings (see `docs/runbooks/review-findings.md`)
- accepted medium/low items (explicitly called out)
- any required re-entry decision (`he-implement` vs `he-plan`)

## What Review Must Cover (Customize Per Repo)

Keep this list short and concrete:

- correctness and edge cases in the changed area
- tests: coverage of new behavior and regression prevention
- user-visible behavior (if applicable) with evidence
- security/data boundaries (if applicable)
- performance or reliability impact (if applicable)

## Escalation

If review requires judgment (risk unclear, expected behavior ambiguous, flaky failures), stop and escalate using `docs/runbooks/escalation.md`.
