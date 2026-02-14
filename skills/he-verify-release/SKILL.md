---
name: he-verify-release
description: Performs release-readiness verification with test evidence, invariant checks, rollback readiness, and go/no-go decision recording in the active plan.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Verify/Release

Validate release readiness and record a go/no-go decision.

## Inputs

- `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- Review findings
- Test and integration evidence

## Verification Checklist

**Launch parallel subagents to verify independent checklist items concurrently:**

1. Required tests pass (subagent: run test suites and collect results).
2. Architecture and safety invariants pass (subagent: check invariants against codebase).
3. No unresolved critical/high findings (check review findings in plan).
4. Rollback steps are documented and feasible.
5. Monitoring and post-release checks are defined.

The main thread collects subagent results and records the GO/NO-GO decision.

## Plan Update

Fill in the `## Verify/Release Decision` section in `docs/plans/active/<slug>.md`.

## Decision Rules

- `NO-GO` if any blocking gate fails.
- `GO` only with complete evidence and explicit rollback path.

## Re-entry on NO-GO

When the decision is `NO-GO`:

- For minor fixes (test failures, small bugs): return to `he-implement` with the specific tasks to fix.
- For design-level issues (architecture problems, missing requirements): return to `he-plan` with a Decision Log entry.
- Always create a Progress Log entry explaining the NO-GO reason and the target re-entry phase.

## Exit Gate

- Decision recorded in active plan
- Evidence references included
- If NO-GO: re-entry target phase identified with rationale
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-learn` (for GO) or the re-entry phase (for NO-GO).
