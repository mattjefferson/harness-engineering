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
- The intake spec recommends a spike (fuzzy-idea loop outcome)
- Risk is high enough that building a throwaway prototype is cheaper than guessing wrong

## Inputs

- `docs/specs/<slug>.md` (the spec that triggered the spike)
- Specific questions to answer or hypotheses to validate

## Spike Contract

1. Define a clear question or hypothesis to validate.
2. Set a time box (default: 2 hours of focused work).
3. Build the minimum throwaway prototype or investigation needed.
4. Document findings — not the prototype code.
5. Spike code is disposable and must not be merged into the main codebase.

When comparing multiple approaches, **launch one subagent per approach** to explore them concurrently. Each subagent prototypes or researches one option and returns findings. This maximizes coverage within the time box.

## Output

- `docs/spikes/<slug>-spike.md` with:
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

Use the spike template when creating the doc:

- `templates/spike-template.md` (includes required YAML frontmatter)

## Exit Gate

- Spike findings document exists at `docs/spikes/<slug>-spike.md`
- Validation goal is answered or explicitly marked as still-unknown with next steps
- Recommendation is actionable (feeds directly into planning)
- Docs commit gate passes

## Transition

Default next phase is `he-plan`.
