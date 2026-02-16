# Architecture / Invariants Reviewer Checklist

Owns: structural integrity, design principles, invariant preservation, dependency management, pattern consistency.

> Runbooks may add repo-specific checks to any section below. Language/framework-specific runbooks (e.g., `review-typescript.md`) are the expected extension mechanism. Runbooks must not remove or relax items here.

## Structural Integrity

- [ ] New files follow the repo's module/directory conventions (check existing structure)
- [ ] Dependency direction is correct — no upward or circular imports
- [ ] Public API surface is intentional — only expose what consumers need
- [ ] Shared types, constants, and utilities live in the repo's common/shared location, not duplicated per module

## Design Principles

Apply pragmatically — flag only when violation creates a concrete problem, not dogmatically.

- [ ] Single Responsibility: each module/class/function has one reason to change
- [ ] Open/Closed: extension points exist where variation is expected; core logic is not modified for each new case
- [ ] Dependency Inversion: high-level modules depend on abstractions, not concrete implementations (where the repo already uses this pattern)
- [ ] Interface Segregation: consumers are not forced to depend on methods they don't use
- [ ] Liskov Substitution: subtypes are substitutable for their base types without breaking callers

## Invariant Preservation

- [ ] Existing invariants from AGENTS.md, runbooks, and generated context are preserved (not silently violated)
- [ ] Schema changes are consistent with generated schema context in `docs/generated/` (if present) and migration files
- [ ] API changes are consistent with generated API context in `docs/generated/` (if present) and route definitions
- [ ] Config changes work across all environments (dev, staging, prod) — no environment-specific breakage
- [ ] Feature flags are used for risky changes that need a rollback path

## Cross-Cutting Concerns

- [ ] Error handling follows the repo's established pattern (thrown exceptions vs. result types vs. error codes)
- [ ] Logging follows conventions (structured logging, appropriate log levels, no sensitive data)
- [ ] New code paths have observability (logs, metrics, or traces for production debugging)
- [ ] Config values have sensible defaults — missing config does not crash silently

## Dependency Management

- [ ] New dependencies are justified — the problem can't be solved with existing deps or stdlib
- [ ] Dependency versions are pinned (lock file updated)
- [ ] No duplicate dependencies solving the same problem (e.g., two date libraries)
- [ ] License compatibility verified for new dependencies

## Migration and Compatibility

- [ ] Breaking changes have documented migration paths
- [ ] Backward compatibility maintained or explicitly broken with justification
- [ ] Generated context (`docs/generated/`) updated to reflect structural changes

## Pattern Consistency

- [ ] Same patterns used for same problems throughout the codebase (don't introduce a competing approach)
- [ ] New abstractions follow existing naming and organizational conventions
- [ ] No one-off patterns that diverge from established repo style without justification

## Priority Guidance

| Situation | Typical Priority |
|---|---|
| Circular dependency introduced | `high` |
| Existing invariant violated (schema, API contract, AGENTS.md rule) | `critical` |
| New dependency duplicates existing one | `medium` |
| Breaking change without migration path | `high` |
| Missing observability for new code path | `medium` |
| Config missing default (crash risk) | `high` |
| Pattern inconsistency (competing approach) | `medium` |
| Design principle violation without concrete impact | `low` |
