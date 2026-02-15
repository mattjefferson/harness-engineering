---
name: he-review
description: Runs agent-first review fanout across correctness, architecture, security/data, and simplicity, then enforces priority gates before release verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Review

Run structured, parallel code review before verify/release.

## Key Principles

1. Security/data review is mandatory (even for trivial changes).
2. The priority gate is real: unresolved `critical`/`high` blocks progression.
3. Findings must be actionable: file/symbol + required action + owner.
4. Runbooks are additive only: apply any runbook whose frontmatter `called_from` matches this skill (see `python scripts/runbooks/select-runbooks.py --skill <skill>`), but never waive/override any gates codified here.
5. Escalate on judgment: unclear risk, ambiguous behavior, or flaky failures.

## Runbooks

These runbooks hold the repo-specific procedures that evolve over time:

- `docs/runbooks/code-review.md`
- `docs/runbooks/review-findings.md`
- `docs/runbooks/address-review-findings.md`
- `docs/runbooks/escalation.md`

Runbooks are additive only. If a runbook is missing or low-quality, do not block forward progress — proceed using the skill-enforced gates and record the runbook drift for `he-learn`.

In addition to the baseline list above, apply any additional runbooks returned by:

`python scripts/runbooks/select-runbooks.py --skill he-review`

## Inputs

- `docs/plans/active/<slug>.md`
- Implementation evidence from diffs/tests and generated reference context in `docs/generated/`

## Generated Context

Refresh generated context before review if stale:

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)

## Fast-Track Mode (Trivial Changes)

When `plan_mode: trivial`, keep review lightweight but do not waive non-negotiable gates:

- Run **correctness reviewer**
- Run **security/data reviewer**

Skip architecture and simplicity reviewers — the trivial criteria already guarantee low risk and single-file scope. All other review mechanics (findings format, priority gate, exit gate) still apply.

## Review Fanout (Parallel)

For `plan_mode: lightweight` or `execution`, launch one subagent per reviewer and run concurrently:

1. correctness reviewer
2. architecture/invariants reviewer
3. security/data reviewer
4. simplicity reviewer

Each subagent receives the active plan, diffs, and generated context.

## Non-Negotiable Gates

Runbooks are additive guidance only. They may add repo-specific checks, but they must not remove or relax these gates:

- A security/data review is always performed.
- Unresolved `critical` or `high` findings block progression.
- Mock-based tests remain a `high` priority finding unless the repo explicitly documents an exception.

If a runbook suggests skipping a non-negotiable gate, treat it as policy drift: record a `high` finding and escalate.

## Review Dimensions

Each reviewer checks against:

- `Purpose / Big Picture`
- `Validation and Acceptance`
- Completed vs. open `Progress` items
- Golden principles defined in AGENTS.md
- Testing philosophy: mock-based tests are a `high` priority finding

## Findings Format

Each finding includes:

- priority: `critical|high|medium|low`
- location: file/path + context
- issue summary
- required action
- owner

The priority rubric and acceptance conventions live in `docs/runbooks/review-findings.md`.

## Consolidation

Write consolidated findings into `## Review Findings` in the active plan, including rationale for accepted medium/low findings.

## Priority Gate

- Any unresolved `critical` or `high` finding blocks progression.
- `medium` and `low` findings can proceed only if explicitly accepted in writing.

## Judgment Required (Escalate)

Stop and escalate via `docs/runbooks/escalation.md` when:

- Expected behavior is ambiguous or disputed
- Risk to users/data is unclear
- Failures are flaky/non-deterministic
- A "fix" would weaken the evidence or remove meaningful assertions

## Re-entry on Fundamental Issues

When review reveals a design-level issue:

- Return to `he-plan`.
- Append a `Decision Log` entry describing the issue and chosen correction.
- Update affected `Progress` items and `Revision Notes`.

## Exit Gate

- Review findings recorded in active plan
- Critical/high findings resolved or explicitly escalated
- No mock-based tests in implementation
- If fundamental design issue found: re-entry to `he-plan` identified
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-verify-release` (recommended when not blocked)
2. Run one more build-feedback round in `he-review`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-verify-release` when gates pass; otherwise stop at the gate and log the blocking reason plus required decision.
