---
name: he-verify-release
description: Performs release-readiness verification with test evidence, invariant checks, rollback readiness, and go/no-go decision recording in the active plan.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Verify/Release

Validate release readiness and record a go/no-go decision.

## Inputs

- `docs/plans/active/<slug>.md`
- Review findings
- Test and integration evidence

## Verification Checklist

1. Required tests pass.
2. Architecture and safety invariants pass.
3. No unresolved critical/high findings.
4. Rollback steps are documented and feasible.
5. Monitoring and post-release checks are defined.

## Plan Update

Add section from `templates/verify-release-decision-section.md`.

## Decision Rules

- `NO-GO` if any blocking gate fails.
- `GO` only with complete evidence and explicit rollback path.

## Exit Gate

- Decision recorded in active plan
- Evidence references included
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-learn`.
- Wait for the user's selection before proceeding to the next phase.
