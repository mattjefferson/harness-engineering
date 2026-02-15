# Architecture

This file is intentionally short. It exists to help a new contributor answer: "Where do I change code to do X?"

Only write down things that are unlikely to change frequently. Do not try to keep this synchronized with the codebase. Revisit a couple of times a year.

Name important directories, modules, and types. Avoid external links and step-by-step procedures (those belong in `docs/` or inline docs).

## Bird's-Eye Overview

In 3-8 sentences:

- What problem does this system solve?
- Who uses it and what are the primary flows?
- What are the major runtime pieces (CLI, server, workers, UI, etc.)?

## Codemap (Where Is X?)

List coarse-grained areas and what each owns. Keep it at "map of a country" granularity.

- `path/or/module`: owns <what>, responsible for <what>, key types: <TypeA>, <TypeB>
- `path/or/module`: owns <what>, responsible for <what>, key types: <TypeC>

Add a short data/control-flow sketch in plain text:

`<entrypoint>` -> `<layer>` -> `<layer>` -> `<storage/service>`

## Boundaries

Call out the boundaries between layers/systems and what is allowed to cross them.

- Boundary: <A> owns <X>; <B> owns <Y>; allowed interactions: <...>
- Boundary: <internal vs external API>; stable contracts live in <...>

## Architectural Invariants (Must Remain True)

List the non-obvious rules that prevent drift. Invariants are often expressed as the absence of a dependency.

- `X` must not depend on `Y`.
- No business logic in <UI/controller layer>.
- Side effects only occur in <explicit boundary/module>.

## Cross-Cutting Concerns

Brief pointers to the stable conventions:

- Logging/metrics/tracing: <where + key conventions>
- Error handling: <where + conventions>
- Configuration: <where + precedence rules>
- Security/data boundaries: <where + sensitivity rules>

## Where Details Live

If you need more detail than this file provides, put it in `docs/` (runbooks, policies, plans) or in inline module documentation, and then add a short pointer here (file paths and names, not URLs).
