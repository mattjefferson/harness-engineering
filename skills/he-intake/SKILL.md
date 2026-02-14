---
name: he-intake
description: Converts fuzzy requests into a concrete initiative spec in docs/specs using a single slug and measurable success criteria. Use at the start of non-trivial work.
argument-hint: "[initiative description]"
---

# HE Intake

Create a decision-ready spec artifact for a new initiative.

## Output

- `docs/specs/<slug>.md`

## Slug

- Create one slug: `YYYY-MM-DD-kebab-topic`
- Use this slug for all subsequent phase artifacts

## Subagent Usage

When scoping a new initiative, use subagents to research the codebase in parallel — e.g., one subagent to find relevant files and existing patterns, another to check for related specs or prior work in `docs/specs/` and `docs/plans/completed/`. Feed subagent findings into the spec rather than doing all exploration in the main thread.

## Intake Procedure

1. Define a concise goal statement (problem + target user/outcome).
2. Define scope with `In Scope` and explicit `Boundaries` (deliberate exclusions).
3. Define requirements in a table with stable IDs (`R1`, `R2`, ...) and priorities.
4. Define measurable success criteria.
5. Define constraints (time, risk, compatibility, performance).
6. Classify overall priority (`critical`, `high`, `medium`, `low`).
7. Draft initial task graph candidates with rough dependencies using sequence IDs (`1`, `1.1`, `1.2`) and include priority for each task.
8. Add `Next Steps` and initialize `Change Log`.

## Progressive Disclosure Rules

- Always include: `Goal`, `Scope`, `Requirements`, `Success Criteria`, `Overall Priority`, `Initial Task Candidates`, `Next Steps`.
- Include only when needed: `Chosen Direction`, `Alternatives Considered`, `Key Decisions`, `Open Questions`.
- Keep implementation detail out of intake spec (libraries/endpoints/schema details belong in planning).

## Plan Path Selection (Required)

Select `plan_mode` in the spec metadata:

- `lightweight` when all are true:
  - Change is small (typically <= 3 tasks and <= 3 files)
  - No schema migration, auth change, security boundary change, or public API contract break
  - Overall risk is not `critical`
  - Verification can be covered by a short targeted test set
- `execution` for all other work

Write `plan_mode: <lightweight|execution>` in `docs/specs/<slug>.md`.

Set `spike_recommended: yes` if the fuzzy-idea loop concludes a spike is needed, otherwise `spike_recommended: no`.

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
- Goal is explicit
- Scope includes explicit boundaries
- Requirements table exists with stable requirement IDs (`R1+`)
- Success criteria are measurable
- Next steps are explicit
- Priority assigned
- `plan_mode` is assigned (`lightweight` or `execution`)
- `spike_recommended` is assigned (`yes` or `no`)
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-plan` (or `Next step: he-spike` if a spike is recommended).
