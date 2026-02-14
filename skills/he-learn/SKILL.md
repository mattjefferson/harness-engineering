---
name: he-learn
description: Captures post-release learning, updates debt and quality guidance, and archives active plans to completed for future reuse.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Learn

Turn execution outcomes into durable improvements.

## Inputs

- `docs/plans/active/<slug>.md`
- runtime events and review/verify outcomes
- incident or friction notes (if any)

## Required Outputs

1. Update `docs/plans/tech-debt-tracker.md` with:
   - issue pattern
   - impact
   - prevention action
   - priority
2. Update relevant quality domain docs if policy changed:
   - `docs/QUALITY_SCORE.md`
   - `docs/SECURITY.md`
   - `docs/RELIABILITY.md`
   - `docs/PRODUCT_SENSE.md`
   - `docs/DESIGN.md`
   - `docs/FRONTEND.md`
3. Move plan to:
   - `docs/plans/completed/<slug>.md`

## Learning Template

Use `templates/learning-entry-template.md`.

## Exit Gate

- At least one concrete prevention action is captured for each meaningful issue
- Active plan is archived to completed
- Docs commit gate passes

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-entropy` (or `he-intake` for the next initiative).
- Wait for the user's selection before proceeding to the next phase.
