---
name: he-learn
description: Converts post-release outcomes into durable docs and mechanical guardrails, clears generated scratchpads, and archives the initiative plan for reuse.
argument-hint: "[slug or path to a plan file]"
---

# HE Learn

Turn execution outcomes into durable improvements that make the next cycle faster, safer, and more legible.

## When to Use

- After `he-verify-release` when an initiative is complete (GO decision)
- After the final merge or rollout when learnings are fresh and evidence is available
- Any time you want to convert repeat friction into policy, runbooks, and enforcement

## Operating Model

### Core idea

- `docs/` is the system of record for agent-visible project knowledge.
- `AGENTS.md` stays a map (table of contents) that points to `docs/` for depth.
- We enforce structure and invariants, but allow freedom inside those boundaries.

### Guardrails that must hold

1. **Discoverability:** Every durable doc added must be linked from an appropriate index or registry (see Doc Placement Matrix).
2. **No monolith manuals:** Do not turn `AGENTS.md` into a long instruction blob. If content is more than a sentence or two, put it in `docs/` and link to it.
3. **Policy must be durable:** If a learning changes “how we do it here,” update a domain doc and/or a runbook.
4. **Repeat issues become enforcement:** If an issue is meaningful or recurring, add a mechanical guardrail (lint, test, CI check) plus the doc that explains the rule.
5. **Runbooks are additive:** Apply any runbook selected for this skill. Runbooks may add steps, but they must not waive or override gates defined in this skill.
6. **Scratchpad is not storage:** `docs/generated/memory.md` is an inbox only. Promote or delete items, then clear it back to an empty scratchpad structure.
7. **Plans are first-class artifacts:** Finalize the plan’s living sections before archiving. Preserve append-only semantics where specified.

### Freedom the agent has

- Create new docs (domain docs, runbooks, specs, design docs) whenever it improves the next cycle.
- Restructure within `docs/` when it improves legibility, as long as discoverability and links are maintained.
- Choose local formats and implementations inside the guardrails, as long as outcomes are correct and legible.

## Inputs

Primary:
- The initiative plan file (active plan or a provided path)

Secondary:
- PR description and CI results
- Review findings
- Verify/release evidence and post-release checks
- Incident notes and operational friction
- `docs/generated/memory.md` contents

## Doc Placement Matrix

Use this to decide where a learning goes and what must be updated for discoverability.

| Learning type | Durable location | Required discoverability updates |
|---|---|---|
| Project-wide setup, workflow entry points, doc map | `AGENTS.md` (short), plus deeper doc in `docs/` | Link from `AGENTS.md` to the deeper doc |
| Durable policy or constraints in a domain | `docs/<DOMAIN>.md` (e.g. `SECURITY.md`, `RELIABILITY.md`, `DESIGN.md`, `DATA.md`, `OBSERVABILITY.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`) | If a new domain doc is created or registry changes, update `docs/DOMAIN_DOCS.md` |
| “How to do X here” checklists, procedures, operational playbooks | `docs/runbooks/<topic>.md` | Ensure runbook frontmatter includes `called_from` so skills can discover it |
| Architectural or design decision history | `docs/design-docs/<topic>.md` | Update `docs/design-docs/index.md` with a link and short descriptor |
| Product, API, or behavior specification | `docs/specs/<topic>.md` | Update `docs/specs/index.md` with a link and short descriptor |
| Experiment/spike notes | `docs/spikes/<topic>.md` (or follow repo convention) | Update `docs/spikes/README.md` if it serves as the index |
| Temporary notes and raw snippets | `docs/generated/memory.md` only | Must be promoted or deleted during this skill |

## Workflow

### Phase 0: Locate the Plan and Gather Inputs

1. Identify the plan file:
   - If an explicit path is provided, use it.
   - If a slug is provided, look for:
     - `docs/plans/active/<slug>-plan.md`
     - If not found, search under `docs/plans/` for `<slug>` and use the best match.
2. Read the full plan, paying special attention to:
   - `Progress`
   - `Surprises & Discoveries`
   - `Decision Log`
   - `Outcomes & Retrospective`
   - `Review Findings`
   - `Verify/Release Decision`
   - `Revision Notes`
3. Gather evidence from:
   - CI outputs, test logs, release checks, screenshots, run outputs
   - Review and verify artifacts
4. Run runbook selection and load returned runbooks:
   - `bash scripts/runbooks/select-runbooks.sh --skill he-learn`
   - Apply returned runbooks throughout this skill (additive only).

### Phase 1: Convert Outcomes into Learnings

For each meaningful issue, success, or surprise:

1. Write a learning entry using `templates/learning-entry-template.md`.
2. Each learning entry must include:
   - What happened (concise)
   - Evidence (command output, logs, links to PR/CI)
   - Root cause or contributing factors (best effort)
   - Prevention action (at least one concrete action)
   - Doc target (where it will live using the Doc Placement Matrix)
   - Enforcement target (if applicable: test, lint, CI, config)
3. If the prevention is “update documentation,” specify exactly:
   - Which file(s) will change
   - What section(s) will be added/updated
   - What index/registry link must be added so it is discoverable

### Phase 2: Update Durable Artifacts

