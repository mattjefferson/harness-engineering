---
name: he-github
description: Opens/updates GitHub PRs, checks CI, responds to feedback, and merges after GO using gh CLI with explicit consent gates.
argument-hint: "[slug, docs/plans/active/<slug>.md, or PR number/url]"
---

# HE GitHub

Drive the PR lifecycle end-to-end with `gh`, while keeping harness artifacts (spec/plan/evidence) as the system of record.

## When to Use

- After `he-implement` when code is ready for a PR
- When CI fails and needs triage
- When PR feedback arrives and needs a response
- When `he-verify-release` decision is GO and merge is approved

## Key Principles

1. **Consent gate for remote ops** — do not push, open a PR, request review, or merge without explicit user approval.
2. **One PR per initiative slug** — the PR title/body should reference the same slug used in `docs/specs/` and `docs/plans/`.
3. **Plan is canonical** — the PR description links to the active plan and key evidence; it does not replace it.
4. **CI is evidence** — treat failing checks as signal; follow `docs/runbooks/ci-failures.md`.
5. **Feedback loop** — respond to review comments by updating code + plan + evidence, then push and re-check.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-github`).

## Workflow

### Phase 0: Preflight

- Read `docs/plans/active/<slug>.md` or accept initiative slug/PR reference.
- Verify current git workspace context (branch/worktree) from `he-worktree`.
- Run and record results in plan `Artifacts and Notes` or `Decision Log`:
  - `git status --short --branch`
  - `git remote -v`
  - `gh auth status`

### Phase 1: Open or Update PR (Consent Required)

**Creating a new PR:**

1. Push the branch: `git push -u origin HEAD`
2. Create a PR: `gh pr create --fill`
3. Ensure the PR body links:
   - spec: `docs/specs/<slug>.md`
   - plan: `docs/plans/active/<slug>.md`
   - evidence: paths under `docs/artifacts/<slug>/` (if any)
4. Update the active plan `## Pull Request` section with pr URL, branch name, current commit SHA, CI link/status.

**Updating an existing PR:**

- Update body/checklist links: `gh pr edit --body-file <file>`
- Re-check CI: `gh pr checks`
- Ensure `## Pull Request` in the plan stays current.

### Phase 2: Respond to Feedback

1. Fetch comments and requested changes:
   - `gh pr view --comments`
   - `gh pr view --json reviews`
2. Make the smallest root-cause fix.
3. Update plan `Review Findings`, `Progress`, and any evidence references.
4. Push and re-run checks (consent required):
   - `git push`
   - `gh pr checks`

### Phase 3: Detect and Remediate Build Failures

- Use `gh pr checks` to identify failing jobs quickly.
- Use `gh run view --log-failed` (or the repo's equivalent) to pull actionable logs.
- Follow `docs/runbooks/ci-failures.md` for triage order and escalation.

### Phase 4: Merge (Consent + GO Required)

**Merge preconditions** (canonical — runbooks may add repo-specific items but must not remove these):

- `he-verify-release` decision is `GO` in the active plan.
- All required checks are green (local and/or CI).
- Evidence is linked in the plan (and PR body if present).
- No unresolved `critical` or `high` review findings.

When approved, merge using the repo policy in `docs/runbooks/merge-change.md` (often via `gh pr merge`).

## Output

- PR opened/updated on GitHub.
- `## Pull Request` section in the active plan kept current.

## Exit Gate

- PR state matches the current phase (opened, updated, merged, or feedback addressed)
- Plan `## Pull Request` section reflects current PR metadata
- CI status is recorded

## When Things Go Wrong

- **`gh auth status` fails** — auth must be resolved before any remote ops; do not proceed unauthenticated.
- **CI fails after push** — triage using `docs/runbooks/ci-failures.md`; do not merge with failing checks.
- **PR feedback contradicts the plan** — update the plan first, then the code; plan is canonical.
- **Merge conflicts** — resolve before merge; never force-push without explicit consent.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Pushing without user consent | Consent gate for all remote operations |
| PR description replaces the plan | PR links to the plan; plan is the system of record |
| Merging with failing CI | CI is evidence; failures must be resolved |
| Force-pushing without explicit approval | Always get consent for destructive remote ops |
| Ignoring PR feedback | Respond by updating code + plan + evidence |

## Transition Points

This skill is typically invoked from within the workflow rather than transitioning to a next phase. After merge, the workflow continues to `he-learn`.
