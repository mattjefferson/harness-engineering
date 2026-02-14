---
name: he-workflow
description: Orchestrates a harness-engineered workflow across intake, spike, plan, implement, review, verify-release, learn, and doc-gardening using a slug-based docs/specs and docs/plans system. Use when running an initiative end-to-end with parallel subagents.
argument-hint: "[initiative request, slug, or active plan path]"
---

# HE Workflow Orchestrator

Use this skill to run the full lifecycle with parallel execution and phase gates.

## Inputs

- Initiative request text, OR
- Existing slug (`YYYY-MM-DD-topic`), OR
- Existing active plan path (`docs/plans/active/<slug>.md`)

## Source of Truth

- Human intent: `docs/specs/<slug>.md`
- Spike findings: `docs/specs/<slug>-spike.md` (if a spike was run)
- Execution plan: `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- Generated project context: `docs/generated/` (for example `docs/generated/db-schema.md`)

## Slug Rules

- Format: `YYYY-MM-DD-kebab-topic`
- Reuse one slug across spec and plan artifacts
- Never create a second slug for the same initiative

## Required Phase Order

1. intake
2. spike (optional — when feasibility or approach is unclear)
3. plan
4. implement
5. review
6. verify-release
7. learn

`doc-gardening` is optional and periodic.

## Re-entry Rules

When a gate fails or a phase reveals issues requiring earlier work:

- **NO-GO at verify-release**: Return to `he-implement` for minor fixes or `he-plan` for design-level issues. Add a Decision Log entry explaining the loop-back.
- **Task failure during implement**: Mark task as `blocked` in Task DAG, log the reason in Progress Log, continue with remaining batch tasks.
- **Fundamental design issue at review**: Return to `he-plan` with a Decision Log entry. Re-validate the affected tasks before resuming implementation.
- **Every re-entry** creates a Progress Log entry explaining the loop-back and the target phase.

## Orchestration Steps

1. Resolve slug.
2. Validate workflow structure exists:
   - `docs/specs/`
   - `docs/plans/active/`
   - `docs/plans/completed/`
   - `docs/generated/`
   - `docs/references/`
3. If any required directory is missing, run `he-bootstrap` before continuing.
4. Ensure `docs/specs/<slug>.md` exists; if not, run `he-intake`.
5. If `spike_recommended: yes` in the spec metadata, run `he-spike` before planning.
6. Read `plan_mode` from `docs/specs/<slug>.md` (`lightweight` or `execution`).
7. Ensure `docs/plans/active/<slug>.md` exists for the selected `plan_mode`; if missing, run `he-plan`.
8. Validate every task/subtask has a `Task Details` section heading in format `#### [ ] <task_seq> [Action-oriented title]`.
9. For `execution` mode: validate plan tasks/subtasks include concrete `files_to_change`, `tests_to_run`, and `verify_commands` in `Task Details`.
10. For `lightweight` mode: validate tasks include `files`, `steps`, `verify`, and `done_when`.
11. Validate every task specifies `test_type` (unit or e2e) — no mocks.
12. Validate implementation steps are markdown checkboxes.
13. Validate Task DAG status reflects current completion state.
14. Validate the plan has both `Decision Log` and `Progress Log` sections.
15. Refresh generated context in `docs/generated/` if stale.
16. Run `he-implement` with DAG batches.
17. Run `he-review` and enforce priority gate.
18. Run `he-verify-release`.
19. Run `he-learn` and archive plan.

## Subagent Strategy

Use subagents liberally throughout the workflow to keep the orchestrator's context clean:

- **Intake**: Subagents for codebase research and prior-work discovery.
- **Spike**: One subagent per approach being compared.
- **Plan**: Subagents to explore different codebase layers in parallel.
- **Implement**: One subagent per task in each DAG batch — this is the primary parallelism lever.
- **Review**: One subagent per review dimension (correctness, architecture, security, simplicity).
- **Doc-gardening**: One subagent per scan target area.

The orchestrator delegates work to subagents and handles integration, plan updates, and gate enforcement in the main thread. Never do implementation or review work directly in the orchestrator context.

## Parallel Execution Contract

- Execute all dependency-free tasks in the same batch concurrently via subagents.
- Use isolated worktrees per task whenever task blast radius is non-trivial.
- Batch integration is required before advancing to the next dependency layer.
- On conflict, split or sequence tasks and retry integration.

## Branch and PR Convention

- One branch per initiative slug.
- Use worktree-per-task for parallel execution when blast radius is non-trivial.
- PR is created at the implement-to-review boundary.
- PR title follows: `<type>(<scope>): <slug> <summary>` (matching commit convention).
- Commit message convention:
  - `docs(intake): <slug> ...`
  - `docs(plan): <slug> ...`
  - `docs(review): <slug> ...`
  - `docs(verify-release): <slug> ...`
  - `docs(learn): <slug> ...`

## Gates

### Doc Commit Gate (Hard)

Before phase transition:

```bash
git status --short docs
```

- Required phase docs must be committed.
- No uncommitted docs changes at the boundary.

### Plan Specificity Gate

- Each task/subtask in `docs/plans/active/<slug>.md` must include a heading in format `#### [ ] <task_seq> [Action-oriented title]`.
- For `execution` mode: each task must include concrete file paths, test commands, objective, implementation steps, risks, rollback impact, and evidence.
- For `lightweight` mode: each task must include files, steps, verify, and done_when.
- Every task must specify `test_type` (unit or e2e) — no mocks.
- Step checkboxes (`implementation_steps` in execution mode, `steps` in lightweight mode) must be markdown checkboxes.
- Task DAG status is the single source of truth for completion state.
- Plans that use vague placeholders (for example `...`, `TBD`) for files/tests cannot proceed to implement.
- Plan must include explicit `Decision Log` and `Progress Log`.

### Priority Gate

- Unresolved `critical` or `high` priority findings block progression.
- `medium` and `low` priorities may proceed only with explicit acceptance notes in the plan.

## Generated Context Files

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)
- Other generated context files used as reference for planning/review/verification
- Each generated file should include a `last_updated` timestamp

## Completion

Workflow is complete when:

- Plan is moved to `docs/plans/completed/<slug>.md`
- Learn updates are written
- Docs are committed

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must name the next phase step (`intake -> he-spike or he-plan`, `spike -> he-plan`, `plan -> he-implement`, `implement -> he-review`, `review -> he-verify-release`, `verify-release -> he-learn`, `learn -> he-doc-gardening` or next-initiative `he-intake`).
