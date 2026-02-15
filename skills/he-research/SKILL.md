---
name: he-research
description: Investigates open questions before planning by running parallel research across docs, codebase patterns, and external references, then updates initiative artifacts with evidence-backed findings.
argument-hint: "[slug, docs/specs/<slug>.md, or question set]"
---

# HE Research

Resolve investigatable unknowns before implementation planning.

Use this skill when answers are discoverable through research. For unknowns that must be built and experienced, use `he-spike` instead.

## Key Principles

1. Categorize first: only research questions where the answer can be found.
2. Evidence-backed: record confidence and source notes; separate fact from inference.
3. Update the source of truth: write findings into `docs/specs/<slug>.md` with revision notes.
4. Prefer primary sources: repo evidence and official docs beat summaries.
5. Do not plan here: research clarifies constraints; planning is `he-plan`.
6. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in this skill.

## When To Use

- After `he-spec` when initiative direction still has open questions
- Before `he-plan` when requirements or constraints are unclear
- Standalone when the user asks to research specific questions
- During re-entry when review or verify finds unresolved context gaps

## Inputs

- `docs/specs/<slug>.md` (preferred), or
- Direct question list from user

Optional supporting context:

- Related completed plans in `docs/plans/completed/`
- Related spike docs in `docs/spikes/`
- Relevant generated docs in `docs/generated/`

## Output

- Research findings embedded in `docs/specs/<slug>.md` (when spec exists), or
- A standalone research summary in `docs/specs/<slug>.md` for new initiative intake

## Research Categories

Classify each question before investigation:

1. Scope/requirements question
2. External constraints or prior-art question
3. Codebase pattern or compatibility question
4. Needs spike (behavior/UX must be experienced)
5. User decision required (cannot be researched)

Category outcomes:

- 1-3: investigate now
- 4: redirect to `he-spike`
- 5: surface decision explicitly to user

## Workflow

1. Gather questions from `Open Questions` (if present) in `docs/specs/<slug>.md`, plus user-provided questions.
2. Categorize each question using the categories above.
3. Launch one subagent per investigatable question (categories 1-3) in parallel.
4. Each subagent returns:
   - finding summary
   - confidence level (`high|medium|low`)
   - evidence/source notes
   - impact on scope/requirements/risk
5. Synthesize findings into a single recommendation set.
6. Update `docs/specs/<slug>.md`:
   - move answered questions out of open state
   - update `Requirements`, `Risks`, `Constraints`, or `Boundaries` as needed
   - append `Revision Notes` describing what changed and why
7. If questions require spike or user decisions, keep them explicit in the spec and mark follow-up action.

## Update Contract For Specs

When a spec exists, keep it as source of truth:

- Add discovered constraints under `## Constraints`
- Add/adjust requirements with stable IDs in `## Requirements`
- Update `## Risks` and `## Scope` boundaries when findings change direction
- Keep unresolved items in `## Open Questions (Optional)` with next action

Do not add implementation-level details that belong in `he-plan`.

## Quality Bar

- Prefer primary sources and concrete repository evidence
- Distinguish fact vs. inference
- Record confidence for each finding
- Keep unresolved unknowns explicit; do not guess

## Failure Handling

- If no useful evidence is found, mark question unresolved and carry it forward
- If all questions require spike, stop and transition to `he-spike`
- If all questions require user decisions, present a concise decision list and stop

## Exit Gate

- Each investigatable question has a finding or explicit unresolved status
- Spec updates (if any) are applied and summarized in `Revision Notes`
- Follow-up actions are explicit for spike-required or user-decision items
- Docs commit gate passes

## Transition

Use an interactive question tool at this transition when available (`request_user_input` in Codex Plan mode, `AskUserQuestion` in Claude Code, or equivalent). Offer:

1. Continue to `he-plan` (recommended when sufficient clarity)
2. Continue to `he-spike` for experience-dependent unknowns
3. Run one more research round on remaining questions

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in the relevant artifact's `Revision Notes`.
