---
phase: 08-appliance-domain-hardening
plan: 04
subsystem: ui
tags: [flutter, appliance-mutations, contract-alignment, concurrency]
requires:
  - phase: 08-03
    provides: manage-appliances mutation orchestration and recovery UX states
provides:
  - Manage Appliances save payloads aligned to backend usageHoursPerDay contract
  - DELETE precondition transport aligned with backend body._expectedVersion schema
  - Expected-version extraction now includes backend __v for deterministic stale-write handling
affects: [profile, appliance-domain-hardening, backend-validation-contract]
tech-stack:
  added: []
  patterns:
    - Preserve If-Match header while duplicating version precondition in request body when required by backend schema
    - Derive expected-version tokens from a fallback chain including __v
key-files:
  created:
    - .planning/phases/08-appliance-domain-hardening/08-04-SUMMARY.md
  modified:
    - wattwise_app/lib/feature/profile/screens/manage_appliances_screen.dart
    - wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart
    - wattwise_app/test/feature/profile/manage_appliances_retry_states_test.dart
    - wattwise_app/test/feature/profile/manage_appliances_delete_flow_test.dart
key-decisions:
  - "Mapped client draft payload usage hours to usageHoursPerDay to match backend create/patch schema exactly."
  - "Sent DELETE precondition token in both body._expectedVersion and If-Match header for compatibility with strict backend validation and existing transport behavior."
  - "Expanded expected-version fallback chain to include backend __v in both screen-level baseline extraction and repository-level envelope parsing."
patterns-established:
  - "Contract-first regression coverage: encode request-shape and token-derivation rules in focused tests before implementation."
requirements-completed: [APP-01, APP-03, APP-04]
duration: 9min
completed: 2026-03-26
---

# Phase 8 Plan 04: Gap Closure Summary

**Manage Appliances client contract drift was fully closed by normalizing payload field names, delete precondition transport, and \_\_v token extraction with targeted regression coverage.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-26T18:36:05+05:30
- **Completed:** 2026-03-26T13:15:08Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added RED regression tests that reproduced all three verification blockers from 08-VERIFICATION.
- Updated Manage Appliances payload and version-token mapping to align with backend create/patch/delete contracts.
- Verified closure with both Flutter client tests and backend appliance contract tests.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add regression tests for payload/delete/version contract mapping gaps** - `159f73f` (test)
2. **Task 2: Implement client contract alignment for create/patch/delete and stale-write tokens** - `bc59ee9` (feat)

## Files Created/Modified

- `.planning/phases/08-appliance-domain-hardening/08-04-SUMMARY.md` - Plan execution record, decisions, and verification evidence.
- `wattwise_app/test/feature/profile/manage_appliances_retry_states_test.dart` - Regression tests for delete precondition body and \_\_v expected-version fallback mapping.
- `wattwise_app/test/feature/profile/manage_appliances_delete_flow_test.dart` - Regression widget test proving save flow sends usageHoursPerDay contract field.
- `wattwise_app/lib/feature/profile/screens/manage_appliances_screen.dart` - usageHoursPerDay payload mapping and \_\_v-aware version extraction.
- `wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart` - DELETE body.\_expectedVersion transport and \_\_v fallback in expected-version derivation.

## Decisions Made

- Keep delete precondition in `If-Match` header for backward compatibility while adding required `body._expectedVersion` to satisfy backend validator contract.
- Enforce backend contract naming at payload source (`usageHoursPerDay`) rather than patching downstream to prevent future drift.
- Apply `__v` fallback in both UI baseline extraction and repository envelope parsing so stale-write retries remain deterministic across entry points.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Initial verification command used an incorrect nested working directory (`cd wattwise_app` while already in that directory). Re-ran from correct directory and proceeded without code changes.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All three Phase 8 verification blockers listed in 08-VERIFICATION are closed with test coverage and passing automation.
- Manage Appliances add/edit/delete and stale-write token paths now match backend request/validation contracts.

## Self-Check: PASSED

- FOUND_FILE: .planning/phases/08-appliance-domain-hardening/08-04-SUMMARY.md
- FOUND_COMMIT: 159f73f
- FOUND_COMMIT: bc59ee9

---

_Phase: 08-appliance-domain-hardening_
_Completed: 2026-03-26_
