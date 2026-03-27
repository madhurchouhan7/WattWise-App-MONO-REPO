---
phase: 09
slug: utility-content-platform
status: pending
created: 2026-03-24
updated: 2026-03-24
---

# Phase 09 Manual UAT Checklist

Use this checklist to close the remaining human verification items for Phase 09.

## Environment

- Build: latest local branch after Phase 09 execution
- Device set: at least one small phone width and one regular phone width
- Network: online for normal checks, offline toggle for error/retry checks

## UAT-01 Profile Navigation to Content Surfaces

### Steps

1. Open Profile screen.
2. Tap How to read bill.
3. Verify content screen opens and shows loading state, then content.
4. Repeat for FAQs.
5. Repeat for Legal.
6. Force a temporary network failure and reopen each surface.
7. Verify error state appears with retry action.
8. Restore network and tap retry.

### Pass Criteria

- All 3 entries navigate to functional screens.
- Each screen supports loading, error, retry, and refresh behavior.
- Retry recovers and loads content after connectivity returns.

## UAT-02 Legal Refresh Feedback Semantics

### Steps

1. Open Legal screen and trigger refresh once without backend content change.
2. Confirm unchanged-state feedback appears.
3. Update backend legal content version/date or use seeded newer content.
4. Trigger refresh again.
5. Confirm updated-state feedback appears with new metadata.

### Pass Criteria

- Unchanged refresh shows "Already up to date" (or equivalent unchanged copy).
- Changed refresh shows explicit updated-version feedback.
- Visible metadata reflects the newer version/effective/update values.

## UAT-03 Metadata Readability on Mobile Sizes

### Steps

1. Open FAQ, Bill guide, and Legal on small-width device.
2. Inspect version/effective/updated metadata blocks.
3. Repeat on regular-width device.
4. Check text scaling (system font size increased if possible).

### Pass Criteria

- Metadata remains readable and not clipped/truncated.
- Hierarchy remains clear (label/value distinction visible).
- No overlapping text or layout overflow at common sizes.

## Result Summary

- [ ] UAT-01 passed
- [ ] UAT-02 passed
- [ ] UAT-03 passed

## Outcome

- If all pass: mark Phase 09 manual verification complete and proceed to Phase 10 planning.
- If any fail: log failing step(s) and create a gap-closure plan for Phase 09.
