---
title: "Review Findings"
use_when: "Writing or interpreting review findings in docs/plans/active/<slug>.md under the Review Findings section."
called_from:
  - he-review
---

# Review Findings

Review findings must be actionable and verifiable. The goal is to let a future reader fix issues without rediscovering context.

## Required Fields

Each finding includes:

- priority: `critical|high|medium|low`
- location: file path + symbol or short pointer
- issue summary: what is wrong
- required action: what must change or what proof is missing
- owner: who is responsible (team/name/agent)

## Priority Rubric (Default)

- `critical`: data loss/security issue, correctness bug with high blast radius, or unsafe merge risk
- `high`: user-visible bug, missing rollback/evidence for a risky change, or tests that do not prove behavior
- `medium`: maintainability/clarity issues that should be addressed soon, small correctness edge cases
- `low`: nits, stylistic consistency, small refactors that improve readability

## No-Mocks Policy

If the repo follows a "unit or e2e only" philosophy, mock-based tests are a `high` finding unless the repo explicitly documents an exception.

## Mandatory Coverage

- Missing the security/data review is a `high` finding (non-negotiable gate).

## Acceptance Rules

- Unresolved `critical` or `high` blocks progression to verify/release.
- `medium` and `low` can proceed only if explicitly accepted in writing in the plan.
