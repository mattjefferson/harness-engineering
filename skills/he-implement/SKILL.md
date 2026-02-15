---
name: he-implement
description: Executes active ExecPlans using milestone-driven progress updates, parallel subagents, and evidence-backed verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Implement

Execute a PLANS-compliant active plan and keep the plan artifact current.

## Inputs

- `docs/plans/active/<slug>.md`

## Generated Context

Before execution, refresh generated context when stale:

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)
- Other generated reference docs in `docs/generated/` (if present)

Each generated file should include a `last_updated` timestamp.

## Execution Model

1. Read `Purpose / Big Picture`, `Context and Orientation`, `Milestones`, `Plan of Work`, `Concrete Steps`, and `Validation and Acceptance`.
2. Build work queue from unchecked `Progress` items (`P1`, `P2`, ...).
3. Execute in milestone order by default.
4. Run parallel subagents only for explicitly independent `Progress` items.
5. Integrate changes after each milestone-sized batch and rerun targeted verification.
6. Continue until all planned `Progress` items are complete or explicitly deferred.

Use subagents aggressively for independent work while keeping integration and plan updates in the main thread.

## Subagent Return Contract

Each subagent returns:

- changed files
- implemented `Progress` item IDs
- tests/verification run and results (`unit` or `e2e`; no mock-only verification)
- unresolved risks with `priority`
- evidence snippets (terminal output, screenshots, or logs)

## Integration Rules

- Integrate one milestone batch at a time.
- Resolve conflicts before marking related `Progress` items done.
- If the plan lacks concrete file paths or commands, return to `he-plan` for clarification.

## Plan Update Contract

After each batch, update `docs/plans/active/<slug>.md`:

- Check completed `Progress` items.
- Append new discoveries in `Surprises & Discoveries` with evidence.
- Append decisions in `Decision Log` when approach/scope changes.
- Update `Outcomes & Retrospective` with milestone outcomes/gaps.
- Add evidence to `Artifacts and Notes`.
- Append `Revision Notes` with what changed in the plan and why.

## Agentic E2E (Optional)

For browser UI verification, prefer `agent-browser` flows and store durable evidence in `Artifacts and Notes`.

## Exit Gate

- All planned `Progress` items are completed or explicitly deferred
- Validation evidence is recorded in the plan
- Living sections are updated (`Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, `Revision Notes`)
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-review` (recommended)
2. Run one more build-feedback round in `he-implement`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-review` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
