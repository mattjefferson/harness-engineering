---
name: he-learn
description: Captures post-release learning, updates debt and quality guidance, and archives active plans to completed for future reuse.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Learn

Turn execution outcomes into durable improvements.

## Key Principles

1. Convert failures into guardrails: record prevention actions in the tracker.
2. Update durable policy: domain docs and runbooks reflect new learnings.
3. Process the scratchpad: triage and clear `docs/generated/memory.md`.
4. Archive cleanly: move the plan to completed and keep append-only semantics.
5. Promote enforcement: repeated issues should become lint/test/CI guardrails.
6. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in this skill.

## Inputs

- `docs/plans/active/<slug>.md`
- implementation/review/verify outcomes plus generated context updates (if any)
- incident or friction notes (if any)

## Required Outputs

1. Update `docs/plans/tech-debt-tracker.md` with:
   - issue pattern
   - impact
   - prevention action
   - priority
   - lesson_applied status (`pending|applied`)
2. Update relevant domain docs per `docs/DOMAIN_DOCS.md` registry if policy changed.
3. Update or create any affected runbooks in `docs/runbooks/` when learnings change process, checklists, or "how we do it here" guidance.
4. Process `docs/generated/memory.md` (scratchpad inbox):
   - promote keepers to the correct durable location in `docs/` or `docs/runbooks/`
   - delete anything no longer needed
   - clear `docs/generated/memory.md` back to an empty scratchpad (keep the header/sections)
5. Move plan to:
   - `docs/plans/completed/<slug>.md`

## Subagent Usage

Use subagents to gather learning inputs in parallel — for example, one subagent to analyze review findings and recurring patterns, another to scan implementation friction points from the plan `Progress` and `Surprises & Discoveries` sections.

## Compound Learning Loop

For each learning captured, explicitly evaluate:

1. **AGENTS.md update**: Should this pattern update the project's AGENTS.md?
2. **Golden principle**: Should this become a golden principle in AGENTS.md?
3. **Guardrail promotion**: Should this become a lint rule, test, or structural check?
4. **Runbook update**: Should this pattern update a runbook? If yes, update `docs/runbooks/<topic>.md` (or add a new one) and link it from AGENTS.md if it becomes a common workflow.
5. **Lesson tracking**: Record `lesson_applied` status in `docs/plans/tech-debt-tracker.md`.

## Learning Template

Use `templates/learning-entry-template.md`.

## Exit Gate

- At least one concrete prevention action is captured for each meaningful issue
- Each learning is evaluated against the compound learning loop
- Runbooks are updated when process/checklists changed (or explicitly marked "no runbook update needed")
- `docs/generated/memory.md` is processed and cleared (or explicitly marked empty/not present)
- Active plan is archived to completed
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-doc-gardening` (or `he-spec` for the next initiative) (recommended)
2. Run one more build-feedback round in `he-learn`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
