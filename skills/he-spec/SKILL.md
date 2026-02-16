---
name: he-spec
description: Converts fuzzy requests into a concrete initiative spec in docs/specs using a single slug and measurable success criteria. Use at the start of non-trivial work.
argument-hint: "[initiative description]"
---

# HE Spec

Create a decision-ready spec artifact for a new initiative.
Question format requirements: `references/intake-question-contract.md`.

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
7. **One question at a time** — ask a single focused question per turn. Never batch. User can say "proceed" at any point to skip remaining questions.
8. **Choice-first by default** — use `request_user_input` for every material decision with 2-3 mutually exclusive options.
9. **Always recommend** — make the recommended option first and suffix it with `(Recommended)` including a one-sentence tradeoff.
10. **Handle vague input explicitly** — if an answer is ambiguous (for example, "AI"), ask one disambiguation follow-up with options before moving on.
11. **No code** — he-spec is a discovery and intent-capture phase. Do not write, generate, or suggest code. Implementation belongs in he-plan and he-implement.

## Workflow

### Phase 0: Understand the Request

**Run subagents and runbooks first** — before any user interaction:
1. Use subagents to research the codebase in parallel — e.g., one to find relevant files and existing patterns, another to check for related specs or prior work in `docs/specs/` and `docs/plans/completed/`.
2. Run `bash scripts/runbooks/select-runbooks.sh --skill he-spec` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

#### Phase 0-pre: Detect External Input

If the user provides an existing spec, PRD, requirements document, or reference artifacts (file path, pasted content, or URL), treat them as the starting point instead of a blank slate:

**External specs/PRDs:**
1. Read/parse the external document.
2. Map its content onto our spec template sections (Purpose, Scope, Requirements, etc.).
3. Identify gaps — which sections from our template are missing or underspecified in the external doc.
4. Present the mapping summary: "Here's what I found in your doc and what's missing: [list gaps]."
5. Use the gap list to drive Phase 0c questions (only ask about what's missing, not what's already covered).
6. Write the normalized spec, preserving the user's intent and wording where possible.

This means he-spec works as both a creator (from scratch) and an adapter (from external input). The output is always our standard `docs/specs/<slug>-spec.md` format.

**Reference artifacts** — Users may provide supporting materials at any point during spec creation: UI mockups/screenshots, links to other repos, API docs, design files, architecture diagrams, etc. When provided:
1. Copy files into `docs/specs/artifacts/<slug>/` (create dir if needed). For URLs, save the URL reference rather than downloading.
2. Reference them in the spec using relative links: `![UI mockup](artifacts/<slug>/mockup.png)`
3. Extract relevant details from the artifacts into the appropriate spec sections (e.g., UI screenshots inform scope and requirements, external repo links inform constraints/dependencies).
4. Ask the user what aspects of the artifact matter: "What should I take from this screenshot — the layout, the data shown, or both?"

If artifacts arrive mid-conversation (during Phase 0b/0c or Phase 2.5 review), handle them the same way — capture, reference, and fold into the spec.

#### Phase 0a: Assess Clarity

If the request is already detailed (clear requirements, success criteria, scope), offer to skip exploration: "Your request is clear enough to draft directly. Want to proceed or explore further?" Prevents forcing a dialogue loop on users who know exactly what they want.

#### Phase 0b: Explore with Focused Questions (Fuzzy-Idea Loop)

Ask questions ONE AT A TIME, starting with highest-uncertainty areas. Each question must follow the intake contract in `references/intake-question-contract.md`:

1. Use `request_user_input` for material decisions.
2. Ask one decision per turn.
3. Provide 2-3 mutually exclusive options with the recommended option first.
4. Include one-sentence tradeoff text for each option.
5. Let users provide a custom answer via the interactive tool's free-text path when needed.

After 2-3 mapping questions, present 2-3 broad directions with tradeoffs (lead with recommendation). User picks direction or says "proceed" to accept recommendation.

Escape hatch: "proceed" / "just do it" / "move on" stops questions; remaining uncertainties become Open Questions in the spec.

#### Phase 0c: Deep Exploration in Chosen Direction

Targeted follow-up questions ONE AT A TIME. **Only ask what the codebase can't answer.** Subagents from Phase 0 already explored the repo — if the stack is evident (languages, frameworks, DB, infra), state what you found and confirm rather than asking from scratch ("This repo uses TypeScript/Next.js/Prisma — I'll plan around that unless you say otherwise"). Only ask tech questions when the initiative introduces something *new to the repo* (new service, new dependency category, new infrastructure).

Also cover: integration points, scale/performance expectations, UX expectations.

**Challenge assumptions**: if the user's approach has a known pitfall or simpler alternative, surface it ("Have you considered X? It might Y.").

Continue until approach is clear OR user says "proceed."

If the user gives a vague response, ask exactly one disambiguation follow-up using the same optionized format. If ambiguity remains after that follow-up, proceed with the recommended default and record the assumption in `Open Questions` as `[decision]`.
Never repeat the exact same question verbatim in the same response or in consecutive turns.

