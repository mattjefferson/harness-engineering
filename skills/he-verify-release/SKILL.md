---
name: he-verify-release
description: Performs release-readiness verification with test evidence, invariant checks, rollback readiness, and go/no-go decision recording in the active plan.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Verify/Release

Validate release readiness and record a GO/NO-GO decision.

## Inputs

- `docs/plans/active/<slug>.md`
- Review findings
- Test and integration evidence

## Verification Checklist

Launch parallel subagents for independent verification items:

1. Required tests pass.
2. Architecture and safety invariants hold.
3. No unresolved critical/high findings.
4. Rollback steps are documented and feasible.
5. Monitoring and post-release checks are defined.

If the change includes browser UI behavior, collect agentic E2E evidence via `agent-browser` and store it in `Artifacts and Notes`.

## Plan Update

Fill in `## Verify/Release Decision` in `docs/plans/active/<slug>.md`.

## Decision Rules

- `NO-GO` if any blocking gate fails.
- `GO` only with complete evidence and explicit rollback path.

## Re-entry on NO-GO

When decision is `NO-GO`:

- For minor fixes: return to `he-implement`.
- For design-level issues: return to `he-plan` and append `Decision Log` context.
- Update `Progress` items and append a `Revision Notes` entry describing re-entry reason.

## Exit Gate

- Decision recorded in active plan
- Evidence references included
- If NO-GO: re-entry target phase identified with rationale
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-learn` for GO (or the identified re-entry phase for NO-GO) (recommended)
2. Run one more build-feedback round in `he-verify-release`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, follow the recommended path automatically and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
