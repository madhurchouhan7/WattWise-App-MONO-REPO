---
phase: 09-utility-content-platform
plan: 02
subsystem: api
tags: [express, mongoose, zod, etag, cache]
requires:
  - phase: 09-01
    provides: Wave-0 RED contract scaffolding for content routes and cache semantics
provides:
  - Versioned UtilityContent model for faq, bill_guide, and legal surfaces
  - Content controller and route wiring under /api/v1/content
  - Deterministic FAQ q/topic filtering with stable ordering and pagination
  - Conditional refresh semantics using ETag and If-None-Match
affects: [flutter-utility-screens, content-sync, legal-hub]
tech-stack:
  added: []
  patterns: [read-through cache for content payloads, conditional-get validators]
key-files:
  created:
    - backend/src/models/UtilityContent.model.js
    - backend/src/controllers/content.controller.js
    - backend/src/routes/content.routes.js
  modified:
    - backend/src/routes/index.js
    - backend/src/middleware/validation.middleware.js
    - backend/src/services/CacheService.js
    - backend/tests/content.contract.test.js
    - backend/tests/content.cache.test.js
key-decisions:
  - "Serve content from published UtilityContent documents with deterministic default fallbacks for missing records."
  - "Use validator-safe ETag generation from kind/slug/locale plus revision metadata and enforce Cache-Control: no-cache."
  - "Scope content cache keys by kind, slug, and locale to prevent cross-surface stale collisions."
patterns-established:
  - "Content endpoints return a normalized envelope with contentVersion, lastUpdatedAt, and effectiveFrom."
  - "FAQ filtering applies topic equality and free-text matching before deterministic order plus offset/limit slicing."
requirements-completed: [CNT-01, CNT-02, CNT-03, CNT-04, CNT-05]
duration: 34 min
completed: 2026-03-26
---

# Phase 09 Plan 02: Utility Content Platform Summary

**Versioned utility content APIs now serve FAQ, bill guide, and legal payloads with deterministic filters and ETag-driven conditional refresh semantics.**

## Performance

- **Duration:** 34 min
- **Started:** 2026-03-26T13:42:00Z
- **Completed:** 2026-03-26T14:16:13Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Implemented `UtilityContent` domain model and created `/api/v1/content` backend endpoints for FAQ, bill guide, and legal surfaces.
- Added validation contracts for FAQ query inputs and legal slug parameters, then wired content routes into the API index.
- Implemented cache-keyed conditional refresh behavior with `ETag` and `If-None-Match` handling and verified 200/304 behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement versioned utility content domain and endpoint contracts** - `5f3363a`, `7c6bb4b`
2. **Task 2: Implement cache-aware conditional refresh behavior for content endpoints** - `93f8c23`, `f5e4aef`

## Files Created/Modified

- `backend/src/models/UtilityContent.model.js` - Versioned content schema for faq, bill_guide, and legal kinds.
- `backend/src/controllers/content.controller.js` - Content fetch handlers with deterministic FAQ filtering and validator headers.
- `backend/src/routes/content.routes.js` - Endpoint definitions for `/faqs`, `/bill-guide`, and `/legal/:slug`.
- `backend/src/routes/index.js` - Mounted content route namespace under `/content`.
- `backend/src/middleware/validation.middleware.js` - Added `getFaqContent`, `getBillGuideContent`, and `getLegalContent` schemas.
- `backend/src/services/CacheService.js` - Added `generateContentKey(kind, slug, locale)` strategy.
- `backend/tests/content.contract.test.js` - Contract assertions for route mount, endpoint paths, and validation schema presence.
- `backend/tests/content.cache.test.js` - Executable handler-level tests for 200/304 conditional refresh behavior.

## Decisions Made

- Preferred additive content domain implementation without touching existing profile/appliance APIs.
- Kept response envelope aligned with `sendSuccess` and fixed metadata fields required by CNT contracts.
- Used locale-aware content cache keys to avoid stale data leakage across content surfaces.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed brittle route-mount detection in contract test for Express 5**
- **Found during:** Task 1 verification
- **Issue:** Router stack regex parsing no longer exposed mount regex in Express 5, causing false RED failures.
- **Fix:** Replaced stack-introspection assertion with static source mount assertion on `router.use("/content", contentRoutes)`.
- **Files modified:** backend/tests/content.contract.test.js
- **Verification:** `npm test -- --runInBand tests/content.contract.test.js`
- **Committed in:** `7c6bb4b`

**2. [Rule 3 - Blocking] Added missing content cache-key helper used by controller**
- **Found during:** Task 2 RED verification
- **Issue:** `content.controller` required `cacheService.generateContentKey`, but `CacheService` did not implement it.
- **Fix:** Added `generateContentKey(kind, slug, locale)` returning scoped `app:content:*` keys.
- **Files modified:** backend/src/services/CacheService.js
- **Verification:** `npm test -- --runInBand tests/content.cache.test.js tests/content.contract.test.js`
- **Committed in:** `f5e4aef`

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Both fixes were required for correctness and successful execution; no architecture change or scope creep.

## Issues Encountered

- Express 5 router internals changed mount-layer shape compared to legacy regex expectations; resolved by stable source-level route assertion.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Backend contracts for CNT-01..CNT-05 are in place and verified by contract/cache tests.
- Utility Flutter wiring can now consume `/api/v1/content` with validator-safe refresh behavior.

## Self-Check: PASSED

- FOUND: .planning/phases/09-utility-content-platform/09-02-SUMMARY.md
- FOUND: 5f3363a
- FOUND: 7c6bb4b
- FOUND: 93f8c23
- FOUND: f5e4aef

---
*Phase: 09-utility-content-platform*
*Completed: 2026-03-26*
