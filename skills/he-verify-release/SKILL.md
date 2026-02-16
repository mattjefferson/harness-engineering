---
name: he-verify-release
description: Performs release-readiness verification with test evidence, invariant checks, rollback readiness, and go/no-go decision recording in the active plan.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Verify/Release

Validate release readiness and record a GO/NO-GO decision.

## Key Principles

1. Written GO/NO-GO: decision is recorded in the plan with evidence, rollback, and post-release checks.
2. Review must have passed: includes security/data review and no unresolved `critical`/`high` findings.
3. Rollback is required: explicit and feasible, not hand-wavy.
4. Evidence for user-visible changes: capture agentic E2E artifacts when UI/behavior changes.
5. Escalate when uncertain: flaky failures, missing evidence, or unclear user/data risk.
6. Runbooks are additive only: apply any runbook whose frontmatter `called_from` matches this skill (see `bash scripts/runbooks/select-runbooks.sh --skill <skill>`), but never waive/override anything codified here.

## Runbooks

These runbooks hold the repo-specific procedures that evolve over time:

- `docs/runbooks/verify-release.md`
- `docs/runbooks/record-evidence.md`
- `docs/runbooks/ci-failures.md`
- `docs/runbooks/merge-change.md`

Runbooks are additive only. If a runbook is missing or low-quality, do not block forward progress — proceed using the skill-enforced gates and record the runbook drift for `he-learn`.

In addition to the baseline list above, apply any additional runbooks returned by:

`bash scripts/runbooks/select-runbooks.sh --skill he-verify-release`

## Inputs

- `docs/plans/active/<slug>.md`
- Review findings
- Test and integration evidence

## Stable Gates (Skill-Enforced)

Launch parallel subagents for independent gate items:

1. Required tests pass.
2. Architecture and safety invariants hold.
3. Review gate passed (including security/data review) and there are no unresolved critical/high findings.
4. Rollback steps are documented and feasible.
5. Monitoring and post-release checks are defined.

If the change includes browser UI behavior, collect agentic E2E evidence via `agent-browser` and store it in `Artifacts and Notes`.

The exact commands, scenarios, and evidence conventions come from `docs/runbooks/verify-release.md` and `docs/runbooks/record-evidence.md`.

## Plan Update

Fill in `## Verify/Release Decision` in `docs/plans/active/<slug>.md`.

## Decision Rules

- `NO-GO` if any blocking gate fails.
- `GO` only with complete evidence and explicit rollback path.
- **Default safe action**: when uncertain, the decision is `NO-GO`. Record the re-entry target (`he-implement` or `he-plan`) and list the missing evidence. Do not default to `GO` with caveats.

## Escalation

Escalate early when the risk is unclear or when correctness cannot be demonstrated with evidence. Stop and escalate when:

- Failures are flaky/non-deterministic
- Rollback is missing or unclear
- Evidence is incomplete but a decision is being requested
- Risk to users/data is unclear

### Escalation Packet

Provide at minimum:

- Current decision request: what you want approved (`GO` vs `NO-GO`, or which re-entry phase)
- Evidence: commands run + short outputs + screenshots/recordings if applicable
- Risk assessment: what could break, who is affected, severity
- Rollback plan: what to revert and how to verify recovery
- Open questions: the smallest set of choices needed to proceed

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

If `GO`, proceed to merge using `docs/runbooks/merge-change.md`.

If running autonomously or no interactive tool is available, follow the recommended path automatically and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
