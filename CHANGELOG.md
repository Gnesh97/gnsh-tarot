# Changelog

## [Unreleased]

- Added the production branch, CI validation, release checklist, rollback notes, backup notes, and staging test matrix.
- Fixed the seated character animation so it remains active while moving to the fortune result and stops only when the session closes.
- Fixed Celtic Cross staff slots 7–10 collapsing to zero size and not rendering their cards.
- Enforced server-side card uniqueness within each reading; the same card ID cannot be revealed twice in one spread.
- Reduced the reversed-card probability from 50% to 20%.
- Added regression contract tests for card uniqueness, reversed-card probability, seating lifecycle, and Celtic Cross layout rendering.

## 1.0.0 - 2026-08-11

- Initial version-controlled production baseline.
