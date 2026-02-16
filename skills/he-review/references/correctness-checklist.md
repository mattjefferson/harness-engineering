# Correctness Reviewer Checklist

Owns: plan fidelity, behavioral correctness, test verification, regression risk.

> Runbooks may add repo-specific checks to any section below. Language/framework-specific runbooks (e.g., `review-typescript.md`) are the expected extension mechanism. Runbooks must not remove or relax items here.

## Plan Fidelity

- [ ] Every `Progress` item marked complete has corresponding code in the diff
- [ ] No code in the diff implements functionality outside the plan scope (scope creep)
- [ ] `Purpose / Big Picture` intent is preserved — the implementation solves the stated problem
- [ ] Every `Validation and Acceptance` criterion can be traced to evidence (test, log, screenshot, or demo)
- [ ] Open `Progress` items are genuinely incomplete, not accidentally left open

## Behavioral Correctness

- [ ] Happy path produces the expected output for representative inputs
- [ ] Edge cases handled: empty collections, null/undefined/nil, zero values, boundary values (off-by-one), max-size inputs
- [ ] Error paths return meaningful errors and do not silently swallow failures
- [ ] State mutations are intentional — no accidental side effects on shared or global state
- [ ] Concurrency and ordering: concurrent access to shared resources is safe; event ordering assumptions are documented or enforced
- [ ] Idempotency: operations that should be idempotent actually are (retries, duplicate messages, re-runs)

## Type and Contract Safety

- [ ] Function/method signatures match all call sites (argument count, types, order)
- [ ] Return types are honored — callers handle every possible return shape (including error variants)
- [ ] API contracts match between producer and consumer (request/response schemas, status codes, headers)
- [ ] Generated context (`docs/generated/`) is consistent with the implementation (schema changes reflected, endpoints match)

## Test Verification

- [ ] Every `Validation and Acceptance` criterion has at least one test
- [ ] No mock-based tests — mocks are a `high` finding unless the repo explicitly documents an exception
- [ ] Tests cover happy path, error path, and at least one edge case per public function
- [ ] Assertions are specific — no `expect(result).toBeTruthy()` when a concrete value is known
- [ ] Tests fail when the feature is removed or broken (not tautological)
- [ ] No test-order dependencies or timing-sensitive assertions (flaky test risk)

## Regression Risk

- [ ] Deleted or modified code does not break existing callers (search for usages before removing)
- [ ] Changed default values are intentional and documented
- [ ] Renamed exports/symbols are updated at every import site

## Priority Guidance

| Situation | Typical Priority |
|---|---|
| Acceptance criterion has no test or evidence | `high` |
| Behavioral bug on happy path | `critical` |
| Missing edge-case handling with user-visible impact | `high` |
| Missing edge-case handling with internal-only impact | `medium` |
| Mock-based test | `high` |
| Scope creep (extra functionality not in plan) | `medium` |
| Flaky test risk (timing/ordering) | `high` |
| Changed default breaks existing callers | `high` |
