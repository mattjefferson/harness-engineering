---
name: he-implement
description: Executes active plans using dependency-aware parallel batches, isolated task work, and integration checkpoints while using generated project context docs for reference. Use during build execution.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Implement

Execute plan tasks with DAG-batch parallelism.

## Inputs

- `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)

## Generated Context

- `docs/generated/db-schema.md` (if present)
- other generated reference docs in `docs/generated/` (if present)

## Execution Model

1. Parse task DAG/checklist from active plan and load concrete execution details from `Task Details` (`files_to_change`, `tests_to_run`, `verify_commands`).
2. Build next ready batch (all dependencies satisfied).
3. Spawn one worker per task in batch.
4. Execute workers concurrently.
5. Integrate batch outputs.
6. Repeat until no remaining tasks.

## Worker Contract

Each worker returns:

- changed files
- planned target files and whether each was touched (or explicit no-change reason)
- tests run and results
- unresolved risks with `priority`
- integration notes

## Integration Rules

- Integrate one batch at a time.
- If conflicts occur, split tasks or sequence conflicting tasks.
- Re-run targeted tests for integrated batch.
- If a task/subtask is missing concrete `files_to_change` or `verify_commands` in `Task Details`, send it back to planning before execution.

## Plan Progress Updates

Update `docs/plans/active/<slug>.md` after each batch:

- completed tasks
- blocked tasks
- notes for retry or reassignment
- append `Progress Log` entry with evidence
- append `Decision Log` entry when scope/approach changes

## Exit Gate

- All planned tasks completed or explicitly deferred
- Plan progress is current
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-review`.
- Wait for the user's selection before proceeding to the next phase.
