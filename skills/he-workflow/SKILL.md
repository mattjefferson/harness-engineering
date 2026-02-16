---
name: he-workflow
description: Orchestrates a harness-engineered workflow across intake, research, spike, plan, implement, review, verify-release, learn, and doc-gardening using docs/specs, docs/spikes, and PLANS-compliant active plans.
argument-hint: "[initiative request, slug, or active plan path]"
---

# HE Workflow Orchestrator

Run the full lifecycle with phase gates and parallel subagents.

## When to Use

- Starting a new initiative from scratch
- Resuming an in-progress initiative at any phase
- Running a complete end-to-end workflow

## Key Principles

1. **Phase order is enforced** — do not skip gates casually.
2. **Single slug** — one initiative uses one slug across artifacts.
3. **Re-entry is explicit** — update plan living sections when returning to earlier phases.
4. **Evidence-based transitions** — progress only when gates pass; otherwise stop and record blockers.
5. **Prefer autonomy with traceability** — auto-transitions are logged in artifacts.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-workflow`), but never waive/override anything codified here.

## Workflow

### Phase 0: Initialize

1. Resolve slug from initiative request, existing slug, or active plan path.
2. Validate workflow structure exists:
   - `docs/specs/`, `docs/spikes/`, `docs/plans/active/`, `docs/plans/completed/`, `docs/generated/`
3. If required directories are missing, run `he-bootstrap`.

### Phase 1: Intake

1. Ensure `docs/specs/<slug>.md` exists; if not, run `he-spec`.
2. If the spec has meaningful open questions that are investigatable, run `he-research`.
3. If `spike_recommended: yes` in the spec metadata, run `he-spike`.

### Phase 2: Plan

1. Ensure `docs/plans/active/<slug>.md` exists; if missing, run `he-plan` (use an abbreviated plan for `plan_mode: trivial`).
2. Validate active plan has all required PLANS sections:
   - `Purpose / Big Picture`, `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, `Context and Orientation`, `Milestones`, `Plan of Work`, `Concrete Steps`, `Validation and Acceptance`, `Idempotence and Recovery`, `Artifacts and Notes`, `Interfaces and Dependencies`, `Pull Request`, `Revision Notes`, `Review Findings`, `Verify/Release Decision`
3. Validate `Progress` entries are timestamped checkboxes with stable IDs.
4. Validate concrete commands and expected outcomes exist in `Concrete Steps` and `Validation and Acceptance`.
5. Validate checklists are only used in `Progress`.
6. Refresh generated context in `docs/generated/` if stale.

### Phase 3: Execute

1. Run `he-implement`.
2. If a PR-driven loop is desired, run `he-github` to open/update the PR and link plan/evidence.

### Phase 4: Quality Gate

1. Run `he-review` and enforce priority gate (`plan_mode: trivial` uses fast-track single-reviewer mode).
2. If `plan_mode` is not `trivial`, run `he-verify-release`; otherwise skip to Phase 5.

### Phase 5: Close

1. Run `he-learn` and archive plan (abbreviated learn path for `plan_mode: trivial`).

## Source of Truth

- Human intent: `docs/specs/<slug>.md`
- Spike findings: `docs/spikes/<slug>-spike.md` (if a spike was run)
- Execution plan: `docs/plans/active/<slug>.md` (`plan_mode: trivial|lightweight|execution`, PLANS-compliant)
- Plan contract: `docs/PLANS.md`
- Generated project context: `docs/generated/`

## Artifact Contracts (Step-to-Step)

Forward progress must depend on stable, versioned artifacts — not mutable runbooks.

- **intake → plan**: `docs/specs/<slug>.md` exists and is lint-clean.
- **plan → implement**: `docs/plans/active/<slug>.md` exists and is PLANS-compliant.
- **implement → github** (optional): code + tests + evidence are recorded in the plan; PR metadata is written into `## Pull Request`.
- **implement → review**: implementation evidence is linked in `Artifacts and Notes`; `Progress` reflects current state.
- **review → verify-release**: consolidated findings are written into `## Review Findings` in the plan.
- **verify-release → merge**: GO/NO-GO is written into `## Verify/Release Decision` with evidence + rollback.
- **merge → learn**: learnings + prevention actions are recorded; plan is archived to `docs/plans/completed/<slug>.md`.

Runbooks are additive: if they are missing, stale, or wrong, do not block — proceed using the skill gates and artifact contracts above.

## Slug Rules

- Format: `YYYY-MM-DD-kebab-topic`
- Reuse one slug across spec and plan artifacts
- Never create a second slug for the same initiative

## Re-entry Rules

When a gate fails or a phase reveals issues requiring earlier work:

- **NO-GO at verify-release**: Return to `he-implement` for minor fixes or `he-plan` for design-level issues. Append a `Decision Log` entry and update `Progress`.
- **Execution blocker during implement**: Mark impacted `Progress` items as incomplete/blocked in-place and add context to `Surprises & Discoveries`.
- **Fundamental design issue at review**: Return to `he-plan` with a `Decision Log` entry and update `Revision Notes`.
- **Every re-entry** updates `Progress` and `Revision Notes` with reason and target phase.

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

## Output

- Complete initiative lifecycle: spec → plan → implementation → review → verify → learn → archive.

## Exit Gate

- Plan is moved to `docs/plans/completed/<slug>.md`
- Learn updates are written
- Docs are committed

## When Things Go Wrong

- **Required directories are missing** — run `he-bootstrap` before proceeding.
- **Gate fails at any phase** — stop, record the blocker, and follow re-entry rules.
- **Phase order is violated** — stop and correct; do not skip gates.
- **Autonomous transition encounters ambiguity** — stop and log the blocking condition; do not guess.
- **Runbook is missing or stale** — proceed using skill gates and artifact contracts; fix the runbook in `he-learn`.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Skipping phases because "it's simple" | Phase order is enforced; use `plan_mode: trivial` for abbreviation |
| Creating multiple slugs for one initiative | One slug across all artifacts |
| Blocking on missing runbooks | Proceed using skill gates; fix runbooks in learn phase |
| Silent re-entry without updating artifacts | Every re-entry updates `Progress` and `Revision Notes` |
| Guessing at transitions when gates are ambiguous | Stop, record the blocker, and escalate |

## Transition Points

At every phase boundary, always use interactive question tool when a human is in the loop (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent).

Present these options at each transition:

1. Continue to the default next phase (recommended)
2. Run one more build-feedback round in the current phase
3. Handoff/pause with a concise status summary and explicit next action

Never only print options as plain text when an interactive question tool is available.

If running autonomously (no user interaction possible), do not block waiting for input:

- Continue to the default next phase when gates pass.
- Record an `Autonomous transition` note in `Decision Log` or `Revision Notes` with source phase, target phase, and reason.
- If a gate fails, stop and record the blocking condition plus required user decision.
