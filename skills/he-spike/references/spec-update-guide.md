# Spec Update Guide (From Spikes)

When a spike concludes, update `docs/specs/<slug>.md` using what was learned.

The spec must be self-sufficient for `he-plan`: capture full rationale in the spec itself, not only in the spike doc.

## Update Mapping

| What changed in spike | Spec update |
|---|---|
| Requirement validated | Keep requirement as-is or tighten wording; add confidence rationale in `Key Decisions` if useful. |
| Requirement changed | Update requirement wording/priority in `Requirements`; include full rationale in spec (`Key Decisions` and affected sections). |
| New requirement discovered | Add a new `R#` row in `Requirements`; update `Success Criteria` and `Constraints` if impacted. |
| Scope boundary confirmed or shifted | Update `Scope` (`In Scope` / `Boundaries`) and `Non-Goals` with rationale. |
| New decision made | Add decision + rationale in `Key Decisions` (or `Chosen Direction`). |
| Direction invalidated | Update `Chosen Direction` and `Alternatives Considered`; flag for user review before planning. |
| Open question resolved | Remove from `Open Questions`; fold rationale into the impacted section. |
| Milestone impact discovered | Update `Initial Milestone Candidates` and `Handoff` (`he-plan` vs `he-spike`). |

## Required Update Pattern

1. Apply spec edits directly in `docs/specs/<slug>.md`.
2. Keep rationale in the spec (do not rely on "see spike doc" only).
3. Add spike linkage in relevant sections for traceability.
4. Append a `Revision Notes` entry in the spec describing what changed and why.
5. In the spike doc's `Impact on Upstream Docs`, list exact spec sections updated (or state no changes were needed).

## No-Change Case

If the spike does not change spec intent:

- Keep `docs/specs/<slug>.md` unchanged.
- In spike `Impact on Upstream Docs`, state: `No spec changes required` with rationale.
