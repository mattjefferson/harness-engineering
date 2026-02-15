# FRONTEND.md

Capture frontend architecture, conventions, and performance/accessibility requirements.

## Stack
<!-- seed: Framework, language, build tools detected from package manifest. -->

- Common baseline:
- Define supported browsers/platforms and the minimum accessibility target.
- Prefer a small set of core dependencies and consistent build tooling across the app.

## Conventions
<!-- seed: Code style, file structure, naming patterns from bootstrap Q&A. -->

- Common baseline:
- Keep components small and named by what they do; avoid "utils soup" without ownership.
- Centralize shared UI primitives; avoid duplicating patterns across pages.

## Component Architecture
<!-- seed: Component library, design system, state management approach. -->

- Common baseline:
- Separate UI rendering from data fetching/mutations where practical.
- Prefer explicit data flow and local state; introduce global state only with a clear boundary.

## Performance
<!-- seed: Bundle size targets, loading strategy, critical rendering path. -->

- Common baseline:
- Avoid unnecessary client work: minimize re-renders, split code on route/feature boundaries, and lazy-load heavy modules.
- Measure before optimizing; keep a short list of performance budgets that matter to users.

## Accessibility
<!-- seed: WCAG level, screen reader support, keyboard navigation requirements. -->

- Common baseline:
- Keyboard navigation works for all interactive controls; focus states are visible.
- Use semantic HTML first; ARIA is for filling gaps, not replacing semantics.
