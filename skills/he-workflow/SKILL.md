---
name: he-workflow
description: Orchestrates a harness-engineered workflow across intake, plan, implement, review, verify-release, learn, and entropy using a slug-based docs/specs and docs/plans system. Use when running an initiative end-to-end with parallel subagents.
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
- Execution plan: `docs/plans/active/<slug>.md`
- Runtime state: `docs/generated/runs/<slug>/`

## Slug Rules

- Format: `YYYY-MM-DD-kebab-topic`
- Reuse one slug across spec, plan, and generated state
- Never create a second slug for the same initiative

## Required Phase Order

1. intake
2. plan
3. implement
4. review
5. verify-release
6. learn

`entropy` is optional and periodic.

## Orchestration Steps

1. Resolve slug.
2. Validate workflow structure exists:
   - `docs/specs/`
   - `docs/plans/active/`
   - `docs/plans/completed/`
   - `docs/generated/runs/`
   - `docs/references/`
3. If any required directory is missing, run `he-bootstrap` before continuing.
4. Ensure `docs/specs/<slug>.md` exists; if not, run `he-intake`.
5. Ensure `docs/plans/active/<slug>.md` exists; if not, run `he-plan`.
6. Run `he-implement` with DAG batches.
7. Run `he-review` and enforce severity gate.
8. Run `he-verify-release`.
9. Run `he-learn` and archive plan.

## Parallel Execution Contract

- Execute all dependency-free tasks in the same batch concurrently.
- Use isolated worktrees per task whenever task blast radius is non-trivial.
- Batch integration is required before advancing to the next dependency layer.
- On conflict, split or sequence tasks and retry integration.

## Gates

### Doc Commit Gate (Hard)

Before phase transition:

```bash
git status --short docs
```

- Required phase docs must be committed.
- No uncommitted docs changes at the boundary.

Commit message convention:

- `docs(intake): <slug> ...`
- `docs(plan): <slug> ...`
- `docs(review): <slug> ...`
- `docs(verify-release): <slug> ...`
- `docs(learn): <slug> ...`

### Severity Gate

- Unresolved `critical` or `high` findings block progression.
- `medium` and `low` may proceed only with explicit acceptance notes in the plan.

## Runtime State Files

- `docs/generated/runs/<slug>/run.json`
- `docs/generated/runs/<slug>/tasks/<task-id>.json`
- `docs/generated/runs/<slug>/events.ndjson`

Minimal `run.json` fields:

- `slug`
- `phase`
- `status`
- `current_batch`
- `updated_at`

## Completion

Workflow is complete when:

- Plan is moved to `docs/plans/completed/<slug>.md`
- Learn updates are written
- Docs are committed

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly name the next phase step (`intake -> he-plan`, `plan -> he-implement`, `implement -> he-review`, `review -> he-verify-release`, `verify-release -> he-learn`, `learn -> he-entropy` or next-initiative `he-intake`).
- Wait for the user's selection before proceeding to the next phase.
