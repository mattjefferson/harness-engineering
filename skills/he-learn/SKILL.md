---
name: he-learn
description: Captures post-release learning, updates debt and quality guidance, and archives active plans to completed for future reuse.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Learn

Turn execution outcomes into durable improvements.

## Inputs

- `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- implementation/review/verify outcomes plus generated context updates (if any)
- incident or friction notes (if any)

## Required Outputs

1. Update `docs/plans/tech-debt-tracker.md` with:
   - issue pattern
   - impact
   - prevention action
   - priority
   - lesson_applied status (`pending|applied`)
2. Update relevant quality domain docs if policy changed:
   - `docs/QUALITY_SCORE.md`
   - `docs/SECURITY.md`
   - `docs/RELIABILITY.md`
   - `docs/PRODUCT_SENSE.md`
   - `docs/DESIGN.md`
   - `docs/FRONTEND.md`
3. Move plan to:
   - `docs/plans/completed/<slug>.md`

## Subagent Usage

Use subagents to gather learning inputs in parallel — e.g., one subagent to analyze review findings and recurring patterns, another to scan implementation friction points from the Progress Log. Feed consolidated results into the compound learning loop in the main thread.

## Compound Learning Loop

For each learning captured, explicitly evaluate:

1. **AGENTS.md update**: Should this pattern update the project's AGENTS.md? (e.g., new convention, workflow adjustment)
2. **Golden principle**: Should this become a golden principle in AGENTS.md? (e.g., a recurring code quality issue that should be enforced during review)
3. **Guardrail promotion**: Should this become a lint rule, test, or structural check? (already partially supported — formalize the decision)
4. **Lesson tracking**: Record `lesson_applied` status in `docs/plans/tech-debt-tracker.md` to track whether the learning has been durably encoded.

## Learning Template

Use `templates/learning-entry-template.md`.

## Exit Gate

- At least one concrete prevention action is captured for each meaningful issue
- Each learning is evaluated against the compound learning loop (AGENTS.md, golden principle, guardrail)
- Active plan is archived to completed
- Docs commit gate passes

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-doc-gardening` (or `he-intake` for the next initiative).