#### Phase 0d: Default Intake Sequence

When starting from a fuzzy idea, use this default sequence unless external input already answers it:

1. Initiative outcome in one sentence (who it helps + what changes).
2. Primary audience for v1.
3. Single most important job-to-be-done in v1.
4. v1 direction choice with explicit tradeoffs.
5. v1 surface and boundaries.

Apply the same interaction contract to each step: one decision per turn, recommendation first, optional custom response, and one disambiguation follow-up when needed.

### Phase 1: Create the Slug

1. **Draft a clear title** using conventional commit format: `feat: Add user authentication`, `fix: Cart total calculation`, `refactor: Extract payment module`.
2. **Convert to slug**: date prefix + type + kebab-cased title (3–5 words):
   - `feat: Add User Authentication` → `2026-02-16-feat-add-user-authentication`
   - `fix: Cart Total Calculation` → `2026-02-16-fix-cart-total-calculation`
   - `refactor: Extract Payment Module` → `2026-02-16-refactor-extract-payment-module`
3. **Use this slug** for all subsequent phase artifacts. The artifact suffix (`-spec`, `-spike`, `-plan`) is appended to filenames automatically — it is not part of the slug itself.

### Phase 2: Write the Spec

Template loading rule before drafting:

- Use `templates/spec-template.md` relative to this skill directory.
- Never assume `templates/spec-template.md` is relative to the repo root.
- Do not pause to "locate" template variants if this skill-local path exists.

1. Define a concise purpose/big-picture statement (problem + target user/outcome).
2. Define scope with `In Scope` and explicit `Boundaries` (deliberate exclusions).
3. Define requirements in a table with stable IDs (`R1`, `R2`, ...) and priorities.
4. Define measurable success criteria.
5. Define constraints (time, risk, compatibility, performance).
6. Classify overall priority (`critical`, `high`, `medium`, `low`).
7. Draft initial milestone candidates (`M1`, `M2`, ...) with observable outcomes and likely risk hotspots.
8. Add `Handoff` and initialize `Revision Notes` (append-only).

### Phase 2.5: Interactive Review

After writing the spec draft, run a review loop before classifying:

1. Commit the initial draft: `git add docs/specs/<slug>-spec.md && git commit -m "docs(spec): <slug> draft"`
2. Summarize spec in 3–5 bullet points highlighting key decisions.
3. Ask: "Review the spec. What would you change? Or say 'looks good' to proceed."
4. If changes requested: revise, append revision note, commit the revision (`docs(spec): <slug> revision — <what changed>`), then show the diff (`git diff HEAD~1 -- docs/specs/<slug>-spec.md`) so the user sees exactly what changed.
5. Repeat until user approves — tight loop, no phase transition. Each round = one commit, so the full revision history is in git.

### Phase 3: Classify and Finalize

1. Select `plan_mode` in spec frontmatter:
   - `trivial` — single-file, no schema/auth/security/API break, low risk, no spike needed. Abbreviated spec: Purpose + single requirement + success criteria only.
   - `lightweight` — small change (≤3 milestones, ≤3 files), no schema/auth/security/API break, risk is not `critical`.
   - `execution` — all other work.
2. Set `spike_recommended: yes|no` based on fuzzy-idea loop outcome.

## Progressive Disclosure Rules

- **Always include**: Purpose / Big Picture, Scope, Non-Goals, Risks, Rollout, Validation and Acceptance Signals, Requirements, Success Criteria, Priority, Initial Milestone Candidates, Handoff.
- **Include only when needed**: Chosen Direction, Alternatives Considered, Key Decisions, Open Questions, Tech Preferences, Reference Artifacts.
- Keep implementation detail out of intake spec (libraries/endpoints/schema details belong in planning).
- **Classify open questions** by type to drive routing at transition:
  - `[research]` — answerable through investigation (route to `he-research`)
  - `[spike]` — needs hands-on exploration (route to `he-spike`)
  - `[decision]` — requires human call (surface to user)
  - `[planning]` — resolve during `he-plan`

## Spec Template

Use `templates/spec-template.md` from this skill directory (not repo root).

## Output

- `docs/specs/<slug>-spec.md`

## Exit Gate

- Spec exists at `docs/specs/<slug>-spec.md`
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

1. Continue to next phase — route based on open question types and `spike_recommended`: `he-research` when `[research]` questions remain, `he-spike` when `spike_recommended: yes`, otherwise `he-plan` (for `plan_mode: trivial`, use an abbreviated plan and continue to implement) (Recommended)
2. Review the spec again (return to Phase 2.5)
3. Ask more questions (return to Phase 0c for deeper exploration)
4. Handoff/pause with status and explicit next action
5. Done for now (spec is parked, no immediate next step)

Transition options must follow the same recommendation convention: recommended option first, concise tradeoff on every option, and one transition decision per turn.

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
