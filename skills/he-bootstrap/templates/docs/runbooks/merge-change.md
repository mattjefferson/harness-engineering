---
title: "Merge Change"
use_when: "You have a GO decision and need the minimum merge gate (checks/approvals/evidence) before merging to the main branch."
---

# Merge Change

This runbook captures the repo-specific merge gate. Keep it short and make it objective where possible.

## Preconditions

- `he-verify-release` decision is `GO` in `docs/plans/active/<slug>.md`
- All required checks are green (local and/or CI, per repo policy)
- Evidence is linked in the plan (and PR if present)

## Merge Checklist (Customize Per Repo)

- Required approvals obtained
- Required checks passing
- Versioning/release notes updated (if applicable)
- Post-merge verification steps queued (see `docs/runbooks/verify-release.md`)

## Post-Merge

- Run the post-release checks documented in the plan
- If any regression is found, open a follow-up and record it in learnings

