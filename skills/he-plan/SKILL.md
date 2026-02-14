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

1. Define architecture and interface decisions.
2. Define task DAG with explicit dependencies.
3. Define acceptance criteria per task.
4. Define test scenarios and verification commands.
5. Define rollout and rollback strategy.
6. Define escalation conditions.

## Plan Template

Use `templates/active-plan-template.md`.

## Exit Gate

- Plan exists in `docs/plans/active/<slug>.md`
- Every task has dependencies and acceptance criteria
- Test matrix exists
- Rollback path exists
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-implement`.
- Wait for the user's selection before proceeding to the next phase.
