---
name: he-create-runbook
description: Creates or edits repo runbooks in docs/runbooks/ with correct frontmatter (title/use_when/called_from), additive-only semantics, and predictable linkage so skills can automatically apply them.
argument-hint: "[runbook topic or target path under docs/runbooks/]"
---

# HE Create Runbook

Create or update a runbook (process/checklist) that can evolve per project, while keeping skill-enforced gates immutable.

## Key Principles

1. Runbooks are additive only: they may add repo-specific steps, but they must not waive or override anything codified in skills.
2. Frontmatter is the integration contract: `title`, `use_when`, `called_from` must be accurate.
3. One runbook, one job: keep scope tight and name it for the workflow it documents.
4. Prefer verifiable steps: commands, file paths, expected outputs; avoid vague guidance.
5. Make it discoverable: link high-leverage runbooks from AGENTS.md (runbook index).

## Inputs

- runbook topic, OR a target path like `docs/runbooks/<topic>.md`
- the skill(s) or workflow steps where the runbook should be applied (`called_from`)

## Outputs

- a runbook file in `docs/runbooks/`
- optional: AGENTS.md link to the runbook (when it's a common workflow)

## Procedure

1. Decide: edit vs new.
   - If an existing runbook covers the topic, edit it in place.
   - Only create a new runbook when the workflow is materially different.
2. Choose filename:
   - `docs/runbooks/<kebab-topic>.md` (short, stable, descriptive).
3. Start from the template:
   - `skills/he-create-runbook/templates/runbook-template.md`
4. Set required frontmatter:
   - `title`: human readable.
   - `use_when`: a single-sentence trigger.
   - `called_from`: YAML list of skill names (preferred) and optionally workflow steps.
     - Examples: `he-review`, `he-verify-release`, `he-implement`, `he-learn`.
     - Keep this list minimal and accurate; it controls automatic runbook selection.
5. Write the body:
   - Start with the stable invariant: "skill gates still apply; runbook cannot waive them".
   - Add the repo-specific checklist/commands in the order they should be executed.
6. Validate integration:
   - Lint: `bash scripts/ci/he-runbooks-lint.sh`
   - Verify selection: `bash scripts/runbooks/select-runbooks.sh --skill <skill>` returns the runbook.
7. Link if needed:
   - If this runbook will be reused, add it to the AGENTS.md runbook index.

## Conflict Rule (Non-Negotiable)

If a runbook contradicts a skill gate, the skill wins. Treat the runbook as drift and escalate/update it.

