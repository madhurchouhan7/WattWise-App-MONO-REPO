---
phase: 08-appliance-domain-hardening
plan: 02
subsystem: api
tags: [express, mongoose, zod, validation, concurrency]

requires:
  - phase: 08-01
    provides: appliance mutation contract baselines and RED-first regression suites
provides:
  - Deterministic create/patch/delete appliance validation contracts with details[] error envelopes
  - Non-destructive bulk mutation scope for touched appliance identifiers only
  - Optimistic concurrency guards for PATCH/DELETE using version preconditions and 412 recovery envelopes
affects: [08-03, appliance-client-retry-ux, mutation-recovery]

tech-stack:
  added: []
  patterns:
    - zod strict schema binding per route operation
    - soft-delete and patch mutation filters guarded by userId + isActive + __v preconditions

key-files:
  created: []
  modified:
    - backend/src/middleware/validation.middleware.js
    - backend/src/routes/appliance.routes.js
    - backend/src/controllers/appliance.controller.js
    - backend/src/models/Appliance.model.js
    - backend/tests/appliance.validation.test.js
    - backend/tests/appliance.contract.test.js
    - backend/tests/appliance.concurrency.contract.test.js

key-decisions:
  - "Require _expectedVersion in PATCH and DELETE payload contracts and enforce __v preconditions in mutation filters."
  - "Return deterministic PRECONDITION_FAILED envelopes for stale writes instead of 404 or silent overwrite behavior."
  - "Retain /bulk route for compatibility but scope deactivation to touched applianceId values only."

patterns-established:
  - "Mutation Hardening: bind operation-specific validation schemas directly in route definitions."
  - "Conflict Safety: when versioned mutation misses, re-check existence and branch to 412 conflict vs 404 not found."

requirements-completed: [APP-01, APP-02, APP-04]

duration: 13 min
completed: 2026-03-24
---

# Phase 8 Plan 2: Appliance Mutation Hardening Summary

**Validated appliance create/patch/delete contracts with strict schema binding, non-destructive mutation scoping, and stale-write protection via deterministic 412 precondition envelopes**

## Performance

- **Duration:** 13 min
- **Started:** 2026-03-24T05:41:00Z
- **Completed:** 2026-03-24T05:54:00Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Added dedicated `createAppliance`, `patchAppliance`, and `deleteAppliance` validation schemas and bound them on appliance routes for deterministic request validation.
- Hardened bulk mutation behavior to deactivate only touched appliance IDs, preserving unrelated active appliances.
- Implemented optimistic concurrency for PATCH/DELETE with `__v` preconditions and deterministic `PRECONDITION_FAILED` envelopes for stale writes.

## Task Commits

Each task was committed atomically:

1. **Task 1: Enforce validated per-resource mutation contracts** - `36d3241` (feat)
2. **Task 2: Implement optimistic concurrency preconditions and conflict recovery contract** - `5766588` (feat)

## Files Created/Modified

- `backend/src/middleware/validation.middleware.js` - Added strict create/patch/delete appliance validation schemas.
- `backend/src/routes/appliance.routes.js` - Bound create/patch/delete (and compatibility bulk) routes to validation middleware.
- `backend/src/controllers/appliance.controller.js` - Added non-destructive bulk scope and version-aware patch/delete conflict handling.
- `backend/src/models/Appliance.model.js` - Enabled explicit optimistic concurrency and added a version-aware index.
- `backend/tests/appliance.validation.test.js` - Added contract coverage for create/patch/delete schema behavior.
- `backend/tests/appliance.contract.test.js` - Added assertions for version-precondition filters and revision increment updates.
- `backend/tests/appliance.concurrency.contract.test.js` - Added deterministic 412 stale-write contract assertions.

## Decisions Made

- Enforced client-provided `_expectedVersion` as required mutation precondition for PATCH/DELETE contracts.
- Chose deterministic `PRECONDITION_FAILED` response envelopes with request correlation fields for client recovery UX.
- Preserved `/bulk` compatibility path but prevented destructive broad deactivation by scoping to targeted appliance IDs.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Initial test command path failed due persistent terminal cwd state; resolved by running backend tests from current backend directory.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Backend appliance mutation contracts are now deterministic and concurrency-safe for client-side conflict UX wiring in 08-03.
- No blockers introduced for remaining Phase 8 work.

---

_Phase: 08-appliance-domain-hardening_
_Completed: 2026-03-24_

## Self-Check: PASSED

- FOUND: .planning/phases/08-appliance-domain-hardening/08-02-SUMMARY.md
- FOUND: 36d3241
- FOUND: 5766588
