---
phase: 11
slug: reliability-and-milestone-closure
artifact: reliability-matrix
status: complete
created: 2026-03-27
updated: 2026-03-27
requirements:
  - NFR-01
---

# Phase 11 Reliability Matrix

This matrix defines expected loading, empty, error, and retry behavior across all v2.1 utility surfaces.

## Coverage Matrix

| Surface                        | Loading Behavior                                                             | Empty Behavior                                                          | Error Behavior                                                                         | Retry Behavior                                                                        | Evidence                                               |
| ------------------------------ | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Profile                        | Profile details placeholders/skeleton while data fetch is in flight.         | Missing optional profile fields render safe defaults, not crash states. | Deterministic inline error copy with clear action guidance.                            | Explicit retry action triggers provider refetch and restores steady state on success. | Phase 07 verification + profile provider/screen tests  |
| Appliances                     | Manage Appliances list shows in-progress status for fetch/mutation requests. | Empty list state explains no appliances and keeps create CTA visible.   | Validation or network failures map to deterministic message taxonomy.                  | User can retry failed create/update/delete without losing pending intent context.     | Phase 08 verification + contract/provider/widget tests |
| Content (FAQ/Bill Guide/Legal) | Content cards show progress indicator during retrieval/refresh.              | Missing published records fall back to deterministic defaults.          | Fetch failures show recoverable state and preserve last stable content when available. | Retry/refetch path reruns content query and updates only when ETag/content changed.   | Phase 09 verification + content route/client tests     |
| Support                        | Contact Support submit state disables duplicate sends and shows progress.    | Empty optional fields are validated with stable field-level guidance.   | Temporary failures return actionable retry guidance with request context.              | Retry path preserves draft and reuses validated payload after transient recovery.     | Phase 10 verification + support provider/repo tests    |
| Solar                          | Estimate action shows in-progress state and avoids stale result overwrite.   | Pre-calc state communicates required inputs before estimate.            | Validation/server failures surface deterministic error copy and preserve valid inputs. | Retry/recalculate path recomputes ranges from current valid draft inputs.             | Phase 10 verification + solar provider/repo tests      |

## Scenario Checklist

| Scenario ID | Surface    | Scenario                                     | Expected Result                                     | Requirement |
| ----------- | ---------- | -------------------------------------------- | --------------------------------------------------- | ----------- |
| REL-01      | Profile    | Initial profile fetch fails once             | User sees recoverable error and retry CTA           | NFR-01      |
| REL-02      | Appliances | Mutation conflict/precondition failure       | Deterministic conflict message + guided retry       | NFR-01      |
| REL-03      | Content    | Legal refresh returns unchanged ETag         | UI communicates unchanged content deterministically | NFR-01      |
| REL-04      | Support    | Ticket submit receives temporary unavailable | Retry guidance appears and draft remains intact     | NFR-01      |
| REL-05      | Solar      | Recalculate after failed request             | Retry succeeds and updates range outputs            | NFR-01      |

## Notes

- This artifact is the canonical reliability reference for phase-level negative-path execution in 11-02.
- All rows map to deterministic behavior expectations before milestone closure.
