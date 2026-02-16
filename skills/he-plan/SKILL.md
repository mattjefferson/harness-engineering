---
name: he-plan
description: Produces a PLANS.md-compliant executable plan from a spec. Use after intake.
argument-hint: "[slug or docs/specs/<slug>-spec.md]"
---

# HE Plan

Convert a spec into a self-contained, novice-guiding execution plan.

## When to Use

- After `he-spec` (and optionally `he-research`/`he-spike`) when the initiative is ready for planning
- When an existing plan needs revision after re-entry from review or verify-release

## Key Principles

1. **`docs/PLANS.md` is law** — follow it literally.
2. **Self-contained plan** — a novice can implement from the plan alone.
3. **Observable outcomes** — every milestone has proof commands and behavior-level acceptance.
4. **Progress is the only checklist** — narrative sections stay prose-first; living sections stay current.
5. **Populate missing policy** — ensure relevant domain docs exist and are updated when context is available.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-plan`), but never waive/override anything codified here.
7. **One question at a time** — ask a single focused question per turn. User can say "proceed" to accept recommendations.
8. **User chooses depth** — after confirming approach, ask what detail level: MINIMAL / MORE / A LOT. Overrides agent-classified `plan_mode` for prose depth.
9. **No code** — he-plan is a planning phase. Do not write, generate, or suggest code. Describe *what* to build and *where*, not the code itself. Implementation belongs in he-implement.

## Workflow

### Phase 0: Gather Context

1. Read `docs/specs/<slug>-spec.md`. If invoked with an external document (file path, pasted content) instead of a `docs/specs/<slug>-spec.md` reference:
   a. Read the external document and extract: purpose, requirements, constraints, tech decisions, open questions.
   b. If the external doc is rich enough to plan from (has clear requirements + success criteria), proceed directly — don't force the user through he-spec first.
   c. If the external doc has significant gaps, offer two paths: (a) run he-spec to normalize it first, or (b) fill gaps inline via Phase 0.5 questions and proceed.
   d. Either way, the plan references the original external doc in its Context and Orientation section alongside any normalized spec.
2. Read `docs/spikes/<slug>-spike.md` (if a spike was run — fold findings directly into the plan).
3. Use subagents to gather implementation context in parallel for independent codebase areas (e.g., data, API, UI, infra).
4. Run `bash scripts/runbooks/select-runbooks.sh --skill he-plan` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 0.5: Idea Refinement (conditional)

When no spec exists or the spec is thin, ask focused questions ONE AT A TIME until approach is clear or user says "proceed." If questioning reveals significant ambiguity, recommend returning to he-spec.

### Phase 1: Confirm Approach with User

**Stop and confirm with the user before proceeding.** Present and confirm ONE AT A TIME — not as a single wall of text.

#### Phase 1a: Spec Alignment Check

Verify codebase matches spec assumptions. If divergence found (spec references nonexistent module, API works differently), stop and surface: "The spec assumes X, but the codebase actually Y. How should we handle this?"

#### Phase 1b: Iterative Approach Confirmation

Present and confirm each item ONE AT A TIME:

1. **Tech stack** — state what the codebase already uses and confirm ("The repo uses X/Y/Z — I'll use those") rather than asking open-ended tech questions. Only ask when the initiative introduces dependencies or patterns not already in the repo.
2. **Architecture approach** — high-level shape of the solution (e.g., new service vs. extending existing, database changes, API surface). State recommendation and ask if user agrees.
3. **Milestone outline** — proposed milestones with one-line descriptions.
4. **Open questions** — anything ambiguous in the spec that affects the plan.

For each item, state your recommendation and ask if user agrees. Escape hatch: "proceed" or "looks good" accepts current state and skips remaining items.

If running autonomously with no interactive tool available, log the proposed approach in `Decision Log` with an `Awaiting confirmation` note and pause.

#### Phase 1c: Detail Level Choice

Ask: "How much detail do you want in the plan?"
- **MINIMAL** — key milestones + commands only
- **MORE** — standard (default)
- **A LOT** — deep guidance, extensive context, step-by-step

### Phase 2: Domain Doc Check

- Check `docs/DOMAIN_DOCS.md` for domain docs relevant to this initiative.
- If a relevant domain doc doesn't exist yet, create it with real content using auto-detect signals and planning context.
- If it exists but is still a stub, populate it.

### Phase 3: Draft the Plan

1. Read `docs/PLANS.md` in full before writing.
2. Keep the plan fully self-contained for a novice with only this repo and the single plan file.
3. In a Markdown file that only contains the plan, omit outer fenced code blocks.
4. Use plain language and define repository-specific terms where they appear.
5. Keep narrative sections prose-first; avoid tables and long enumerations unless clarity requires them.
6. Use checklists only in `## Progress` (required).
7. Include all required sections from `docs/PLANS.md`:
   - `Purpose / Big Picture`, `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, `Context and Orientation`, `Milestones`, `Plan of Work`, `Concrete Steps`, `Validation and Acceptance`, `Idempotence and Recovery`, `Artifacts and Notes`, `Interfaces and Dependencies`, `Pull Request`, `Review Findings`, `Verify/Release Decision`, `Revision Notes`
8. Keep the plan as a living document: update `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, and `Revision Notes` as work evolves.
9. Every `Progress` checkbox entry must include a timestamp and a stable progress ID (`P1`, `P2`, ...).
10. Milestones must be narrative and independently verifiable, each with observable outcomes.
11. Provide concrete file paths, commands, and expected outputs in `Plan of Work`, `Concrete Steps`, and `Validation and Acceptance`.
12. Include safe retry/rollback instructions in `Idempotence and Recovery`.
13. Include concise evidence snippets in `Artifacts and Notes` as work progresses.
14. Add a revision note at the bottom of the plan whenever the plan is revised.

