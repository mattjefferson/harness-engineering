# Harness Engineering Skill Pack

Artifact-first workflows for agent-driven software delivery.

This repository packages a set of `he-*` skills plus templates that turn "ship software" into a versioned, evidence-backed control loop that both humans and agents can run reliably.

## Key Features

- End-to-end workflow skills (`he-spec` -> `he-learn`) with hard gates and explicit artifacts
- `he-bootstrap` templates for `docs/` structure, plans, runbooks, and generated context
- Parallel review + verify/release gates that produce a written GO/NO-GO decision
- A compounding learning loop that turns failures into permanent guardrails
- `agent-browser` and `he-video` helpers for capturing agentic E2E evidence

## Philosophy

Ultimate philosophy: turn software delivery into a versioned, evidence-backed control system.

How this is different:

- Artifact-first, not meeting-first: specs/plans/decisions are committed, not tribal memory.
- Progressive disclosure: short stable entry points, deeper context only when needed.
- Gate-driven flow: movement across phases requires proof, not "looks good".
- Agent-native by design: work is chunked so parallel agents can execute/review/verify.
- Compounding: failures become guardrails (docs, tests, principles, and CI rules).

Influences:

- OpenAI Harness Engineering: https://openai.com/index/harness-engineering/
- Every Compound Engineering Plugin: https://github.com/EveryInc/compound-engineering-plugin
- TMC Iterative Engineering Plugin: https://github.com/tmchow/tmc-marketplace/tree/main/plugins/iterative-engineering

## Table of Contents

