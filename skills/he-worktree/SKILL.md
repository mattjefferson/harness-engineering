---
name: he-worktree
description: Creates or validates an isolated git workspace (worktree or branch) so harness workflow execution does not collide with human in-flight changes.
argument-hint: "[optional initiative slug, topic, or target branch]"
---

# HE Worktree

Prepare safe workspace isolation before running implementation-heavy phases.

## Key Principles

1. Isolation first for non-trivial work: avoid collisions with human in-flight changes.
2. Never work on the default branch without explicit consent.
3. No destructive git: do not reset/clean/delete automatically.
4. Name and verify: branch/worktree naming plus explicit status verification.
5. Hand off a concrete workspace: strategy, branch name, directory path.
6. Runbooks are additive only: apply any runbook whose frontmatter `called_from` matches this skill (see `bash scripts/runbooks/select-runbooks.sh --skill <skill>`), but never waive/override anything codified here.

## When To Use

- Before `he-spike` when creating throwaway prototypes
- Before `he-implement` for non-trivial or long-running work
- Before broad review/refactor passes that may touch many files
- Any time the current branch/workspace ownership is unclear

## Inputs

- Optional initiative slug/topic/branch hint
- Current repository state (`git status`, current branch, default branch)

## Workspace Detection

1. Ensure repository context:
   - `git rev-parse --show-toplevel`
2. Read current branch:
   - `git branch --show-current`
3. Read default branch:
   - `git remote show origin | sed -n '/HEAD branch/s/.*: //p'`
4. Detect whether already in a worktree:
   - `git rev-parse --git-dir` contains `/worktrees/`
5. Refresh refs before branching decisions:
   - `git fetch --all --prune`

## Branch Naming

Choose a branch name from context:

- `spike/<topic>` for feasibility investigations
- `feat/<topic>` for feature work
- `fix/<topic>` for bug fixes
- `chore/<topic>` for maintenance

When a slug exists, prefer embedding the topic part from `YYYY-MM-DD-topic`.

## Decision Flow

1. If already in a worktree for the same initiative, continue there.
2. If on the default branch, prefer creating a new worktree.
3. If on a feature branch, decide between continuing that branch or creating a new worktree.
4. Continuing directly on default branch requires explicit user consent.

When interactive tools are available, ask the user to choose:

1. Create a new worktree (recommended)
2. Create a branch in current directory
3. Continue in current directory

## Worktree Creation

1. Derive branch name from initiative context.
2. Derive directory path:
   - `../<repo-name>-<branch-name>`
3. Create and switch in one command:
   - `git worktree add ../<repo-name>-<branch-name> -b <branch-name>`
4. If needed, copy local runtime files (`.env`, local config overrides) that should not be committed.
5. Validate isolation:
   - `git -C ../<repo-name>-<branch-name> status --short --branch`

## Branch-Only Path

If worktree is unnecessary:

1. Create branch in current repo:
   - `git checkout -b <branch-name>`
2. Verify:
   - `git status --short --branch`

## Safety Rules

- Never run destructive git commands (`reset --hard`, `clean -fd`, branch deletion) as part of this skill.
- Never delete existing worktrees automatically.
- If a target worktree path already exists, inspect and ask before reusing.
- Report exact branch and directory before handing off.

## Output Contract

Return:

- selected strategy (`worktree` or `branch`)
- branch name
- workspace directory path
- verification command + result summary

## Next Step

Proceed to `he-spike` or `he-implement` in the selected isolated workspace.
