---
name: he-spike
description: Runs a time-boxed investigation or throwaway prototype to validate feasibility, reduce ambiguity, or compare approaches before planning. Use between spec and plan when the path forward is unclear.
argument-hint: "[slug or docs/specs/<slug>.md]"
---

# HE Spike

Run a focused, time-boxed investigation to reduce uncertainty before planning.

## When to Use

- Feasibility is uncertain (new technology, unfamiliar API, unclear constraints)
- Multiple valid approaches exist and the tradeoffs aren't clear without hands-on exploration
- The spec recommends a spike (`spike_recommended: yes`)
- Risk is high enough that building a throwaway prototype is cheaper than guessing wrong

## Key Principles

1. **Validate, do not implement** — the spike answers a question, not ships a feature.
2. **Timebox** — stop when the goal is met or time expires (default: 2 hours).
3. **Throwaway code, durable doc** — prototype can be deleted; findings persist in the spike artifact.
4. **Parallel approaches** — one subagent per approach when comparing options.
5. **Decide the next action** — update spec/plan direction based on findings.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-spike`), but never waive/override anything codified here.

## Workflow

### Phase 0: Load Inputs

- Read `docs/specs/<slug>.md` (the spec that triggered the spike).
- Gather specific questions to answer or hypotheses to validate.

### Phase 1: Define the Spike

1. Define a clear question or hypothesis to validate.
2. Set a time box (default: 2 hours of focused work).

### Phase 2: Investigate

1. Build the minimum throwaway prototype or investigation needed.
2. When comparing multiple approaches, **launch one subagent per approach** to explore them concurrently. Each subagent prototypes or researches one option and returns findings.
3. Spike code is disposable and must not be merged into the main codebase.

### Phase 3: Document and Finish

1. Document findings — not the prototype code.
2. If spike findings change scope/requirements/direction, update `docs/specs/<slug>.md` in the same pass using `references/spec-update-guide.md`.

## Output

`docs/spikes/<slug>-spike.md` with:

- **Context**: Why the spike exists and what uncertainty is being reduced
- **Validation Goal**: What understanding the spike must produce
- **Approach**: What we built or investigated
- **Progress**: Temporary in-progress notes (remove at finalization)
- **Findings**: What we learned (with evidence)
- **Decisions**: Decisions and rationale based on findings
- **Recommendation**: Which path to take and why
- **Impact on Upstream Docs**: Required spec/plan updates
- **Spike Code**: Prototype/worktree/branch artifact references
- **Remaining unknowns**: What we still don't know
- **Time spent**: Actual vs. budgeted
- **Revision Notes**: Append-only changes to the spike doc

Use `templates/spike-template.md` (includes required YAML frontmatter).
Use `references/spec-update-guide.md` for exact mapping when updating `docs/specs/<slug>.md` from spike findings.

## Exit Gate

- Spike findings document exists at `docs/spikes/<slug>-spike.md`
- Validation goal is answered or explicitly marked as still-unknown with next steps
- Recommendation is actionable (feeds directly into planning)
- `Impact on Upstream Docs` clearly states whether `docs/specs/<slug>.md` was updated and why
- Docs commit gate passes

## When Things Go Wrong

- **Time box expires with no clear answer** — document what was learned, mark validation goal as partially-answered, and carry remaining unknowns forward.
- **Prototype reveals the approach is infeasible** — that is a valid finding. Document why and recommend alternatives.
- **Spike scope creeps into implementation** — stop. The spike answers a question; it does not ship code. Delete excess and refocus.
- **All approaches fail** — escalate with an escalation packet (evidence, risk, options) rather than guessing.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Merging spike code into main | Spike code is disposable; rewrite cleanly during implement |
| Skipping documentation because "it's just a spike" | Findings are the deliverable, not the code |
| Running a spike when research would suffice | Use `he-research` for questions answerable through investigation |
| Open-ended exploration without a hypothesis | Define a clear question before starting |
| Letting the time box silently expand | Stop at the boundary; extend only with explicit decision |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-plan` (recommended)
2. Run one more build-feedback round in `he-spike`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-plan` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
