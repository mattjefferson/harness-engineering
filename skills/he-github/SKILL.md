---
name: he-github
description: Opens/updates GitHub PRs, checks CI, responds to feedback, and merges after GO using gh CLI with explicit consent gates.
argument-hint: "[slug, docs/plans/active/<slug>.md, or PR number/url]"
---

# HE GitHub

Drive the PR lifecycle end-to-end with `gh`, while keeping harness artifacts (spec/plan/evidence) as the system of record.

## Key Principles

1. **Consent gate for remote ops**: do not push, open a PR, request review, or merge without explicit user approval.
2. **One PR per initiative slug**: the PR title/body should reference the same slug used in `docs/specs/` and `docs/plans/`.
3. **Plan is canonical**: the PR description links to the active plan and key evidence; it does not replace it.
4. **CI is evidence**: treat failing checks as signal; follow `docs/runbooks/ci-failures.md`.
5. **Feedback loop**: respond to review comments by updating code + plan + evidence, then push and re-check.
6. Runbooks are additive only: apply any runbook whose frontmatter `called_from` matches this skill (see `python scripts/runbooks/select-runbooks.py --skill <skill>`).

## Runbooks

Runbooks are additive (not required). A bootstrapped repo usually includes:

- `docs/runbooks/pull-request.md`
- `docs/runbooks/respond-to-feedback.md`
- `docs/runbooks/ci-failures.md`
- `docs/runbooks/merge-change.md`

In addition, apply any runbooks returned by:

`python scripts/runbooks/select-runbooks.py --skill he-github`

## Inputs

- Initiative slug or active plan path: `docs/plans/active/<slug>.md`
- Current git workspace context (branch/worktree) from `he-worktree`
- GitHub CLI auth context (`gh auth status`)

## Preflight

Run and record results (in plan `Artifacts and Notes` or `Decision Log`):

- `git status --short --branch`
- `git remote -v`
- `gh auth status`

## Open Or Update PR (Consent Required)

When approved:

1. Push the branch:
   - `git push -u origin HEAD`
2. Create a PR if none exists:
   - `gh pr create --fill`
3. Ensure the PR body links:
   - spec: `docs/specs/<slug>.md`
   - plan: `docs/plans/active/<slug>.md`
   - evidence: paths under `docs/artifacts/<slug>/` (if any)
4. Update the active plan `## Pull Request` section with:
   - pr URL
   - branch name
   - current commit SHA
   - CI link/status (as available)

If a PR already exists:

- Update body/checklist links: `gh pr edit --body-file <file>`
- Re-check CI: `gh pr checks`
- Ensure `docs/plans/active/<slug>.md` `## Pull Request` stays current.

## Respond To Feedback

1. Fetch comments and requested changes:
   - `gh pr view --comments`
   - `gh pr view --json reviews`
2. Make the smallest root-cause fix.
3. Update plan `Review Findings`, `Progress`, and any evidence references.
4. Push and re-run checks (consent required):
   - `git push`
   - `gh pr checks`

## Detect And Remediate Build Failures

- Use `gh pr checks` to identify failing jobs quickly.
- Use `gh run view --log-failed` (or the repo’s equivalent) to pull actionable logs.
- Follow `docs/runbooks/ci-failures.md` for triage order and escalation.

## Merge (Consent + GO Required)

Preconditions:

- `he-verify-release` decision is `GO` in the active plan.
- Required checks are green.

When approved, merge using the repo policy in `docs/runbooks/merge-change.md` (often via `gh pr merge`).
