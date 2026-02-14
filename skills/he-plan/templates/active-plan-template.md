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

## Task Details (Required)

### 1
- files_to_change: `src/domain/user.ts`
- tests_to_run: `bun test tests/domain/user.test.ts`
- verify_commands: `bun test tests/domain/user.test.ts`
- acceptance: `...`
- done_when: `...`

### 1.1
- files_to_change: `src/api/users.ts`
- tests_to_run: `bun test tests/api/users.test.ts`
- verify_commands: `bun test tests/api/users.test.ts`
- acceptance: `...`
- done_when: `...`

### 1.2
- files_to_change: `src/ui/UserProfile.tsx`
- tests_to_run: `bun test tests/ui/UserProfile.test.tsx`
- verify_commands: `bun test tests/ui/UserProfile.test.tsx`
- acceptance: `...`
- done_when: `...`

## Progress Log
| timestamp | task_seq | update | evidence |
|---|---|---|---|
| <YYYY-MM-DD HH:MM> | 1 | planned | link to PR/test output |

## Test Matrix
- 1: scenario -> expected (linked to `test_files`/`verify_commands`)
- 1.1: scenario -> expected (linked to `test_files`/`verify_commands`)
- 1.2: scenario -> expected (linked to `test_files`/`verify_commands`)

## Rollout / Rollback
- rollout: ...
- rollback: ...

## Review / Verify Gates
- critical/high findings block progression
