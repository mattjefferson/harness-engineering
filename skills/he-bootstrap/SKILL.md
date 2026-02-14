---
name: he-bootstrap
description: Bootstraps a repository for the harness-engineered workflow by creating AGENTS.md, docs/specs, docs/plans, docs/generated, and baseline tracking files. Use when setting up a new project before running he-intake through he-learn.
argument-hint: "[optional target repo path; defaults to current directory]"
---

# HE Bootstrap

Initialize the minimum docs structure required by the `he-*` workflow.

## Inputs

- Optional target path (repo root)
- If omitted, use current directory

## Created Structure

- `docs/specs/`
- `docs/plans/active/`
- `docs/plans/completed/`
- `docs/generated/runs/`
- `docs/references/`

## Baseline Files

Create these only if missing:

- `AGENTS.md`
- `docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md`
- `docs/plans/README.md`
- `docs/generated/README.md`
- `docs/references/README.md`

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
test -d docs/generated/runs &&
test -d docs/references &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md
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
