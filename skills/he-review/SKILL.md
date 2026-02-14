---
name: he-review
description: Runs agent-first review fanout across correctness, architecture, security/data, and simplicity, then enforces severity gates before release verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Review

Run structured, parallel code review before verify/release.

## Inputs

- `docs/plans/active/<slug>.md`
- Implementation evidence from generated runtime state

## Review Fanout (Parallel)

Run these reviewers concurrently:

1. correctness reviewer
2. architecture/invariants reviewer
3. security/data reviewer
4. simplicity reviewer

## Findings Format

Each finding includes:

- severity: `critical|high|medium|low`
- location: file/path + context
- issue summary
- required action
- owner

## Consolidation

Write consolidated findings into plan:

- section: `## Review Findings`
- include unresolved and accepted items
- include explicit rationale for accepted medium/low items

## Severity Gate

- Any unresolved `critical` or `high` finding blocks progression.
- `medium` and `low` can proceed only if accepted in writing in the active plan.

## Guardrail Promotion

When the same class of finding repeats:

- propose mechanical guardrail (lint/test/structural check)
- record it in `docs/plans/tech-debt-tracker.md`

## Exit Gate

- Review findings recorded in active plan
- Critical/high findings resolved or explicitly escalated
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-verify-release`.
- Wait for the user's selection before proceeding to the next phase.
