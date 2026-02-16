---
name: he-research
description: Investigates open questions before planning by running parallel research across docs, codebase patterns, and external references, then updates initiative artifacts with evidence-backed findings.
argument-hint: "[slug, docs/specs/<slug>.md, or question set]"
---

# HE Research

Resolve investigatable unknowns before implementation planning.

Use this skill when answers are discoverable through research. For unknowns that must be built and experienced, use `he-spike` instead.

## When to Use

- After `he-spec` when initiative direction still has open questions
- Before `he-plan` when requirements or constraints are unclear
- Standalone when the user asks to research specific questions
- During re-entry when review or verify finds unresolved context gaps

## Key Principles

1. **Categorize first** — only research questions where the answer can be found.
2. **Evidence-backed** — record confidence and source notes; separate fact from inference.
3. **Update the source of truth** — write findings into `docs/specs/<slug>.md` with revision notes.
4. **Prefer primary sources** — repo evidence and official docs beat summaries.
5. **Do not plan here** — research clarifies constraints; planning is `he-plan`.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-research`), but never waive/override anything codified here.

## Workflow

### Phase 0: Gather Questions

1. Read `docs/specs/<slug>.md` (preferred) or direct question list from user.
2. Optionally pull context from `docs/plans/completed/`, `docs/spikes/`, `docs/generated/`.
3. Run `bash scripts/runbooks/select-runbooks.sh --skill he-research` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Categorize

Classify each question before investigation:

1. Scope/requirements question
2. External constraints or prior-art question
3. Codebase pattern or compatibility question
4. Needs spike (behavior/UX must be experienced)
5. User decision required (cannot be researched)

Category outcomes:

- 1–3: investigate now
- 4: redirect to `he-spike`
- 5: surface decision explicitly to user

### Phase 2: Investigate in Parallel

1. Launch one subagent per investigatable question (categories 1–3).
2. Each subagent returns:
   - finding summary
   - confidence level (`high|medium|low`)
   - evidence/source notes
   - impact on scope/requirements/risk
3. Synthesize findings into a single recommendation set.

### Phase 3: Update Artifacts

1. Update `docs/specs/<slug>.md`:
   - Move answered questions out of open state.
   - Update `Requirements`, `Risks`, `Constraints`, or `Boundaries` as needed.
   - Append `Revision Notes` describing what changed and why.
2. Keep unresolved items explicit with next action.

## Update Contract for Specs

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

## Output

- Research findings embedded in `docs/specs/<slug>.md` (when spec exists), or
- A standalone research summary in `docs/specs/<slug>.md` for new initiative intake

## Exit Gate

- Each investigatable question has a finding or explicit unresolved status
- Spec updates (if any) are applied and summarized in `Revision Notes`
- Follow-up actions are explicit for spike-required or user-decision items
- Docs commit gate passes

## When Things Go Wrong

- **No useful evidence found** — mark question unresolved and carry it forward with explicit next action.
- **All questions require spike** — stop research and transition to `he-spike`.
- **All questions require user decisions** — present a concise decision list and stop.
- **Conflicting evidence across sources** — record both sides with confidence levels; do not pick a winner without evidence.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Guessing when evidence is thin | Mark as unresolved with confidence level |
| Researching questions that need hands-on exploration | Redirect to `he-spike` for experience-dependent unknowns |
| Adding implementation details to the spec | Keep implementation in `he-plan`; spec is intent only |
| Treating inference as fact | Always distinguish and label confidence explicitly |
| Researching in the main thread instead of parallel | Launch one subagent per question for concurrent investigation |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-plan` (recommended when sufficient clarity)
2. Continue to `he-spike` for experience-dependent unknowns
3. Run one more research round on remaining questions

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in the relevant artifact's `Revision Notes`.
