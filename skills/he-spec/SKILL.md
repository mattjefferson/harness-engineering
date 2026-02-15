---
name: he-spec
description: Converts fuzzy requests into a concrete initiative spec in docs/specs using a single slug and measurable success criteria. Use at the start of non-trivial work.
argument-hint: "[initiative description]"
---

# HE Spec

Create a decision-ready spec artifact for a new initiative.

## Key Principles

1. Intent only: define what/why/success; avoid implementation details.
2. Single slug: one initiative = one slug across spec/spike/plan artifacts.
3. Concrete success: requirements and success criteria must be testable/observable.
4. Route unknowns: investigatable questions go to `he-research`; experience-dependent unknowns go to `he-spike`.
5. No fake certainty: capture ambiguity explicitly instead of guessing.
6. Runbooks are additive only: apply any runbook whose frontmatter `called_from` matches this skill (see `python scripts/runbooks/select-runbooks.py --skill <skill>`), but never waive/override anything codified here.

## Output

- `docs/specs/<slug>.md`

## Slug

- Create one slug: `YYYY-MM-DD-kebab-topic`
- Use this slug for all subsequent phase artifacts

## Subagent Usage

When scoping a new initiative, use subagents to research the codebase in parallel — e.g., one subagent to find relevant files and existing patterns, another to check for related specs or prior work in `docs/specs/` and `docs/plans/completed/`. Feed subagent findings into the spec rather than doing all exploration in the main thread.

## Intake Procedure

1. Define a concise purpose/big-picture statement (problem + target user/outcome).
2. Define scope with `In Scope` and explicit `Boundaries` (deliberate exclusions).
3. Define requirements in a table with stable IDs (`R1`, `R2`, ...) and priorities.
4. Define measurable success criteria.
5. Define constraints (time, risk, compatibility, performance).
6. Classify overall priority (`critical`, `high`, `medium`, `low`).
7. Draft initial milestone candidates (`M1`, `M2`, ...) with observable outcomes and likely risk hotspots.
8. Add `Handoff` and initialize `Revision Notes` (append-only).

## Progressive Disclosure Rules

- Always include: `Purpose / Big Picture`, `Scope`, `Non-Goals`, `Risks`, `Rollout`, `Validation and Acceptance Signals`, `Requirements`, `Success Criteria`, `Priority`, `Initial Milestone Candidates`, `Handoff`.
- Include only when needed: `Chosen Direction`, `Alternatives Considered`, `Key Decisions`, `Open Questions`.
- Keep implementation detail out of intake spec (libraries/endpoints/schema details belong in planning).

## Plan Path Selection (Required)

Select `plan_mode` in the spec frontmatter:

- `trivial` when **all** are true:
  - Single-file change (or config-only tweak)
  - No schema migration, auth change, security boundary change, or public API contract break
  - Overall risk is `low`
  - No spike needed
  - Spec can be abbreviated: Purpose + single requirement + success criteria only
- `lightweight` when all are true:
  - Change is small (typically <= 3 milestones and <= 3 files)
  - No schema migration, auth change, security boundary change, or public API contract break
  - Overall risk is not `critical`
  - Validation can be covered by a short targeted test set
- `execution` for all other work

Write `plan_mode: <trivial|lightweight|execution>` in the YAML frontmatter of `docs/specs/<slug>.md`.

When `plan_mode: trivial`, the spec may omit optional sections entirely — only `Purpose / Big Picture`, one requirement row, and `Success Criteria` are required.

Set `spike_recommended: yes` in YAML frontmatter if the fuzzy-idea loop concludes a spike is needed, otherwise `spike_recommended: no`.

## Fuzzy-Idea Loop

If request is unclear:

1. Capture intended outcome in one sentence.
2. Offer 2-3 possible approaches with tradeoffs.
3. Pick a default approach and list assumptions.
4. If still ambiguous, recommend `he-spike` before planning.

## Spec Template

Use `templates/spec-template.md`.

## Exit Gate

- Spec exists at `docs/specs/<slug>.md`
- Purpose / Big Picture is explicit
- Scope includes explicit boundaries
- Requirements table exists with stable requirement IDs (`R1+`)
- Success criteria are measurable
- Handoff is explicit
- Priority assigned
- `plan_mode` is assigned (`trivial`, `lightweight`, or `execution`)
- `spike_recommended` is assigned (`yes` or `no`)
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-research` when meaningful open questions remain; otherwise continue to `he-plan` (or `he-spike` when `spike_recommended: yes`; for `plan_mode: trivial`, use an abbreviated plan and continue to implement) (recommended)
2. Run one more build-feedback round in `he-spec`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