### Phase 3.5: Review Loop

After drafting the plan, run an interactive review loop before tuning depth:

1. Commit the initial draft: `git add docs/plans/active/<slug>-plan.md && git commit -m "docs(plan): <slug> draft"`
2. Summarize plan in 3–5 bullet points covering key decisions and milestone structure.
3. Ask: "Review the plan. What would you change?"
4. If changes requested: revise, append revision note, commit (`docs(plan): <slug> revision — <what changed>`), show diff (`git diff HEAD~1 -- docs/plans/active/<slug>-plan.md`).
5. **Recommendation logic**:
   - Critical/High severity issues found and fixed → recommend another review round
   - Medium/Low only → fix and recommend proceeding to implement
   - After 3+ review rounds → recommend proceeding: "We've refined this well; further improvement will come from implementation feedback"
6. Repeat until user approves or accepts recommendation to proceed. Each round = one commit.

### Phase 4: Tune Depth by Plan Mode

Combine `plan_mode` (structural completeness from spec) with user's `detail_level` choice (prose depth from Phase 1c):

- **`plan_mode` controls structure**: `trivial` = abbreviated plan, `lightweight` = fewer milestones, `execution` = full depth. All modes include every required section.
- **`detail_level` controls prose**: `minimal` = terse, `more` = standard, `a_lot` = exhaustive context and step-by-step guidance.

For example, `execution` + `minimal` = full milestone structure but concise prose. `lightweight` + `a_lot` = fewer milestones but deeply explained.

## Source of Truth

- `docs/PLANS.md` is the instruction contract.
- Follow it literally when creating and revising plans.
- Do not modify `docs/PLANS.md` while running `he-plan`.

## Plan Template

Use `templates/plan-template.md`.

## Output

- `docs/plans/active/<slug>-plan.md`

## Exit Gate

- Plan exists at `docs/plans/active/<slug>-plan.md`
- Plan includes every required PLANS section
- `Progress` contains timestamped checklist entries with stable progress IDs
- Milestones describe observable outcomes and verification
- Concrete commands and expected behavior are documented
- `Decision Log`, `Surprises & Discoveries`, `Outcomes & Retrospective`, and `Revision Notes` are initialized
- Domain docs relevant to this initiative exist and have real content (not stubs)
- Docs commit gate passes
- **User has explicitly approved the final plan** before any transition

## When Things Go Wrong

- **Spec is too vague to plan from** — return to `he-spec` or `he-research` for clarification rather than guessing.
- **Plan exceeds reasonable scope** — split into multiple milestones or recommend splitting the initiative.
- **Missing domain docs block understanding** — create them with available context; don't wait for perfect information.
- **Spike findings contradict the spec** — update the spec first, then plan from the corrected spec.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Planning without reading `docs/PLANS.md` | Always read PLANS.md in full before drafting |
| Vague milestones ("implement the feature") | Observable outcomes with proof commands |
| Checklists outside `## Progress` | Narrative prose for non-progress sections |
| Implementation-light plan that a novice can't follow | Concrete file paths, commands, expected outputs |
| Skipping domain doc check | Create/populate domain docs when context is available |

## Transition Points

After the review loop, **present the plan to the user for final approval**. Use `AskUserQuestion` (or equivalent) to offer:

1. Approve and continue to `he-implement` (recommended)
2. Deepen a specific section (ask which, revise just that section)
3. Run a technical review (re-examine for gaps, risks, edge cases)
4. Request changes (return to Phase 3.5)
5. Handoff/pause with status and explicit next action

**Do not transition out of `he-plan` without explicit user approval of the final plan.** If the user requests changes, revise and re-present until approved.

If running autonomously with no interactive tool available, log the plan as `Awaiting user approval` in `Decision Log` and pause. Do not proceed to implementation.
