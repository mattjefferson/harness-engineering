---
name: he-plan
description: Produces an executable active plan from a spec with explicit task DAG, acceptance criteria, testing strategy, and release constraints. Use after intake.
argument-hint: "[slug or docs/specs/<slug>.md]"
---

# HE Plan

Convert a spec into a decision-complete execution plan.

## Inputs

- `docs/specs/<slug>.md`

## Output

- `docs/plans/active/<slug>.md`

## Planning Requirements

1. Read `plan_mode` from `docs/specs/<slug>.md`.
2. For `execution` mode:
   - Define architecture and interface decisions.
   - Define task DAG with explicit dependencies using sequence IDs (`1`, `1.1`, `1.2`).
   - Keep DAG entries high-level (task summary, dependency, parallel safety, priority, status).
3. For `lightweight` mode:
   - Keep plan concise (typically <= 3 tasks).
   - Use sequence IDs (`1`, `1.1`, `1.2`) only as needed.
   - Keep one short decision log and progress log section in the same template.
4. Define priority level (`critical|high|medium|low`) per task.
5. Define concrete target files per task/subtask in Task Details (exact repo-relative paths).
6. Define concrete tests and verification commands per task/subtask in Task Details.
7. Define rollout and rollback strategy.
8. Define escalation conditions.
9. Initialize `Decision Log` and `Progress Log` sections.

## Plan Template

Use `templates/active-plan-template.md` for both `lightweight` and `execution`.

## Exit Gate

- Plan exists in `docs/plans/active/<slug>.md`
- Every task has acceptance criteria
- Every task/subtask lists concrete file paths and tests
- Rollback path exists
- `Decision Log` exists
- `Progress Log` exists
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-implement`.
- Wait for the user's selection before proceeding to the next phase.
