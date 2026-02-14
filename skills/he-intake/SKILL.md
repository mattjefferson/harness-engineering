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

## Intake Procedure

1. Define the problem statement.
2. Define measurable success criteria.
3. Define constraints (time, risk, compatibility, performance).
4. Define scope and non-goals.
5. Classify overall priority (`critical`, `high`, `medium`, `low`).
6. Draft initial task graph candidates with rough dependencies using sequence IDs (`1`, `1.1`, `1.2`) and include priority for each task.

## Plan Path Selection (Required)

Select `plan_mode` in the spec metadata:

- `lightweight` when all are true:
  - Change is small (typically <= 3 tasks and <= 3 files)
  - No schema migration, auth change, security boundary change, or public API contract break
  - Overall risk is not `critical`
  - Verification can be covered by a short targeted test set
- `execution` for all other work

Write `plan_mode: <lightweight|execution>` in `docs/specs/<slug>.md`.

## Fuzzy-Idea Loop

If request is unclear:

1. Capture intended outcome in one sentence.
2. Offer 2-3 possible approaches with tradeoffs.
3. Pick a default approach and list assumptions.
4. If still ambiguous, propose a short spike task in the spec.

## Spec Template

Use `templates/spec-template.md`.

## Exit Gate

- Spec exists at `docs/specs/<slug>.md`
- Success criteria are measurable
- Scope and non-goals are explicit
- Priority assigned
- `plan_mode` is assigned (`lightweight` or `execution`)
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-plan`.
- Wait for the user's selection before proceeding to the next phase.
