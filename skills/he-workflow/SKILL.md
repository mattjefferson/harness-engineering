---
name: he-workflow
description: Orchestrates a harness-engineered workflow across intake, research, spike, plan, implement, review, verify-release, learn, and doc-gardening using docs/specs, docs/spikes, and PLANS-compliant active plans.
argument-hint: "[initiative request, slug, or active plan path]"
---

# HE Workflow Orchestrator

Run the full lifecycle with phase gates and parallel subagents.

## Key Principles

1. Phase order is enforced: do not skip gates casually.
2. Single slug: one initiative uses one slug across artifacts.
3. Re-entry is explicit: update plan living sections when returning to earlier phases.
4. Evidence-based transitions: progress only when gates pass; otherwise stop and record blockers.
5. Prefer autonomy with traceability: auto-transitions are logged in artifacts.
6. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in this skill.

## Inputs

- Initiative request text, OR
- Existing slug (`YYYY-MM-DD-topic`), OR
- Existing active plan path (`docs/plans/active/<slug>.md`)

## Source of Truth

- Human intent: `docs/specs/<slug>.md`
- Spike findings: `docs/spikes/<slug>-spike.md` (if a spike was run)
- Execution plan: `docs/plans/active/<slug>.md` (`plan_mode: trivial|lightweight|execution`, PLANS-compliant)
- Plan contract: `docs/PLANS.md`
- Generated project context: `docs/generated/` (for example `docs/generated/db-schema.md`)

## Slug Rules

- Format: `YYYY-MM-DD-kebab-topic`
- Reuse one slug across spec and plan artifacts
- Never create a second slug for the same initiative

## Required Phase Order

1. intake
2. research (optional — when open questions are answerable through investigation)
3. spike (optional — when feasibility or approach is unclear)
4. plan
5. implement
6. review
7. verify-release
8. learn

`doc-gardening` is optional and periodic.
For `plan_mode: trivial`, skip `verify-release` after review.

## Re-entry Rules

When a gate fails or a phase reveals issues requiring earlier work:

- **NO-GO at verify-release**: Return to `he-implement` for minor fixes or `he-plan` for design-level issues. Append a `Decision Log` entry and update `Progress`.
- **Execution blocker during implement**: Mark impacted `Progress` items as incomplete/blocked in-place and add context to `Surprises & Discoveries`.
- **Fundamental design issue at review**: Return to `he-plan` with a `Decision Log` entry and update `Revision Notes`.
- **Every re-entry** updates `Progress` and `Revision Notes` with reason and target phase.

## Orchestration Steps

1. Resolve slug.
2. Validate workflow structure exists:
   - `docs/specs/`
   - `docs/spikes/`
   - `docs/plans/active/`
   - `docs/plans/completed/`
   - `docs/generated/`
3. If required directories are missing, run `he-bootstrap`.
4. Ensure `docs/specs/<slug>.md` exists; if not, run `he-spec`.
5. If the spec has meaningful open questions that are investigatable, run `he-research`.
6. If `spike_recommended: yes` in the spec metadata, run `he-spike`.
7. Ensure `docs/plans/active/<slug>.md` exists; if missing, run `he-plan` (use an abbreviated plan for `plan_mode: trivial`).
8. Validate active plan has all required PLANS sections:
   - `Purpose / Big Picture`
   - `Progress`
   - `Surprises & Discoveries`
   - `Decision Log`
   - `Outcomes & Retrospective`
   - `Context and Orientation`
   - `Milestones`
   - `Plan of Work`
   - `Concrete Steps`
   - `Validation and Acceptance`
   - `Idempotence and Recovery`
   - `Artifacts and Notes`
   - `Interfaces and Dependencies`
   - `Revision Notes`
9. Validate `Progress` entries are timestamped checkboxes with stable IDs.
10. Validate concrete commands and expected outcomes exist in `Concrete Steps` and `Validation and Acceptance`.
11. Validate checklists are only used in `Progress`.
12. Refresh generated context in `docs/generated/` if stale.
13. Run `he-implement`.
14. Run `he-review` and enforce priority gate (`plan_mode: trivial` uses fast-track single-reviewer mode).
15. If `plan_mode` is not `trivial`, run `he-verify-release`; otherwise skip to step 16.
16. Run `he-learn` and archive plan (abbreviated learn path for `plan_mode: trivial`).

## Subagent Strategy

Use subagents throughout to keep orchestrator context clean:

- **Intake**: subagents for codebase and prior-artifact discovery.
- **Research**: one subagent per independent question.
- **Spike**: one subagent per approach under evaluation.
- **Plan**: subagents for layered context gathering.
- **Implement**: one subagent per independent progress item.
- **Review**: one subagent per review dimension.
- **Doc-gardening**: one subagent per scan area.

The orchestrator integrates results, updates plan artifacts, and enforces gates.

## Priority Gate

- Unresolved `critical` or `high` priority findings block progression.
- `medium` and `low` priorities may proceed only with explicit acceptance notes.

## Generated Context Files

- `docs/generated/db-schema.md` (if present)
- `docs/generated/api-schema.md` (if present)
- `docs/generated/component-tree.md` (if present)
- `docs/generated/dependency-graph.md` (if present)
- Other generated context files used as reference
- Each generated file should include a `last_updated` timestamp

## Completion

Workflow is complete when:

- Plan is moved to `docs/plans/completed/<slug>.md`
- Learn updates are written
- Docs are committed

## Transition Interaction Protocol

At every phase boundary, use an interactive question tool when a human is in the loop:

- Codex (Plan mode): `request_user_input`
- Claude Code: `AskUserQuestion`
- Equivalent interactive prompt tool on other runtimes

Present these options at each transition point:

1. Continue to the default next phase (recommended)
2. Run one more build-feedback round in the current phase
3. Handoff/pause with a concise status summary and explicit next action

Never only print options as plain text when an interactive question tool is available.

If running autonomously (no user interaction possible), do not block waiting for input:

- Continue to the default next phase when gates pass
- Record an `Autonomous transition` note in `Decision Log` or `Revision Notes` with source phase, target phase, and reason
- If a gate fails, stop and record the blocking condition plus required user decision
