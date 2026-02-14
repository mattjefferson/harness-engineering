---
name: he-bootstrap
description: Bootstraps a repository for the harness-engineered workflow by creating AGENTS.md, docs/specs, docs/plans, docs/generated, and baseline tracking files. Use when setting up a new project before running he-intake through he-learn.
argument-hint: "[optional target repo path; defaults to current directory]"
---

# HE Bootstrap

Initialize the docs structure required by the `he-*` workflow while preserving this repo's `docs/specs` and `docs/plans` conventions.

## Inputs

- Optional target path (repo root)
- If omitted, use current directory

## Created Structure

- `docs/specs/`
- `docs/plans/active/`
- `docs/plans/completed/`
- `docs/design-docs/`
- `docs/generated/`
- `docs/references/`

## Baseline Files

Create these only if missing:

- `AGENTS.md`
- `docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md`
- `docs/specs/index.md`
- `docs/plans/README.md`
- `docs/generated/README.md`
- `docs/generated/db-schema.md`
- `docs/references/README.md`
- `docs/design-docs/index.md`
- `docs/design-docs/core-beliefs.md`
- `docs/DESIGN.md`
- `docs/FRONTEND.md`
- `docs/PLANS.md`
- `docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md`
- `docs/SECURITY.md`

## Templates

Each created file has a source template in `templates/`:

- `AGENTS.md` <- `templates/AGENTS.md`
- `ARCHITECTURE.md` <- `templates/ARCHITECTURE.md` (optional with `--with-architecture`)
- `docs/plans/tech-debt-tracker.md` <- `templates/docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md` <- `templates/docs/specs/README.md`
- `docs/specs/index.md` <- `templates/docs/specs/index.md`
- `docs/plans/README.md` <- `templates/docs/plans/README.md`
- `docs/generated/README.md` <- `templates/docs/generated/README.md`
- `docs/generated/db-schema.md` <- `templates/docs/generated/db-schema.md`
- `docs/references/README.md` <- `templates/docs/references/README.md`
- `docs/design-docs/index.md` <- `templates/docs/design-docs/index.md`
- `docs/design-docs/core-beliefs.md` <- `templates/docs/design-docs/core-beliefs.md`
- `docs/DESIGN.md` <- `templates/docs/DESIGN.md`
- `docs/FRONTEND.md` <- `templates/docs/FRONTEND.md`
- `docs/PLANS.md` <- `templates/docs/PLANS.md`
- `docs/PRODUCT_SENSE.md` <- `templates/docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md` <- `templates/docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md` <- `templates/docs/RELIABILITY.md`
- `docs/SECURITY.md` <- `templates/docs/SECURITY.md`

Plan templates provided by this skill set:

- `skills/he-intake/templates/spec-template.md` (intake output)
- `skills/he-plan/templates/active-plan-template.md` (`plan_mode: lightweight|execution`)

Optional reference examples (not auto-created by bootstrap):

- `templates/docs/references/template-llms.txt`

Optional:

- `ARCHITECTURE.md` (when `--with-architecture` is passed)

## Bootstrap Commands

Run `templates/bootstrap.sh` from the target repo root.

Example:

```bash
bash skills/he-bootstrap/templates/bootstrap.sh
```

With architecture template:

```bash
bash skills/he-bootstrap/templates/bootstrap.sh --with-architecture
```

## Post-Bootstrap Validation

```bash
test -d docs/specs &&
test -d docs/plans/active &&
test -d docs/plans/completed &&
test -d docs/design-docs &&
test -d docs/generated &&
test -d docs/references &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md &&
test -f docs/generated/db-schema.md &&
test -f docs/design-docs/core-beliefs.md &&
test -f docs/QUALITY_SCORE.md
```

## Next Step

Start the first initiative with:

1. `he-intake` to create `docs/specs/<slug>.md`
2. `he-plan` to create `docs/plans/active/<slug>.md`

## Transition Options (Required)

At every transition point, present 2-3 explicit options and a recommended default before continuing.

- Use the plan question tool (`request_user_input`) when in Plan mode.
- If the plan question tool is unavailable, ask in chat with the same option structure.
- At least one option must explicitly be `Next step: he-intake`.
- Wait for the user's selection before proceeding to the next phase.
