---
name: he-plan
description: Produces an executable active plan from a spec with explicit task DAG, acceptance criteria, testing strategy, and release constraints. Use after intake.
argument-hint: "[slug or docs/specs/<slug>.md]"
---

# HE Plan

Convert a spec into a decision-complete execution plan.

## Inputs

- `docs/specs/<slug>.md`
- `docs/specs/<slug>-spike.md` (if a spike was run — incorporate findings into plan decisions)

## Output

- `docs/plans/active/<slug>.md`

## Subagent Usage

Use subagents to research the codebase before writing the plan. Launch parallel subagents to explore different areas of the codebase (e.g., one for the data layer, one for the API layer, one for the UI layer). Gather file lists, existing patterns, and test conventions from subagent results, then synthesize into the plan in the main thread.

## Planning Requirements

1. Read `plan_mode` from `docs/specs/<slug>.md`.
2. For `execution` mode:
   - Define architecture and interface decisions.
   - Define task DAG with explicit dependencies using sequence IDs (`1`, `1.1`, `1.2`).
   - Keep DAG entries high-level (task summary, dependency, parallel safety, priority, status).
   - Use full task detail format (see template) with all fields.
3. For `lightweight` mode:
   - Keep plan concise (typically <= 3 tasks).
   - Use sequence IDs (`1`, `1.1`, `1.2`) only as needed.
   - Use minimal task detail format: `files`, `steps`, `test_type`, `verify`, `done_when`.
   - Keep one short decision log and progress log section in the same template.
4. Define priority level (`critical|high|medium|low`) per task.
5. In `Task Details`, create one section per task/subtask using exact heading format: `#### [ ] <task_seq> [Action-oriented title]`.
6. Define concrete target files per task/subtask in Task Details (exact repo-relative paths).
7. Define concrete tests and verification commands per task/subtask in Task Details.
8. Specify `test_type` (unit or e2e) per task — no mock-based tests.
9. Task DAG `status` is the single source of truth for task completion state.
10. Keep implementation step checkboxes as local progress within each task detail.
11. Progress Log is append-only evidence — not a sync target.
12. Define rollout and rollback strategy.
13. Define escalation conditions.
14. Initialize `Decision Log` and `Progress Log` sections.

## Plan Template

Use `templates/active-plan-template.md`. Select the lightweight or execution task format based on `plan_mode`.

## Exit Gate

- Plan exists in `docs/plans/active/<slug>.md`
- Every task has acceptance criteria (or `done_when` for lightweight)
- Every task/subtask has a `#### [ ] <task_seq> [Action-oriented title]` section in Task Details
- Every task/subtask lists concrete file paths and tests
- Every task specifies `test_type` (unit or e2e) — no mocks
- For `execution` mode: every task includes objective, implementation steps, risks, rollback impact, and evidence fields
- For `lightweight` mode: every task includes files, steps, verify, and done_when
- Implementation steps are markdown checkboxes
- Task DAG status reflects current completion state
- Rollback path exists
- `Decision Log` exists
- `Progress Log` exists
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-implement`.
