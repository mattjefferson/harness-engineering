---
name: he-worktree
description: Creates or validates an isolated git workspace (worktree or branch) so harness workflow execution does not collide with human in-flight changes.
argument-hint: "[optional initiative slug, topic, or target branch]"
---

# HE Worktree

Prepare safe workspace isolation before running implementation-heavy phases.

## When to Use

- Before `he-spike` when creating throwaway prototypes
- Before `he-implement` for non-trivial or long-running work
- Before broad review/refactor passes that may touch many files
- Any time the current branch/workspace ownership is unclear

## Key Principles

1. **Isolation first** — avoid collisions with human in-flight changes for non-trivial work.
2. **Never work on default branch without explicit consent** — always ask first.
3. **No destructive git** — do not reset/clean/delete automatically.
4. **Name and verify** — branch/worktree naming plus explicit status verification.
5. **Hand off a concrete workspace** — strategy, branch name, directory path.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-worktree`), but never waive/override anything codified here.

## Workflow

### Phase 0: Detect Current State

1. Ensure repository context: `git rev-parse --show-toplevel`
2. Read current branch: `git branch --show-current`
3. Read default branch: `git remote show origin | sed -n '/HEAD branch/s/.*: //p'`
4. Detect whether already in a worktree: `git rev-parse --git-dir` contains `/worktrees/`
5. Refresh refs: `git fetch --all --prune`
6. Accept optional initiative slug/topic/branch hint.
7. Run `bash scripts/runbooks/select-runbooks.sh --skill he-worktree` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Choose Strategy

1. If already in a worktree for the same initiative, continue there.
2. If on the default branch, prefer creating a new worktree.
3. If on a feature branch, decide between continuing that branch or creating a new worktree.
4. Continuing directly on default branch requires explicit user consent.

When interactive tools are available, ask the user to choose:

1. Create a new worktree (recommended)
2. Create a branch in current directory
3. Continue in current directory

### Phase 2: Create Workspace

**Branch naming** — choose from context:

- `spike/<topic>` for feasibility investigations
- `feat/<topic>` for feature work
- `fix/<topic>` for bug fixes
- `chore/<topic>` for maintenance

When a slug exists, prefer embedding the topic part from `YYYY-MM-DD-topic`.

**Worktree path:**

1. Derive branch name from initiative context.
2. Derive directory path: `../<repo-name>-<branch-name>`
3. Create and switch: `git worktree add ../<repo-name>-<branch-name> -b <branch-name>`
4. If needed, copy local runtime files (`.env`, local config overrides) that should not be committed.
5. Validate: `git -C ../<repo-name>-<branch-name> status --short --branch`

**Branch-only path** (when worktree is unnecessary):

1. Create branch: `git checkout -b <branch-name>`
2. Verify: `git status --short --branch`

## Safety Rules

- Never run destructive git commands (`reset --hard`, `clean -fd`, branch deletion) as part of this skill.
- Never delete existing worktrees automatically.
- If a target worktree path already exists, inspect and ask before reusing.
- Report exact branch and directory before handing off.

## Output

Return:

- Selected strategy (`worktree` or `branch`)
- Branch name
- Workspace directory path
- Verification command + result summary

## Exit Gate

- Workspace is isolated and verified
- Branch name and directory path are explicit
- Strategy is documented for downstream phases

## When Things Go Wrong

- **Target worktree path already exists** — inspect the existing worktree and ask the user before reusing or choosing a different path.
- **Branch name conflicts with existing branch** — check if the existing branch is related; if so, offer to continue on it; otherwise choose a different name.
- **`git fetch` fails** — check network/remote config; do not proceed with stale refs.
- **User is on default branch with uncommitted work** — warn explicitly; never silently overwrite in-flight changes.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Working directly on main/default without consent | Always isolate or get explicit approval |
| Deleting worktrees to resolve conflicts | Inspect first, ask the user |
| Skipping verification after creation | Always run `git status` to confirm isolation |
| Hardcoding branch prefixes without context | Match prefix to initiative type (spike/feat/fix/chore) |

## Transition Points

Proceed to `he-spike` or `he-implement` in the selected isolated workspace.
