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

Before starting execution, refresh generated context if stale:

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)
- Other generated reference docs in `docs/generated/` (if present)

Each generated file should include a `last_updated` timestamp.

## Execution Model

1. Parse task DAG/checklist from active plan and load concrete execution details from `Task Details`.
   - For `execution` mode: load `files_to_change`, `tests_to_run`, `verify_commands`.
   - For `lightweight` mode: load `files`, `steps`, `test_type`, `verify`, `done_when`.
2. Build next ready batch (all dependencies satisfied).
3. **Launch one subagent per task in the batch.** Each subagent receives the task details, target files, and relevant generated context. Run all subagents in the batch concurrently.
4. Collect subagent results and integrate batch outputs.
5. Repeat until no remaining tasks.

Use subagents aggressively — every independent task in a batch should be its own subagent. Keep the main context clean by offloading implementation work to subagents and only handling integration and plan updates in the main thread.

## Subagent Return Contract

Each subagent returns:

- changed files
- planned target files (`files_to_change` or `files`) and whether each was touched (or explicit no-change reason)
- tests run and results (must match task's `test_type` — unit or e2e, no mocks)
- unresolved risks with `priority`
- integration notes

## Integration Rules

- Integrate one batch at a time.
- If conflicts occur, split tasks or sequence conflicting tasks.
- Re-run targeted tests for integrated batch.
- If a task is missing concrete file paths or verify commands in `Task Details`, send it back to planning before execution.

## Branch and PR Convention

- Work on the initiative's branch (one branch per slug).
- Use worktree-per-task for parallel execution when blast radius is non-trivial.
- Create PR at the implement-to-review boundary.

## Plan Progress Updates

Update `docs/plans/active/<slug>.md` after each batch:

- Update `Task DAG` statuses (`todo|in_progress|blocked|done`) — this is the single source of truth
- Check/uncheck step checkboxes (`implementation_steps` in execution mode, `steps` in lightweight mode) to reflect executed work
- Append `Progress Log` entry with evidence
- Append `Decision Log` entry when scope/approach changes

## Exit Gate

- All planned tasks completed or explicitly deferred
- Plan progress is current
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-review`.
