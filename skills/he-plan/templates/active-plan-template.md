# <title>

## Metadata
- slug: <slug>
- status: active
- phase: plan
- plan_mode: <lightweight|execution>
- overall_priority: <critical|high|medium|low>

## Summary
...

## Decision Log
| date | decision_id | decision | rationale | owner |
|---|---|---|---|---|
| <YYYY-MM-DD> | D1 | ... | ... | ... |

## Task DAG
| task_seq | summary | depends_on | parallel_safe | priority | status |
|---|---|---|---|---|---|
| 1 | Domain model update | none | yes | low | todo |
| 1.1 | Controller behavior update | 1 | yes | medium | todo |
| 1.2 | UI behavior update | 1 | no | medium | todo |

Task DAG `status` is the single source of truth for task completion.

## Task Details

> **Template instruction**: Use one format below based on `plan_mode`. Delete the section you are not using.

### Lightweight Mode

For `plan_mode: lightweight`, use the minimal task format:

#### [ ] 1 [Define user domain invariants]
- files: `src/domain/user.ts`, `src/domain/validator.ts`
- steps:
  - [ ] Add/adjust domain invariants and validation logic
  - [ ] Update call sites that depend on invariant behavior
- test_type: unit
- verify: `bun test tests/domain/user.test.ts`
- done_when: Domain tests pass and behavior matches spec

#### [ ] 1.1 [Implement API validation flow]
- files: `src/api/users.ts`
- steps:
  - [ ] Wire invariant checks into request handling path
  - [ ] Map validation failures to stable API errors
- test_type: unit
- verify: `bun test tests/api/users.test.ts`
- done_when: Invalid requests rejected with expected API responses

### Execution Mode

For `plan_mode: execution`, use the full task format:

#### [ ] 1 [Define user domain invariants]
- objective: `Codify domain rules and invariants for user entities.`
- implementation_steps:
  - [ ] `Add/adjust domain invariants and validation logic.`
  - [ ] `Update call sites that depend on invariant behavior.`
- files_to_change: `src/domain/user.ts`, `src/domain/validator.ts`
- test_type: unit
- tests_to_run: `bun test tests/domain/user.test.ts`
- verify_commands: `bun test tests/domain/user.test.ts`
- dependencies: `none`
- risks: `Incorrect invariant assumptions may reject valid input.`
- rollback_impact: `Revert domain invariant changes and rerun domain tests.`
- acceptance: `Invariant behavior matches spec and existing contracts.`
- done_when: `Domain tests pass and behavior is reflected in plan evidence.`
- evidence: `link to commit/test output`

#### [ ] 1.1 [Implement API validation flow]
- objective: `Apply domain invariant checks in the API boundary.`
- implementation_steps:
  - [ ] `Wire invariant checks into request handling path.`
  - [ ] `Map validation failures to stable API errors.`
- files_to_change: `src/api/users.ts`
- test_type: e2e
- tests_to_run: `bun test tests/api/users.test.ts`
- verify_commands: `bun test tests/api/users.test.ts`
- dependencies: `1`
- risks: `Response contract drift if error mapping changes.`
- rollback_impact: `Revert handler changes and restore prior API mapping.`
- acceptance: `Invalid requests are rejected with expected API responses.`
- done_when: `API tests pass with unchanged success-path behavior.`
- evidence: `link to commit/test output`

#### [ ] 1.2 [Update user profile UI behavior]
- objective: `Reflect updated API/domain behavior in profile flows.`
- implementation_steps:
  - [ ] `Update UI validation handling states.`
  - [ ] `Adjust user-facing error messaging and interaction flow.`
- files_to_change: `src/ui/UserProfile.tsx`
- test_type: e2e
- tests_to_run: `bun test tests/ui/UserProfile.test.tsx`
- verify_commands: `bun test tests/ui/UserProfile.test.tsx`
- dependencies: `1`
- risks: `UI regressions in client-side form state transitions.`
- rollback_impact: `Revert component changes and rerun UI tests.`
- acceptance: `UI handles new validation responses without regressions.`
- done_when: `UI tests pass and acceptance scenarios are satisfied.`
- evidence: `link to commit/test output`

## Progress Log
| timestamp | task_seq | update | evidence |
|---|---|---|---|
| <YYYY-MM-DD HH:MM> | 1 | planned | link to PR/test output |

## Review Findings
<!-- Populated by he-review -->

## Verify/Release Decision
<!-- Populated by he-verify-release -->
- decision: GO | NO-GO
- date:
- open findings by priority (if any):
- evidence:
- rollback:
- post-release checks:
- owner:
