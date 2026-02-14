---
name: he-review
description: Runs agent-first review fanout across correctness, architecture, security/data, and simplicity, then enforces priority gates before release verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Review

Run structured, parallel code review before verify/release.

## Inputs

- `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- Implementation evidence from diffs/tests and generated reference context in `docs/generated/`

## Generated Context

Refresh generated context before review if stale:

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)

## Review Fanout (Parallel)

**Launch one subagent per reviewer.** Run all four concurrently:

1. correctness reviewer subagent
2. architecture/invariants reviewer subagent
3. security/data reviewer subagent
4. simplicity reviewer subagent

Each subagent receives the plan, the diffs, and the relevant generated context. Each returns a list of findings in the standard format. The main thread consolidates results — do not do review work in the main thread.

## Review Dimensions

Each reviewer checks against:

- The plan's acceptance criteria and `done_when` conditions
- Golden principles defined in AGENTS.md (flag violations as findings)
- Testing philosophy: flag any mock-based tests as a `high` priority finding

## Findings Format

Each finding includes:

- priority: `critical|high|medium|low`
- location: file/path + context
- issue summary
- required action
- owner

## Consolidation

Write consolidated findings into plan:

- section: `## Review Findings`
- include unresolved and accepted items
- include explicit rationale for accepted medium/low items

## Priority Gate

- Any unresolved `critical` or `high` priority finding blocks progression.
- `medium` and `low` priorities can proceed only if accepted in writing in the active plan.

## Guardrail Promotion

When the same class of finding repeats:

- propose mechanical guardrail (lint/test/structural check)
- record it in `docs/plans/tech-debt-tracker.md`

## Re-entry on Fundamental Issues

When review reveals a fundamental design issue (not just a bug fix):

- Return to `he-plan` with a Decision Log entry explaining the issue.
- Re-validate affected tasks before resuming implementation.
- Create a Progress Log entry explaining the loop-back.

## Exit Gate

- Review findings recorded in active plan
- Critical/high findings resolved or explicitly escalated
- No mock-based tests in the implementation
- If fundamental design issue found: re-entry to `he-plan` identified
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-verify-release`. If a fundamental design issue requires re-entry, offer `Next step: he-plan` instead.
