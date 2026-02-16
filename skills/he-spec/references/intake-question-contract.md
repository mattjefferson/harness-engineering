# Intake Question Contract (`he-spec`)

Use this contract for all material intake decisions in `he-spec`.

## Core Rules

1. Ask exactly one decision per turn.
2. Use `request_user_input` for material decisions.
3. Provide 2-3 mutually exclusive options.
4. Put the recommended option first and suffix it with `(Recommended)`.
5. Include one sentence describing the tradeoff for each option.
6. Allow a custom answer through the interactive tool's free-text path when needed.
7. If the user's answer is vague, ask one disambiguation follow-up using the same format.
8. If ambiguity remains after that follow-up, proceed with the recommended default and log it in `Open Questions` as `[decision]`.
9. Never repeat the exact same question verbatim in the same response or in consecutive turns.

## Required Question Shape

Each decision question should include:

- `header`: short label (12 chars or fewer)
- `question`: single decision-focused sentence
- `options`: 2-3 choices where each option has:
- `label`: short, mutually exclusive choice name
- `description`: one sentence explaining impact/tradeoff

## Good Example

Question:

- Header: `V1 Focus`
- Prompt: `Which v1 direction should this initiative take?`
- Options:
- Option `Drafting Copilot (Recommended)` - Best for fast time-to-value from a blank page.
- Option `Rewrite Coach` - Better for editing existing text, weaker for blank-page starts.
- Option `End-to-End Agent` - Highest ambition, but higher complexity and risk.

Why this is good:

- Single decision.
- Explicit recommendation.
- Clear tradeoffs.
- Mutually exclusive options.

## Bad Example

Question:

- `What should this do?`
- Followed by mixed free-text prompts and occasional multiple-choice blocks with no recommendation.

Why this is bad:

- Inconsistent interaction style.
- More than one decision can be implied in one prompt.
- Missing recommendation makes defaults unclear.
- Harder to compare options turn to turn.

## Exception Rule

Use direct free-text only when options cannot be reasonably enumerated. State why before asking (for example: "I cannot provide meaningful fixed options here because valid answers are unconstrained by the current repo or product context.").
