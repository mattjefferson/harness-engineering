---
title: "Escalation"
use_when: "A verify/release gate requires human judgment due to ambiguity, risk, or missing information; you need a crisp escalation packet."
called_from:
  - he-review
  - he-verify-release
---

# Escalation

Escalate early when the risk is unclear or when correctness cannot be demonstrated with evidence.

## Escalate When

- User/data risk is non-obvious or potentially high impact
- Rollback is unclear or not feasible
- Evidence is incomplete but a decision is being requested
- CI failures appear flaky or environment-dependent
- There are competing interpretations of expected behavior

## Escalation Packet (Minimum)

Provide:

- Current decision request: what you want approved (`GO` vs `NO-GO`, or which re-entry phase)
- Evidence: commands run + short outputs + screenshots/recordings if applicable
- Risk assessment: what could break, who is affected, severity
- Rollback plan: what to revert and how to verify recovery
- Open questions: the smallest set of choices needed to proceed

## Default Safe Action

If in doubt: record `NO-GO`, identify re-entry target (`he-implement` or `he-plan`), and list the missing evidence.
