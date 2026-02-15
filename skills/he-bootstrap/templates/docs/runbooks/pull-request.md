---
title: "Pull Request"
use_when: "You need to open or update a PR that links the initiative plan and evidence, and you want a consistent PR hygiene/checks workflow."
called_from:
  - he-github
  - he-implement
  - he-review
---

# Pull Request

This runbook describes repo-specific PR conventions (title/body conventions, labels, reviewers, and required checks).

Skill gates still apply: do not push/open/merge without the required validation and explicit consent when a human is present.

## Preflight

- `git status --short --branch`
- `git diff`
- `gh auth status`

## Create Or Update PR (Customize Per Repo)

Recommended `gh` flow:

- Push:
  - `git push -u origin HEAD`
- Create:
  - `gh pr create --fill`
- Update:
  - `gh pr edit --body-file <path>`

## Required Links In PR Description

- Spec: `docs/specs/<slug>.md`
- Plan: `docs/plans/active/<slug>.md`
- Evidence (if any): `docs/artifacts/<slug>/...`

## Checks

- View checks:
  - `gh pr checks`
- View a failing run:
  - `gh run view --log-failed`

