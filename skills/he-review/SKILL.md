---
name: he-review
description: Runs agent-first review fanout across correctness, architecture, security/data, and simplicity, then enforces priority gates before release verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Review

Run structured, parallel code review before verify/release.

## Inputs

- `docs/plans/active/<slug>.md`
- Implementation evidence from diffs/tests and generated reference context in `docs/generated/`

## Generated Context

Refresh generated context before review if stale:

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)

## Review Fanout (Parallel)

Launch one subagent per reviewer and run concurrently:

1. correctness reviewer
2. architecture/invariants reviewer
3. security/data reviewer
4. simplicity reviewer

Each subagent receives the active plan, diffs, and generated context.

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

## Consolidation

Write consolidated findings into `## Review Findings` in the active plan, including rationale for accepted medium/low findings.

## Priority Gate

- Any unresolved `critical` or `high` finding blocks progression.
- `medium` and `low` findings can proceed only if explicitly accepted in writing.

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
