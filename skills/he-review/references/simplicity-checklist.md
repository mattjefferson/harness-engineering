# Simplicity Reviewer Checklist

Owns: YAGNI violations, complexity, redundancy, readability, change proportionality.

> Runbooks may add repo-specific checks to any section below. Language/framework-specific runbooks (e.g., `review-typescript.md`) are the expected extension mechanism. Runbooks must not remove or relax items here.

## YAGNI Discipline

- [ ] Every abstraction has 2+ current uses — no abstractions built for a single call site
- [ ] No speculative feature flags, extension points, or plugin architectures without a current consumer
- [ ] Generic solutions are justified by current requirements, not hypothetical future ones
- [ ] No "just in case" error handling for scenarios that cannot occur given the current architecture
- [ ] Configuration options exist only for values that actually vary — no premature parameterization

## Complexity

- [ ] Functions are readable in one pass — flag functions exceeding ~60 lines for review
- [ ] Nesting depth is 3 levels or fewer (conditionals, loops, callbacks)
- [ ] No nested ternaries or boolean truth tables — use early returns, guard clauses, or named conditions
- [ ] No "clever" code — straightforward and obvious is preferred over concise and obscure
- [ ] Cyclomatic complexity is proportional to the problem — simple problems have simple solutions
- [ ] Control flow reads top-to-bottom — no jumping between distant code sections to understand a single operation

## Redundancy

- [ ] No dead code (unused functions, unreachable branches, leftover debug statements)
- [ ] Duplicate logic is extracted only when it's exact duplication serving the same purpose — prefer duplication over the wrong abstraction
- [ ] No redundant defensive checks (e.g., null-checking a value that TypeScript guarantees non-null)
- [ ] No reimplementation of standard library or framework functionality
- [ ] No redundant comments that restate the code (`// increment counter` above `counter++`)

## Readability

- [ ] Names are self-documenting — variables, functions, and types describe their purpose without needing comments
- [ ] Comments explain *why*, not *what* — the code shows what, comments explain non-obvious reasoning
- [ ] Data structures match their usage pattern — not repurposing a structure for convenience
- [ ] Control flow reads naturally — no inverted conditions, double negatives, or boolean gymnastics
- [ ] No unused imports, variables, or parameters

## Change Proportionality

- [ ] Diff size is proportional to the feature — a one-line behavior change should not touch 20 files
- [ ] Multi-file changes are justified (e.g., interface change that requires updating all implementations)
- [ ] No formatting or style changes mixed with behavioral changes — separate commits
- [ ] Refactoring scope matches the task — don't clean up unrelated code in the same PR
- [ ] Test file count and size are proportional to the feature complexity

## Priority Guidance

| Situation | Typical Priority |
|---|---|
| Abstraction with only one use site | `medium` |
| Function exceeding ~60 lines with high complexity | `medium` |
| Dead code left in the diff | `low` |
| Speculative feature flag with no current consumer | `medium` |
| Formatting changes mixed with behavioral changes | `medium` |
| Reimplementation of stdlib functionality | `medium` |
| Nested ternary or boolean truth table | `low` |
| Diff size wildly disproportionate to feature | `high` |
| Wrong abstraction (forced DRY) | `high` |
| Clever/obscure code where straightforward alternative exists | `medium` |
