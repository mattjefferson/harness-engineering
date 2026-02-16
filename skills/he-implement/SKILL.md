---
name: he-implement
description: Executes active ExecPlans using milestone-driven progress updates, parallel subagents, and evidence-backed verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Implement

Execute a PLANS-compliant active plan and keep the plan artifact current.

## When to Use

- After `he-plan` when the initiative is ready for execution
- During re-entry from `he-review` or `he-verify-release` for fixes

## Key Principles

1. **Workspace isolation gate** — confirm an isolated workspace is selected and recorded before editing code.
2. **Plan-driven execution** — implement by `Progress` items and keep living sections current.
3. **Evidence as you go** — run relevant tests/commands continuously; do not batch validation at the end.
4. **Generated context is a tool** — refresh only what matters; keep it usable for reasoning.
5. **Unit/e2e by default** — avoid mock-only verification unless the repo explicitly documents an exception.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-implement`), but never waive/override anything codified here.

## Workflow

### Phase 0: Workspace Isolation Gate

1. Inspect current workspace state (`git status --short --branch`, current branch, worktree detection).
2. If not already isolated for this initiative, run `he-worktree` to choose and create the workspace.
3. For non-trivial or long-running work, prefer a dedicated worktree.
4. Never proceed directly on the default branch without explicit user consent.
5. Record selected strategy (`worktree` or `branch`), branch name, and workspace directory in `Decision Log` or `Revision Notes`.

### Phase 1: Load Context

- Read `docs/plans/active/<slug>.md`: `Purpose / Big Picture`, `Context and Orientation`, `Milestones`, `Plan of Work`, `Concrete Steps`, and `Validation and Acceptance`.
- Refresh generated context in `docs/generated/` when stale:
  1. Read `docs/generated/README.md` first (if present) for project-specific expectations.
  2. Refresh only the generated files relevant to the current milestones.
  3. Ensure refreshed files include an updated `last_updated` timestamp when the project uses that convention.
  4. If expected generated context is missing and cannot be refreshed, record the gap in `Revision Notes`.

### Phase 2: Execute

1. Build work queue from unchecked `Progress` items (`P1`, `P2`, ...).
2. Execute in milestone order by default.
3. Run parallel subagents only for explicitly independent `Progress` items.
4. Integrate changes after each milestone-sized batch and rerun targeted verification.
5. If implementation reveals a domain doc is missing, wrong, or incomplete, create or update it in-place and note the change in `Revision Notes`.
6. Continue until all planned `Progress` items are complete or explicitly deferred.

Use subagents aggressively for independent work while keeping integration and plan updates in the main thread.

**Subagent return contract** — each subagent returns:

- Changed files
- Implemented `Progress` item IDs
- Tests/verification run and results (`unit` or `e2e`; no mock-only verification)
- Unresolved risks with `priority`
- Evidence snippets (terminal output, screenshots, or logs)

**Integration rules:**

- Integrate one milestone batch at a time.
- Resolve conflicts before marking related `Progress` items done.
- If the plan lacks concrete file paths or commands, return to `he-plan` for clarification.

### Phase 3: Update Plan

After each batch, update `docs/plans/active/<slug>.md`:

- Check completed `Progress` items.
- Append new discoveries in `Surprises & Discoveries` with evidence.
- Append decisions in `Decision Log` when approach/scope changes.
- Update `Outcomes & Retrospective` with milestone outcomes/gaps.
- Add evidence to `Artifacts and Notes`.
- Append `Revision Notes` with what changed in the plan and why.

## Agentic E2E (Optional)

For browser UI verification, prefer `agent-browser` flows and store durable evidence in `Artifacts and Notes`.

## Output

- Updated `docs/plans/active/<slug>.md` with completed progress, evidence, and living sections current.

## Exit Gate

- All planned `Progress` items are completed or explicitly deferred
- Validation evidence is recorded in the plan
- Living sections are updated (`Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, `Revision Notes`)
- Workspace strategy/branch/path are documented for reproducibility
- Docs commit gate passes

## When Things Go Wrong

- **Plan lacks concrete steps** — return to `he-plan` for clarification rather than guessing.
- **Tests fail and root cause is unclear** — record the failure in `Surprises & Discoveries`, investigate, and escalate if unresolvable.
- **Merge conflicts during integration** — resolve before marking progress items done; do not skip.
- **Generated context is missing** — record the gap in `Revision Notes` and proceed with available context.
- **Scope creep during implementation** — stop and update the plan rather than implementing undocumented changes.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Batching all validation at the end | Evidence as you go — verify continuously |
| Using mocks instead of real tests | Unit or e2e only; mocks are a `high` finding |
| Working on default branch without consent | Workspace isolation gate first |
| Implementing without reading the plan | Plan-driven execution; read before writing |
| Skipping plan updates after each batch | Keep living sections current after every milestone |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-review` (recommended)
2. Run one more build-feedback round in `he-implement`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-review` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