Execute the learning loop for each learning:

1. **AGENTS map update**
   - Only update `AGENTS.md` when the learning changes:
     - Setup commands
     - Workflow entry points
     - Where to find key docs
     - Escalation rules
   - Keep it TOC-like. Put detailed guidance in `docs/` and link to it.

2. **Golden principles promotion**
   - If a learning is a project invariant that must never be violated, add it to `AGENTS.md` under `## Golden Principles`.
   - Only add principles that can be enforced mechanically. If it cannot be checked, it is guidance and belongs in a domain doc or runbook.

3. **Policy and runbooks**
   - Update the appropriate domain doc when the rule is policy.
   - Update or create a runbook when the rule is process or checklist.
   - For new runbooks:
     - Add frontmatter including `called_from: [he-learn, ...]` or whatever set matches discovery rules.
     - Keep runbooks additive and skill-compatible.

4. **Specs and design docs**
   - If the learning changes a contract or expected behavior, update a spec in `docs/specs/` and update `docs/specs/index.md`.
   - If the learning records an architectural decision or tradeoff, add a design doc and update `docs/design-docs/index.md`.

5. **Mechanical enforcement**
   - If the learning should be enforced, implement the enforcement in code:
     - `scripts/ci/` (or the repo’s enforcement mechanism)
     - relevant config (e.g., `he-docs-config.json` if used by your docs/CI tooling)
   - The doc describes the rule. The code enforces it. Both should exist for repeat issues.

6. **Architecture review**
   - Review `ARCHITECTURE.md` for drift.
   - Update it when learnings change components, boundaries, or cross-cutting concerns.
   - If `ARCHITECTURE.md` does not exist, create a minimal top-level map and link it from `AGENTS.md`.

7. **Tech debt tracker**
   - Update `docs/plans/tech-debt-tracker.md` for:
     - deferred fixes
     - cleanup needed
     - follow-up enforcement work
   - Each entry should link to evidence (plan section, PR, CI run) and include a suggested next action.

### Phase 3: Finalize the Plan for Archival

Before archiving, ensure the plan is a reliable artifact for future reuse:

1. Update `Outcomes & Retrospective` with:
   - Key outcomes
   - Key learnings (link to the learning entries or the updated docs)
   - Remaining gaps and follow-ups (link to tech debt tracker entries)
2. Ensure `Surprises & Discoveries`, `Decision Log`, and `Verify/Release Decision` are complete and evidence-backed.
3. Do not rewrite history:
   - Keep `Revision Notes` append-only.
   - Preserve timestamps and stable IDs in `Progress`.

### Phase 4: Process Scratchpad and Garbage Collect

1. Process `docs/generated/memory.md`:
   - Promote each keeper to a durable doc location (domain doc, runbook, spec, design doc).
   - Delete items that are no longer needed.
   - Clear `docs/generated/memory.md` back to an empty scratchpad structure.
2. Ensure no orphan docs were created:
   - Every new durable doc must be linked from an index or registry as required in the Doc Placement Matrix.

### Phase 5: Archive

1. Ensure the plans directory structure exists:
   - If missing, create:
     - `docs/plans/active/`
     - `docs/plans/completed/`
2. Move the plan:
   - From `docs/plans/active/<slug>-plan.md`
   - To `docs/plans/completed/<slug>-plan.md`
3. If the repo uses a different convention, follow `docs/PLANS.md` as the source of truth and keep the structure consistent and discoverable.

## Output

- Updated domain docs and/or runbooks driven by learnings
- Updated `AGENTS.md` only when navigation or invariants changed
- Updated `docs/plans/tech-debt-tracker.md`
- Processed and cleared `docs/generated/memory.md`
- Archived plan at `docs/plans/completed/<slug>-plan.md` (or per `docs/PLANS.md`)
- Evidence links added to plan and tracker entries

## Exit Gates

- Every meaningful issue has at least one concrete prevention action
- Each learning has an explicit doc target and, when appropriate, an enforcement target
- Any new durable doc is discoverable via an index or registry
- Runbooks updated when process/checklists changed, or explicitly noted as not needed
- `ARCHITECTURE.md` reviewed and updated if needed
- `docs/generated/memory.md` is processed and cleared, or explicitly marked not present
- Active plan is finalized and archived
- Docs commit gate passes

## When Things Go Wrong

- No meaningful learnings found: re-check `Surprises & Discoveries`, `Review Findings`, and verify evidence logs.
- Memory scratchpad empty or missing: note “not present” and proceed.
- Runbook conflicts with a skill gate: skill gate wins; adjust runbook to be additive.
- Tech debt tracker missing: create it in the expected format and populate it.
- Plan location mismatch: follow `docs/PLANS.md`, then make structure consistent and discoverable.

## Transition Points

Use an interactive question tool at transitions when available. Offer:

1. Continue to `he-doc-gardening` (recommended)
2. Continue to `he-spec` if a new initiative is ready
3. Run `he-triage` if many new tracker entries were added
4. Pause with status plus explicit next action

If running autonomously and no interactive tool is available, proceed with the recommended next step and log an “Autonomous transition” note in `Decision Log` or `Revision Notes`.
