---
name: he-verify-release
description: Performs release-readiness verification with test evidence, invariant checks, rollback readiness, and go/no-go decision recording in the active plan.
argument-hint: "[slug or docs/plans/active/<slug>-plan.md]"
---

# HE Verify/Release

Validate release readiness and record a GO/NO-GO decision.

## When to Use

- After `he-review` when all review gates pass
- When re-verifying after fixes from a previous NO-GO

## Key Principles

1. **Written GO/NO-GO** — decision is recorded in the plan with evidence, rollback, and post-release checks.
2. **Review must have passed** — includes security/data review and no unresolved `critical`/`high` findings.
3. **Rollback is required** — explicit and feasible, not hand-wavy.
4. **Evidence for user-visible changes** — capture agentic E2E artifacts when UI/behavior changes.
5. **Escalate when uncertain** — flaky failures, missing evidence, or unclear user/data risk.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-verify-release`), but never waive/override anything codified here.

## Workflow

### Phase 0: Load Context

- Read `docs/plans/active/<slug>-plan.md`.
- Gather review findings and test/integration evidence.
- Load repo-specific verification procedures from `docs/runbooks/verify-release.md` and `docs/runbooks/record-evidence.md`.

### Phase 1: Verify Gates (Parallel)

Launch parallel subagents for independent gate items:

1. Required tests pass.
2. Architecture and safety invariants hold.
3. Review gate passed (including security/data review) and there are no unresolved critical/high findings.
4. Rollback steps are documented and feasible.
5. Monitoring and post-release checks are defined.

If the change includes browser UI behavior, collect agentic E2E evidence via `agent-browser` and store it in `Artifacts and Notes`.

### Phase 2: Record Decision

Fill in `## Verify/Release Decision` in `docs/plans/active/<slug>-plan.md`.

**Decision rules:**

- `NO-GO` if any blocking gate fails.
- `GO` only with complete evidence and explicit rollback path.
- **Default safe action**: when uncertain, the decision is `NO-GO`. Record the re-entry target (`he-implement` or `he-plan`) and list the missing evidence. Do not default to `GO` with caveats.

### Phase 3: Handle NO-GO Re-entry

When decision is `NO-GO`:

- For minor fixes: return to `he-implement`.
- For design-level issues: return to `he-plan` and append `Decision Log` context.
- Update `Progress` items and append a `Revision Notes` entry describing re-entry reason.

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

## Output

- `## Verify/Release Decision` filled in `docs/plans/active/<slug>-plan.md`.

## Exit Gate

- Decision recorded in active plan
- Evidence references included
- If NO-GO: re-entry target phase identified with rationale
- Docs commit gate passes

## When Things Go Wrong

- **Tests pass locally but fail in CI** — investigate the delta; do not paper over with a GO. Record in `Surprises & Discoveries`.
- **Rollback plan is vague or untested** — this is a NO-GO condition. Document what's missing and return to implement.
- **Evidence is incomplete but pressure to ship** — default safe action is NO-GO. Escalate with the gap documented.
- **Flaky failures block a clear decision** — escalate with evidence of flakiness; do not retry silently hoping it passes.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Defaulting to GO with caveats | Default safe action is NO-GO; GO requires complete evidence |
| Skipping rollback documentation | Explicit, feasible rollback is a required gate |
| Ignoring flaky test failures | Record and escalate; flakiness is signal, not noise |
| Rubber-stamping after review passed | Verify independently; review is necessary but not sufficient |
| Hand-wavy monitoring plan | Define concrete post-release checks |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-learn` for GO (or the identified re-entry phase for NO-GO) (recommended)
2. Run one more build-feedback round in `he-verify-release`
3. Handoff/pause with status and explicit next action

If `GO`, proceed to merge using `docs/runbooks/merge-change.md`.

If running autonomously or no interactive tool is available, follow the recommended path automatically and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
