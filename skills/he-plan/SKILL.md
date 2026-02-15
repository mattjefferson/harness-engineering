---
name: he-plan
description: Produces a PLANS.md-compliant executable plan from a spec. Use after intake.
argument-hint: "[slug or docs/specs/<slug>.md]"
---

# HE Plan

Convert a spec into a self-contained, novice-guiding execution plan.

## Key Principles

1. `docs/PLANS.md` is law: follow it literally.
2. Self-contained plan: a novice can implement from the plan alone.
3. Observable outcomes: every milestone has proof commands and behavior-level acceptance.
4. Progress is the only checklist: narrative sections stay prose-first; living sections stay current.
5. Populate missing policy: ensure relevant domain docs exist and are updated when context is available.
6. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in this skill.

## Inputs

- `docs/specs/<slug>.md`
- `docs/spikes/<slug>-spike.md` (if a spike was run — fold findings directly into the plan)

## Output

- `docs/plans/active/<slug>.md`

## Source of Truth

- `docs/PLANS.md` is the instruction contract.
- Follow it literally when creating and revising plans.
- Do not modify `docs/PLANS.md` while running `he-plan`.

## Subagent Usage

Use subagents to gather implementation context before drafting the plan. Run parallel subagents for independent codebase areas (for example data, API, UI, infra), then synthesize findings into one coherent plan in the main thread.

## Domain Doc Check

Before drafting the plan, check `docs/DOMAIN_DOCS.md` for domain docs relevant to this initiative. If a relevant domain doc doesn't exist yet, create it with real content using auto-detect signals and planning context. If it exists but is still a stub, populate it. Domain docs are created on-demand — this is often the first skill that has enough context to write them.

## Planning Requirements

1. Read `docs/PLANS.md` in full before writing.
2. Keep the plan fully self-contained for a novice with only this repo and the single plan file.
3. In a Markdown file that only contains the plan, omit outer fenced code blocks.
4. Use plain language and define repository-specific terms where they appear.
5. Keep narrative sections prose-first; avoid tables and long enumerations unless clarity requires them.
6. Use checklists only in `## Progress` (required).
7. Include all required sections from `docs/PLANS.md`:
   - `## Purpose / Big Picture`
   - `## Progress`
   - `## Surprises & Discoveries`
   - `## Decision Log`
   - `## Outcomes & Retrospective`
   - `## Context and Orientation`
   - `## Milestones`
   - `## Plan of Work`
   - `## Concrete Steps`
   - `## Validation and Acceptance`
   - `## Idempotence and Recovery`
   - `## Artifacts and Notes`
   - `## Interfaces and Dependencies`
   - `## Revision Notes`
8. Keep the plan as a living document: update `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, and `Revision Notes` as work evolves.
9. Every `Progress` checkbox entry must include a timestamp and a stable progress ID (`P1`, `P2`, ...).
10. Milestones must be narrative and independently verifiable, each with observable outcomes.
11. Provide concrete file paths, commands, and expected outputs in `Plan of Work`, `Concrete Steps`, and `Validation and Acceptance`.
12. Include safe retry/rollback instructions in `Idempotence and Recovery`.
13. Include concise evidence snippets in `Artifacts and Notes` as work progresses.
14. Add a revision note at the bottom of the plan whenever the plan is revised.

## Plan Depth By `plan_mode`

Read `plan_mode` from `docs/specs/<slug>.md` and tune depth, not structure:

- `trivial`: abbreviated plan that still includes all required sections and enables implement/review/learn gates.
- `lightweight`: fewer milestones and shorter prose, but still include every required section.
- `execution`: deeper orientation, milestones, validation detail, and richer decision/evidence updates.

## Plan Template

Use `templates/plan-template.md`.

## Exit Gate

- Plan exists at `docs/plans/active/<slug>.md`
- Plan includes every required PLANS section
- `Progress` contains timestamped checklist entries with stable progress IDs
- Milestones describe observable outcomes and verification
- Concrete commands and expected behavior are documented
- `Decision Log`, `Surprises & Discoveries`, `Outcomes & Retrospective`, and `Revision Notes` are initialized
- Domain docs relevant to this initiative exist and have real content (not stubs)
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-implement` (recommended)
2. Run one more build-feedback round in `he-plan`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-implement` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
