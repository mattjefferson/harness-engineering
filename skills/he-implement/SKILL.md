---
name: he-implement
description: Executes active plans using dependency-aware parallel batches, isolated task work, and integration checkpoints while updating generated run state. Use during build execution.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Implement

Execute plan tasks with DAG-batch parallelism.

## Inputs

- `docs/plans/active/<slug>.md`

## Runtime State

- `docs/generated/runs/<slug>/run.json`
- `docs/generated/runs/<slug>/tasks/<task-id>.json`
- `docs/generated/runs/<slug>/events.ndjson`

## Execution Model

1. Parse task DAG from active plan.
2. Build next ready batch (all dependencies satisfied).
3. Spawn one worker per task in batch.
4. Execute workers concurrently.
5. Integrate batch outputs.
6. Repeat until no remaining tasks.

## Worker Contract

Each worker returns:

- changed files
- tests run and results
- unresolved risks
- integration notes

Each worker updates:

- `tasks/<task-id>.json` with `status` and `evidence_refs`

## Integration Rules

- Integrate one batch at a time.
- If conflicts occur, split tasks or sequence conflicting tasks.
- Re-run targeted tests for integrated batch.

## Plan Progress Updates

Update `docs/plans/active/<slug>.md` after each batch:

- completed tasks
- blocked tasks
- notes for retry or reassignment

## Exit Gate

- All planned tasks completed or explicitly deferred
- Plan progress is current
- Runtime state files reflect final implementation status
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-review`.
- Wait for the user's selection before proceeding to the next phase.
