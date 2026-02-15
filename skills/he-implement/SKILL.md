---
name: he-implement
description: Executes active ExecPlans using milestone-driven progress updates, parallel subagents, and evidence-backed verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Implement

Execute a PLANS-compliant active plan and keep the plan artifact current.

## Key Principles

1. Workspace isolation gate: confirm an isolated workspace is selected and recorded before editing code.
2. Plan-driven execution: implement by `Progress` items and keep living sections current.
3. Evidence as you go: run relevant tests/commands continuously; do not batch validation at the end.
4. Generated context is a tool: refresh only what matters; keep it usable for reasoning.
5. Unit/e2e by default: avoid mock-only verification unless the repo explicitly documents an exception.
6. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in this skill.

## Inputs

- `docs/plans/active/<slug>.md`
- isolated workspace context from `he-worktree` (strategy, branch, directory)

## Workspace Isolation Gate

Before implementation execution:

1. Inspect current workspace state (`git status --short --branch`, current branch, and whether repo is a linked worktree).
2. If not already isolated for this initiative, run `he-worktree` to choose and create the workspace using the project branch/worktree logic.
3. For non-trivial or long-running work, prefer a dedicated worktree.
4. Never proceed directly on the default branch without explicit user consent.
5. Record selected strategy (`worktree` or `branch`), branch name, and workspace directory in `Decision Log` or `Revision Notes`.

## Generated Context

Before execution, refresh generated context in `docs/generated/` when stale:

1. Read `docs/generated/README.md` first (if present) for project-specific generated artifact expectations.
2. Refresh only the generated files relevant to the current milestones and validation scope.
3. Treat any generated `docs/generated/*.md` file as valid reference context, not only a fixed filename set.
4. Ensure refreshed generated files include an updated `last_updated` timestamp when the project uses that convention.
5. If expected generated context is missing and cannot be refreshed, record the gap and impact in `Revision Notes`.

## Execution Model

1. Ensure the workspace isolation gate above has been satisfied and `pwd` matches the selected workspace.
2. Read `Purpose / Big Picture`, `Context and Orientation`, `Milestones`, `Plan of Work`, `Concrete Steps`, and `Validation and Acceptance`. If implementation reveals a domain doc is missing, wrong, or incomplete, create or update it in-place and note the change in `Revision Notes`. See `docs/DOMAIN_DOCS.md` for the registry.
3. Build work queue from unchecked `Progress` items (`P1`, `P2`, ...).
4. Execute in milestone order by default.
5. Run parallel subagents only for explicitly independent `Progress` items.
6. Integrate changes after each milestone-sized batch and rerun targeted verification.
7. Continue until all planned `Progress` items are complete or explicitly deferred.

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
- Workspace strategy/branch/path are documented for reproducibility
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-review` (recommended)
2. Run one more build-feedback round in `he-implement`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-review` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
