---
name: he-help
description: Explain the harness workflow, detect current phase, and recommend the next command/skill.
argument-hint: "[optional: slug, phase, or question]"
---

Act as the harness workflow guide for this repository.

Use `$ARGUMENTS` (if provided) as extra context, but always inspect the current repo state first.

## What to do

1. Determine current state:
- Check if workflow scaffolding exists (`docs/specs`, `docs/plans/active`, `docs/plans/completed`, `docs/generated`).
- Check for active plans in `docs/plans/active/`.
- If active plans exist, read each plan `## Progress` and identify the first incomplete item.
- If no active plan exists, identify whether a spec exists for the requested slug/context.

2. Explain the workflow clearly:
- Show the canonical phase path:
  `he-spec -> he-research (optional) -> he-spike (optional) -> he-plan -> he-worktree (recommended) -> he-implement -> he-review -> he-verify-release -> he-learn`
- Call out when `he-workflow` is preferable as an orchestrator.
- Mention that `he-bootstrap` is required if docs/workflow structure is missing.

3. Recommend exact next action:
- Give one recommended next command/skill and why.
- Give up to 2 alternatives when there are meaningful tradeoffs.
- Include copy-paste command examples when useful.

4. Keep output concise and actionable:
- Use these sections in order:
  - `Current State`
  - `Where You Are In The Workflow`
  - `Recommended Next Step`
  - `Alternative Paths`

## Decision rules

- Missing docs structure: recommend `he-bootstrap`.
- No spec for the initiative: recommend `he-spec`.
- Spec exists but no plan: recommend `he-plan`.
- Active plan with incomplete progress: recommend `he-implement` unless review/release gates are due.
- Implementation done but quality gate not run: recommend `he-review`.
- Review complete and non-trivial plan: recommend `he-verify-release`.
- Verify complete/GO: recommend `he-learn`.

Never suggest skipping mandatory gates unless `plan_mode: trivial` explicitly allows the abbreviated path.
