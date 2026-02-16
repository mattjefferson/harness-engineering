---
name: he-spec
description: Converts fuzzy requests into a concrete initiative spec in docs/specs using a single slug and measurable success criteria. Use at the start of non-trivial work.
argument-hint: "[initiative description]"
---

# HE Spec

Create a decision-ready spec artifact for a new initiative.

## When to Use

- Starting any non-trivial work (new feature, significant change, multi-file refactor)
- When a user request needs to be formalized into requirements and success criteria
- When initiative direction is fuzzy and needs to be crystallized before planning

## Key Principles

1. **Intent only** — define what/why/success; avoid implementation details.
2. **Single slug** — one initiative = one slug across spec/spike/plan artifacts.
3. **Concrete success** — requirements and success criteria must be testable/observable.
4. **Route unknowns** — investigatable questions go to `he-research`; experience-dependent unknowns go to `he-spike`.
5. **No fake certainty** — capture ambiguity explicitly instead of guessing.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-spec`), but never waive/override anything codified here.

## Workflow

### Phase 0: Understand the Request

1. If request is unclear, run the Fuzzy-Idea Loop:
   - Capture intended outcome in one sentence.
   - Offer 2–3 possible approaches with tradeoffs.
   - Pick a default approach and list assumptions.
   - If still ambiguous, recommend `he-spike` before planning.
2. Use subagents to research the codebase in parallel — e.g., one to find relevant files and existing patterns, another to check for related specs or prior work in `docs/specs/` and `docs/plans/completed/`.

### Phase 1: Create the Slug

- Format: `YYYY-MM-DD-kebab-topic`
- Use this slug for all subsequent phase artifacts.

### Phase 2: Write the Spec

1. Define a concise purpose/big-picture statement (problem + target user/outcome).
2. Define scope with `In Scope` and explicit `Boundaries` (deliberate exclusions).
3. Define requirements in a table with stable IDs (`R1`, `R2`, ...) and priorities.
4. Define measurable success criteria.
5. Define constraints (time, risk, compatibility, performance).
6. Classify overall priority (`critical`, `high`, `medium`, `low`).
7. Draft initial milestone candidates (`M1`, `M2`, ...) with observable outcomes and likely risk hotspots.
8. Add `Handoff` and initialize `Revision Notes` (append-only).

### Phase 3: Classify and Finalize

1. Select `plan_mode` in spec frontmatter:
   - `trivial` — single-file, no schema/auth/security/API break, low risk, no spike needed. Abbreviated spec: Purpose + single requirement + success criteria only.
   - `lightweight` — small change (≤3 milestones, ≤3 files), no schema/auth/security/API break, risk is not `critical`.
   - `execution` — all other work.
2. Set `spike_recommended: yes|no` based on fuzzy-idea loop outcome.

## Progressive Disclosure Rules

- **Always include**: Purpose / Big Picture, Scope, Non-Goals, Risks, Rollout, Validation and Acceptance Signals, Requirements, Success Criteria, Priority, Initial Milestone Candidates, Handoff.
- **Include only when needed**: Chosen Direction, Alternatives Considered, Key Decisions, Open Questions.
- Keep implementation detail out of intake spec (libraries/endpoints/schema details belong in planning).

## Spec Template

Use `templates/spec-template.md`.

## Output

- `docs/specs/<slug>.md`

## Exit Gate

- Spec exists at `docs/specs/<slug>.md`
- Purpose / Big Picture is explicit
- Scope includes explicit boundaries
- Requirements table exists with stable requirement IDs (`R1+`)
- Success criteria are measurable
- Handoff is explicit
- Priority assigned
- `plan_mode` is assigned (`trivial`, `lightweight`, or `execution`)
- `spike_recommended` is assigned (`yes` or `no`)
- Docs commit gate passes

## When Things Go Wrong

- **Request remains ambiguous after fuzzy-idea loop** — recommend `he-spike` to build clarity through exploration.
- **Scope keeps expanding during intake** — draw explicit boundaries, move additions to a follow-up initiative.
- **Cannot define measurable success criteria** — this usually means the problem isn't well-understood yet; route to `he-research`.
- **Stakeholder disagrees with priority or scope** — capture the disagreement explicitly and escalate with options.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Including implementation details in the spec | Spec is intent; implementation belongs in `he-plan` |
| Creating multiple slugs for one initiative | One slug across all artifacts |
| Vague success criteria ("it works") | Testable/observable criteria with concrete signals |
| Skipping boundaries/non-goals | Explicit exclusions prevent scope creep |
| Guessing when uncertain | Capture ambiguity explicitly; route to research or spike |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-research` when meaningful open questions remain; otherwise continue to `he-plan` (or `he-spike` when `spike_recommended: yes`; for `plan_mode: trivial`, use an abbreviated plan and continue to implement) (recommended)
2. Run one more build-feedback round in `he-spec`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
