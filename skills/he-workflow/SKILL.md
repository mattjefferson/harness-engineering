---
name: he-workflow
description: Orchestrates a harness-engineered workflow across intake, spike, plan, implement, review, verify-release, learn, and doc-gardening using docs/specs, docs/spikes, and PLANS-compliant active plans.
argument-hint: "[initiative request, slug, or active plan path]"
---

# HE Workflow Orchestrator

Run the full lifecycle with phase gates and parallel subagents.

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
2. spike (optional — when feasibility or approach is unclear)
3. plan
4. implement
5. review
6. verify-release
7. learn

`doc-gardening` is optional and periodic.

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
5. **Express path check**: if `plan_mode: trivial` in the spec metadata, skip steps 5a–10 and go directly to step 11 (refresh context), then step 12 (`he-implement`), then step 13 (`he-review` in fast-track mode), then step 15 (`he-learn` abbreviated). Skip `he-verify-release` for trivial changes. The docs commit gate and test evidence gate still apply.
5a. If `spike_recommended: yes` in the spec metadata, run `he-spike`.
6. Ensure `docs/plans/active/<slug>.md` exists; if missing, run `he-plan`.
7. Validate active plan has all required PLANS sections:
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
8. Validate `Progress` entries are timestamped checkboxes with stable IDs.
9. Validate concrete commands and expected outcomes exist in `Concrete Steps` and `Validation and Acceptance`.
10. Validate checklists are only used in `Progress`.
11. Refresh generated context in `docs/generated/` if stale.
12. Run `he-implement`.
13. Run `he-review` and enforce priority gate.
14. Run `he-verify-release`.
15. Run `he-learn` and archive plan.

## Subagent Strategy

Use subagents throughout to keep orchestrator context clean:

- **Intake**: subagents for codebase and prior-artifact discovery.
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
