---
name: he-learn
description: Captures post-release learning, updates debt and quality guidance, and archives active plans to completed for future reuse.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Learn

Turn execution outcomes into durable improvements.

## When to Use

- After `he-verify-release` when the initiative is complete (GO decision)
- After merge to capture learnings before archiving

## Key Principles

1. **Convert failures into guardrails** — record prevention actions in the tracker.
2. **Update durable policy** — domain docs and runbooks reflect new learnings.
3. **Process the scratchpad** — triage and clear `docs/generated/memory.md`.
4. **Archive cleanly** — move the plan to completed and keep append-only semantics.
5. **Promote enforcement** — repeated issues should become lint/test/CI guardrails.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-learn`), but never waive/override anything codified here.

## Workflow

### Phase 0: Gather Learning Inputs

1. Read `docs/plans/active/<slug>.md`.
2. Gather implementation/review/verify outcomes plus generated context updates (if any).
3. Gather incident or friction notes (if any).
4. Use subagents in parallel — e.g., one to analyze review findings and recurring patterns, another to scan implementation friction from `Progress` and `Surprises & Discoveries`.
5. Run `bash scripts/runbooks/select-runbooks.sh --skill he-learn` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Capture Learnings

For each learning, evaluate the compound learning loop:

1. **AGENTS.md update** — should this pattern update the project's AGENTS.md?
2. **Golden principle** — should this become a golden principle in AGENTS.md?
3. **Guardrail promotion** — should this become a lint rule, test, or structural check?
4. **Runbook update** — should this pattern update a runbook? If yes, update `docs/runbooks/<topic>.md` (or add a new one) and link it from AGENTS.md if it becomes a common workflow. Ensure new/updated runbooks include frontmatter `called_from` so relevant skills pick them up automatically.
5. **Lesson tracking** — update status in `docs/plans/tech-debt-tracker.md` (set `resolved` with evidence when a learning addresses an existing entry).

Use `templates/learning-entry-template.md`.

### Phase 2: Update Durable Artifacts

1. Update `docs/plans/tech-debt-tracker.md`:
   - Add or update an entry in the index table (ID, date, priority, source, status, summary)
   - Add or update the corresponding detail entry with prevention action, owner, and source slug
   - Set status to `resolved` and add `Resolved in: <slug>` when a learning addresses an existing entry
2. Update relevant domain docs per `docs/DOMAIN_DOCS.md` registry if policy changed.
3. Update or create any affected runbooks in `docs/runbooks/` when learnings change process, checklists, or "how we do it here" guidance.

### Phase 3: Process Scratchpad and Archive

1. Process `docs/generated/memory.md` (scratchpad inbox):
   - Promote keepers to the correct durable location in `docs/` or `docs/runbooks/`.
   - Delete anything no longer needed.
   - Clear `docs/generated/memory.md` back to an empty scratchpad (keep the header/sections).
2. Move plan to `docs/plans/completed/<slug>.md`.

## Output

- Updated `docs/plans/tech-debt-tracker.md`
- Updated domain docs and runbooks as needed
- Processed `docs/generated/memory.md`
- Archived plan at `docs/plans/completed/<slug>.md`

## Exit Gate

- At least one concrete prevention action is captured for each meaningful issue
- Each learning is evaluated against the compound learning loop
- Runbooks are updated when process/checklists changed (or explicitly marked "no runbook update needed")
- `docs/generated/memory.md` is processed and cleared (or explicitly marked empty/not present)
- Active plan is archived to completed
- Docs commit gate passes

## When Things Go Wrong

- **No meaningful learnings found** — this is suspicious; review the `Surprises & Discoveries` and `Review Findings` sections more carefully.
- **Memory scratchpad is empty or missing** — mark as "not present" and proceed; don't block on it.
- **Runbook update would conflict with a skill gate** — skill gates win; adjust the runbook to be additive only.
- **Tech debt tracker doesn't exist yet** — create it from the expected format and populate.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Skipping learn phase because "nothing went wrong" | Every initiative has learnings; dig deeper |
| Recording learnings without prevention actions | Every issue needs a concrete prevention action |
| Leaving memory scratchpad unprocessed | Promote or delete every item; clear the inbox |
| Updating runbooks without `called_from` frontmatter | Skills discover runbooks via frontmatter; always include it |
| Archiving without updating living sections | Ensure plan living sections are final before archiving |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-doc-gardening` (or `he-spec` for the next initiative) (recommended)
2. Run `he-triage` if significant new tracker entries were added during this learning cycle
3. Run one more build-feedback round in `he-learn`
4. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with the recommended next phase and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
