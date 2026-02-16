---
name: he-runbook
description: Creates or edits repo runbooks in docs/runbooks/ with correct frontmatter (title/use_when/called_from), additive-only semantics, and predictable linkage so skills can automatically apply them.
argument-hint: "[runbook topic or target path under docs/runbooks/]"
---

# HE Runbook

Create or update a runbook (process/checklist) that can evolve per project, while keeping skill-enforced gates immutable.

## When to Use

- When a learning or review finding should become a repeatable process
- When a new workflow needs documentation for skill integration
- When an existing runbook needs updating after `he-learn`

## Key Principles

1. **Runbooks are additive only** — they may add repo-specific steps, but they must not waive or override anything codified in skills.
2. **Frontmatter is the integration contract** — `title`, `use_when`, `called_from` must be accurate.
3. **One runbook, one job** — keep scope tight and name it for the workflow it documents.
4. **Avoid duplication** — before creating or editing, scan existing runbooks for overlap and conflicts.
5. **Prefer verifiable steps** — commands, file paths, expected outputs; avoid vague guidance.
6. **Make it discoverable** — link high-leverage runbooks from AGENTS.md (runbook index).

## Workflow

### Phase 0: Inventory Existing Runbooks

1. List existing runbooks: `find docs/runbooks -type f -name "*.md" -print`
2. Skim frontmatter: `rg -n "^(title|use_when|called_from):" docs/runbooks`
3. If a runbook already covers the workflow, update it instead of creating a new one.
4. If multiple runbooks overlap:
   - Consolidate into one primary runbook when possible, or
   - Add explicit cross-links ("Related runbooks") and clarify boundaries.
5. Check for conflicts: any step that suggests skipping tests/review/verify gates is invalid.

### Phase 1: Decide Edit vs. New

- If an existing runbook covers the topic, edit it in place.
- Only create a new runbook when the workflow is materially different.

### Phase 2: Write the Runbook

1. Choose filename: `docs/runbooks/<kebab-topic>.md` (short, stable, descriptive).
2. Start from `skills/he-runbook/templates/runbook-template.md`.
3. Set required frontmatter:
   - `title`: human readable.
   - `use_when`: a single-sentence trigger.
   - `called_from`: YAML list of skill names (preferred) and optionally workflow steps. Keep this list minimal and accurate; it controls automatic runbook selection.
4. Write the body:
   - Start with the stable invariant: "skill gates still apply; runbook cannot waive them".
   - Add the repo-specific checklist/commands in execution order.
5. Audit against `skills/he-runbook/references/audit-rules.md` — verify no prohibited content (escalation weakening, gate waiving, priority redefinition, evidence weakening, mock allowance, consent bypass).

### Phase 3: Validate and Link

1. Audit: verify runbook content against `skills/he-runbook/references/audit-rules.md` (no prohibited content).
2. Lint: `bash scripts/ci/he-runbooks-lint.sh`
3. Verify selection: `bash scripts/runbooks/select-runbooks.sh --skill <skill>` returns the runbook.
4. If this runbook will be reused, add it to the AGENTS.md runbook index.

## Conflict Rule (Non-Negotiable)

If a runbook contradicts a skill gate, the skill wins. Treat the runbook as drift and escalate/update it.

## Forward Progress Rule

Runbooks are **not** the critical path artifact contract between workflow phases. If a runbook is missing, malformed, or low-quality:

- Do not block execution of `he-implement`, `he-review`, or `he-verify-release`.
- Proceed based on the skill-enforced gates and the plan contract (`docs/PLANS.md`).
- Treat the runbook fix as an additive improvement to be captured during `he-learn`.

## Output

- A runbook file in `docs/runbooks/`
- Optional: AGENTS.md link to the runbook (when it's a common workflow)

## Exit Gate

- Runbook exists with correct frontmatter (`title`, `use_when`, `called_from`)
- Runbook lint passes
- `select-runbooks.sh` returns the runbook for specified skills
- No steps contradict skill-enforced gates

## When Things Go Wrong

- **Runbook lint fails** — fix frontmatter before proceeding; it controls skill integration.
- **`select-runbooks.sh` doesn't return the runbook** — check `called_from` list matches the target skill names exactly.
- **Existing runbook conflicts with a new one** — consolidate or add explicit cross-links with clear boundaries.
- **Runbook step contradicts a skill gate** — remove or rewrite the step; skill gates are immutable.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Creating a new runbook when an existing one covers the topic | Update existing runbooks in place |
| Missing or inaccurate `called_from` frontmatter | Skills discover runbooks via frontmatter; accuracy is critical |
| Runbook steps that waive skill gates | Runbooks are additive only; skill gates are immutable |
| Vague guidance ("make sure everything works") | Concrete commands, file paths, expected outputs |
| Duplicate runbooks for overlapping workflows | Consolidate or cross-link with clear boundaries |

## Transition Points

This skill is typically invoked from `he-learn` or standalone. No fixed next phase.
