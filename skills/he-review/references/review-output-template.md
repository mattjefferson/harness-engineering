# Review Output Template

Format for `## Review Findings` written into the active plan during Phase 2 (Consolidate).

## Structure

Each dimension gets its own section with a thin index table followed by detail entries. Dimensions with no findings still appear with an empty table and a note.

### Dimension Sections

One section per reviewer dimension, in this order:

1. **Correctness** — ID prefix: `C-`
2. **Architecture / Invariants** — ID prefix: `A-`
3. **Security** — ID prefix: `S-`
4. **Data Integrity / Privacy** — ID prefix: `D-`
5. **Simplicity** — ID prefix: `SIM-`

Each section contains:

1. **Index table** — scannable overview of findings for that dimension
2. **Detail entries** — one `####` entry per finding with full context
3. **N/A summary** — checklist sections that did not apply, with one-line rationale

### Index Table Format

```markdown
| ID | Priority | Location | Summary |
|---|---|---|---|
| C-1 | high | `auth.ts:87` | Token refresh race under concurrent requests |
| C-2 | medium | `list.ts:201` | Filter ignores archived items with --all flag |
```

### Detail Entry Format

```markdown
#### C-1: Token refresh race under concurrent requests

Concurrent requests can use an expired token after expiry but before the refresh
completes. Add a mutex or queue so only one refresh runs at a time and others wait
for the result.

Owner: @backend
```

Every detail entry must include:

- **Priority** (in the index table): `critical | high | medium | low`
- **Location** (in the index table): file path + line/symbol context
- **Issue summary** (entry heading + body): what is wrong and why it matters
- **Required action** (entry body): what must be done to resolve
- **Owner** (entry footer): who is responsible for the fix

### N/A Summary Format

After the detail entries for each dimension, list checklist items that did not apply:

```markdown
**N/A items**: Input validation (no user-facing inputs in this change), CSRF (backend-only change).
```

## Summary Section

After all dimension sections, write a `### Summary` section:

- Issue counts by severity (e.g., "1 critical, 2 high, 3 medium, 1 low")
- Cross-domain insights — when multiple reviewers flag the same area, call it out in a blockquote
- Recommended fix order (address highest-risk findings first)

## Gate Decision Section

After the summary, write a `### Gate Decision` section:

- **Verdict**: `BLOCKED` or `PASS`
- If `BLOCKED`: list the blocking findings (critical/high) by ID — these are added to the plan's `Progress` section and routed back to `he-implement` for resolution, then re-reviewed
- Medium/low findings: "Routed to `docs/plans/tech-debt-tracker.md` with status `new`" — list the IDs cross-referenced

## Example

```markdown
## Review Findings

### Correctness

| ID | Priority | Location | Summary |
|---|---|---|---|
| C-1 | high | `auth.ts:87` | Token refresh race under concurrent requests |
| C-2 | medium | `list.ts:201` | Filter ignores archived items with --all flag |

#### C-1: Token refresh race under concurrent requests

Concurrent requests can use an expired token after expiry but before the refresh
completes. Add a mutex or queue so only one refresh runs at a time and others wait
for the result.

Owner: @backend

#### C-2: Filter ignores archived items with --all flag

The `--all` flag is documented to include archived items, but the filter predicate
skips them. Add `status != 'archived'` to the exclusion list only when `--all` is
not set.

Owner: @backend

**N/A items**: Database query correctness (no DB changes), migration rollback (no migrations).

### Architecture / Invariants

| ID | Priority | Location | Summary |
|---|---|---|---|

No findings.

**N/A items**: Dependency management (no new dependencies), module boundary (single-module change).

### Security

| ID | Priority | Location | Summary |
|---|---|---|---|
| S-1 | critical | `auth.ts:34` | API key logged at debug level |

#### S-1: API key logged at debug level

The debug-level log at `auth.ts:34` includes the raw API key in the request context
dump. Replace with a masked version or remove from debug output entirely.

Owner: @backend

**N/A items**: CSRF (backend-only), file upload validation (no uploads).

### Data Integrity / Privacy

| ID | Priority | Location | Summary |
|---|---|---|---|

No findings.

**N/A items**: Migration safety (no migrations), PII handling (no PII fields touched).

### Simplicity

| ID | Priority | Location | Summary |
|---|---|---|---|
| SIM-1 | low | `format.ts:45` | Nested ternary in format helper |

#### SIM-1: Nested ternary in format helper

Three-level nested ternary is hard to read. Extract to a `switch` or early-return
chain.

Owner: @frontend

**N/A items**: YAGNI (no speculative features), dead code (no unused exports).

### Summary

1 critical, 1 high, 1 medium, 1 low.

> **Cross-domain**: `auth.ts` flagged by both Correctness (C-1) and Security (S-1) — this file needs focused attention.

Recommended fix order: S-1 (critical) → C-1 (high) → C-2, SIM-1 (non-blocking).

### Gate Decision

**BLOCKED** — the following findings must be resolved before proceeding.

Blocking findings added to `Progress` and routed back to `he-implement`:

- S-1 (critical): API key logged at debug level
- C-1 (high): Token refresh race under concurrent requests

Medium/low findings routed to `docs/plans/tech-debt-tracker.md` with status `new`: C-2, SIM-1.
```