- [What This Repo Provides](#what-this-repo-provides)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Install Script Reference](#install-script-reference)
- [Using The Skills In A Project](#using-the-skills-in-a-project)
- [Workflow Model](#workflow-model)
- [Skills (Detailed)](#skills-detailed)
- [Templates And Artifacts](#templates-and-artifacts)
- [Development Guide](#development-guide)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Deployment And Distribution](#deployment-and-distribution)

## What This Repo Provides

- `he-*` skills for a harness-oriented workflow:
  - `he-bootstrap`
  - `he-spec`
  - `he-research`
  - `he-spike`
  - `he-plan`
  - `he-worktree`
  - `he-implement`
  - `he-review`
  - `he-verify-release`
  - `he-learn`
  - `he-doc-gardening`
  - `he-workflow` (orchestrator)
- `agent-browser`: browser automation evidence capture (snapshots, clicks, forms, screenshots, recordings).
- `he-video`: scripts/templates for recording and linking evidence.
- Templates for:
  - specs (`docs/specs/`)
  - spikes (`docs/spikes/`)
  - plans (`docs/plans/active/` and `docs/plans/completed/`)
  - runbooks (`docs/runbooks/`)
  - generated reference context (`docs/generated/`)
- An installer (`scripts/install.sh`) to sync skills into agent runtimes.

## Tech Stack

- **Language**: Bash + Markdown
- **Packaging**: filesystem skill packs (`skills/<name>/SKILL.md` + `templates/`)
- **Distribution**: copy/sync skills into runtime skill directories
- **CI helpers (templates)**: shell scripts that lint plans/specs/spikes and check doc drift

## Prerequisites

Required:

- macOS or Linux
- Bash
- Git (for cloning and normal workflow use)

Optional but recommended:

- `trash` (so the installer can remove legacy `~/.codex/skills` safely when present)
- `rg` (ripgrep) for fast local searching

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/mattjefferson/harness-engineering.git
cd harness-engineering
```

### 2. Preview install actions (safe)

```bash
./scripts/install.sh --dry-run
```

### 3. Install skills into your agent runtimes

```bash
./scripts/install.sh
```

Default behavior:

- Copies repo `skills/*` into `~/.agents/skills` (Codex reads this directly)
- Optionally syncs the same installed skills into `~/.claude/skills`
- If legacy `~/.codex/skills` exists, removes it safely (using `trash` or `~/.Trash`)

### 4. Verify installed skills exist

```bash
ls -1 ~/.agents/skills | rg '^(he-|agent-browser|he-video)'
ls -1 ~/.claude/skills | rg '^(he-|agent-browser|he-video)' || true
test ! -d ~/.codex/skills || echo \"Legacy ~/.codex/skills still exists\"
```

### 5. Bootstrap a target repo

From the target repo root (the repo you want to work on with the workflow):

```bash
bash /path/to/harness-engineering/skills/he-bootstrap/templates/bootstrap.sh
```

Optional architecture template:

```bash
bash /path/to/harness-engineering/skills/he-bootstrap/templates/bootstrap.sh --with-architecture
```

## Install Script Reference

Script: `scripts/install.sh`

### Command

```bash
./scripts/install.sh [options]
```

### Options

| Option | Description | Default |
|---|---|---|
| `--source <dir>` | Source skills directory | `<repo>/skills` |
| `--agents-home <dir>` | Base `.agents` path | `~/.agents` |
| `--target <dir>` | Extra install target (repeatable) | none |
| `--no-claude` | Skip sync to `~/.claude/skills` | disabled |
| `--dry-run` | Print actions without copying | off |
| `-h`, `--help` | Show help | n/a |

### Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `AGENTS_HOME` | Base `.agents` directory | `~/.agents` |

### Usage examples

Install to all defaults:

```bash
./scripts/install.sh
```

Install only to `~/.agents/skills` (skip Claude sync):

```bash
./scripts/install.sh --no-claude
```

Install to defaults plus an additional target:

```bash
./scripts/install.sh --target ~/.config/my-agent/skills
```

Use custom source and agents home:

```bash
./scripts/install.sh --source ./skills --agents-home ~/.agents
```

## Using The Skills In A Project

### What `he-bootstrap` creates

After running bootstrap, the target repo will contain a predictable `docs/` layout:

```text
docs/
  PLANS.md
  DOMAIN_DOCS.md
  design-docs/
    core-beliefs.md
  generated/
    README.md
    db-schema.md
    api-schema.md
    component-tree.md
    dependency-graph.md
    memory.md
  plans/
    README.md
    tech-debt-tracker.md
    active/
    completed/
  runbooks/
    update-agents-md.md
    update-domain-docs.md
    code-review.md
    review-findings.md
    address-review-findings.md
    verify-release.md
    record-evidence.md
    ci-failures.md
    escalation.md
    merge-change.md
  specs/
    README.md
    index.md
  spikes/
    README.md
```

Notes:

- Domain docs like `docs/SECURITY.md` and `docs/RELIABILITY.md` are created on-demand by downstream skills when the repo has real context.
- `docs/generated/memory.md` is an agent scratchpad and is processed/cleared during `he-learn`.

### A typical initiative flow

1. `he-spec`: write intent into `docs/specs/<slug>.md`
2. `he-research` (optional): answer investigatable open questions; update the spec
3. `he-spike` (optional): time-box feasibility UX/behavior exploration; write findings
4. `he-plan`: write the executable plan into `docs/plans/active/<slug>.md`
5. `he-worktree` (recommended for non-trivial): isolate workspace for implementation
6. `he-implement`: execute the plan and keep the plan's living sections current
7. `he-review`: parallel review fanout into the plan's `## Review Findings`
8. `he-verify-release`: record GO/NO-GO with evidence + rollback in `## Verify/Release Decision`
9. `he-learn`: turn issues into guardrails; update runbooks; process `docs/generated/memory.md`; archive plan

`he-workflow` orchestrates the above and enforces phase order and gates.

## Workflow Model

### Slug convention

All initiative artifacts share one slug:

```text
YYYY-MM-DD-kebab-topic
```

Example:

```text
2026-02-14-install-skill-sync
```

### Plan modes

- `trivial`: single-file, low-risk fixes; abbreviated plan path; lightweight review fanout
- `lightweight`: small work with concise milestones and evidence
- `execution`: multi-hour work with rich context, milestones, and deeper validation

### Source of truth hierarchy (in consuming repos)

1. Human intent: `docs/specs/<slug>.md`
2. Spike findings: `docs/spikes/<slug>-spike.md` (if a spike was run)
3. Execution plan: `docs/plans/active/<slug>.md` (`plan_mode: trivial|lightweight|execution`)
4. Generated context: `docs/generated/` (schema snapshots, graphs, scratchpad)

### Hard gates (non-negotiable)

- Doc commit gate between phase transitions (artifacts are versioned)
- Priority gate: unresolved `critical`/`high` findings block progression
- Progress gate: `## Progress` is the single checklist section; timestamped with stable IDs
- Section gate: active plans include all required `docs/PLANS.md` sections
- Validation gate: plans include concrete commands and observable acceptance outcomes
- Testing gate: verification uses unit/e2e evidence only; no mocks by default
- Living-plan gate: decision/discovery/retro sections are append-only and current

## Skills (Detailed)

Each skill is a directory under `skills/<name>/` and is defined by `SKILL.md` (plus optional templates and references).

### `he-bootstrap`

Bootstraps a repo with a predictable `docs/` artifact structure.

- Template source: `skills/he-bootstrap/templates/`
- Entry point: `skills/he-bootstrap/templates/bootstrap.sh`

### `he-spec`

Converts an initiative request into a written spec.

- Template: `skills/he-spec/templates/spec-template.md`
- Output: `docs/specs/<slug>.md`

### `he-research`

Resolves investigatable open questions and updates the spec with evidence.

- Output: updates `docs/specs/<slug>.md`

### `he-spike`

Time-boxed feasibility exploration for unknown UX/behavior or risky approach questions.

- Template: `skills/he-spike/templates/spike-template.md`
- Output: `docs/spikes/<slug>-spike.md`

### `he-plan`

Creates a PLANS-compliant executable plan with milestones, proof commands, and living sections.

- Template: `skills/he-plan/templates/plan-template.md`
- Output: `docs/plans/active/<slug>.md`

### `he-worktree`

Creates an isolated worktree/branch for non-trivial work so agent execution does not collide with local changes.

### `he-implement`

Executes plan progress items and keeps living sections current.

### `he-review`

Runs parallel review fanout (correctness, architecture, security/data, simplicity) and enforces the priority gate.

- Runbooks: `docs/runbooks/code-review.md` and `docs/runbooks/review-findings.md`

### `he-verify-release`

Records GO/NO-GO in the plan with evidence, rollback readiness, and post-release checks.

- Runbooks: `docs/runbooks/verify-release.md`, `docs/runbooks/record-evidence.md`, `docs/runbooks/ci-failures.md`, `docs/runbooks/merge-change.md`

### `he-learn`

Turns execution outcomes into durable guardrails, updates runbooks, processes the scratchpad, and archives the plan.

### `he-doc-gardening`

Periodic maintenance: identify drift, obsolete docs, and missing references; create doc-fix initiatives.

### `he-workflow`

The orchestrator: enforces phase order and the hard gates, and routes to the correct skill next.

## Templates And Artifacts

### Skills are versioned APIs

Treat:

- `skills/<name>/SKILL.md`
- `skills/<name>/templates/**`

as an API contract. Consuming repos will rely on these semantics.

### `ARCHITECTURE.md` template is intentionally short

The architecture template is a "codemap + invariants" document:

- It should help new contributors find where to change code.
- It should capture stable boundaries and non-obvious invariants.
- It should avoid long procedures (those belong in runbooks).

Template: `skills/he-bootstrap/templates/ARCHITECTURE.md`

## Development Guide

### Add a new skill

1. Create `skills/<skill-name>/`.
2. Add `skills/<skill-name>/SKILL.md` with frontmatter and an explicit workflow.
3. Add any `templates/` or `references/` mentioned by the skill.
4. Dry-run install: `./scripts/install.sh --dry-run`
5. Install: `./scripts/install.sh`

### Update existing skills/templates

1. Edit `skills/<skill-name>/SKILL.md` or templates under `skills/<skill-name>/templates/`.
2. Keep phase order and gate semantics consistent with `skills/he-workflow/SKILL.md`.
3. Reinstall with `./scripts/install.sh`.

## Verification

Recommended checks before committing:

```bash
# Shell syntax
bash -n scripts/install.sh

# Installer safety preview
./scripts/install.sh --dry-run

# Bootstrap script usage smoke check
bash skills/he-bootstrap/templates/bootstrap.sh --help
```

If you are editing `he-bootstrap` templates, also run the template CI scripts locally:

```bash
# From this repo root (runs in the template tree):
bash skills/he-bootstrap/templates/scripts/ci/he-docs-lint.sh
bash skills/he-bootstrap/templates/scripts/ci/he-docs-drift.sh || true
bash skills/he-bootstrap/templates/scripts/ci/he-plans-lint.sh || true
bash skills/he-bootstrap/templates/scripts/ci/he-specs-lint.sh || true
bash skills/he-bootstrap/templates/scripts/ci/he-spikes-lint.sh || true
```

## Troubleshooting

### Installer fails removing legacy `~/.codex/skills`

Cause: legacy dir exists and the machine lacks `trash` and `~/.Trash` (common on Linux).

Fix options:

1. Install a `trash` command appropriate for your OS, then rerun installer.
2. Manually move `~/.codex/skills` out of the way safely, then rerun installer.

### Skills not appearing in your runtime

Fix:

```bash
./scripts/install.sh
ls -la ~/.agents/skills
ls -la ~/.claude/skills || true
```

If your runtime uses a different skills directory, install to it:

```bash
./scripts/install.sh --target /path/to/runtime/skills
```

### Bootstrap created only part of the docs structure

Cause: running bootstrap from the wrong current directory.

Fix: `cd` to target repo root and rerun bootstrap script.

## Deployment And Distribution

This repository has no runtime service to deploy. Distribution is file-based:

1. Update `skills/` and `scripts/install.sh`.
2. Pin to a commit/tag if you need stable rollout.
3. Re-run `./scripts/install.sh` on developer machines to propagate updates.
