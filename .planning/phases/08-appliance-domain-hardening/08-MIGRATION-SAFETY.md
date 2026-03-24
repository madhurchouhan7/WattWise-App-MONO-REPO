# Phase 08 Migration Safety Runbook

Status: Frozen before runtime hardening work.

Goal: Introduce deterministic appliance mutation behavior while preserving existing clients and preventing destructive data loss.

## Requirement Coverage

- APP-01: deterministic success/error behavior for add/edit/delete.
- APP-02: no loss of unrelated appliance records during updates.
- APP-04: stale edit conflicts return recoverable `412` response.

## Rollout Order

1. Deploy contract-aligned validation and response envelopes first.
2. Enable concurrency precondition handling on `PATCH /api/v1/appliances/:id`.
3. Harden `POST /api/v1/appliances/bulk` to compatibility guardrails.
4. Move mobile/app clients to canonical create/patch/delete flows.
5. Decommission legacy dependency on bulk replace semantics after telemetry confirms no usage.

## Compatibility and Fallback

During transition window:

- Keep `POST /api/v1/appliances/bulk` available for older app versions.
- Route bulk writes through non-destructive logic:
  - only deactivate records whose IDs are included in payload,
  - preserve unrelated active records,
  - never hard-delete historical rows.
- If precondition token is absent on patch, server MAY run in compatibility mode for a limited period:
  - accept update,
  - emit deprecation marker in logs,
  - return migration warning header for clients.

## Bulk Endpoint Guardrails

`POST /api/v1/appliances/bulk` is temporary and bounded by the following controls:

- Validation gate: malformed arrays fail with `400 VALIDATION_ERROR` and `details[]`.
- Scope gate: update filter must include touched appliance IDs.
- Audit gate: emit structured log events for touched IDs, untouched count, and requestId.
- Kill switch: environment flag disables legacy bulk write path if corruption risk is detected.

## Concurrency Safety

For `PATCH /api/v1/appliances/:id`:

- Require revision token (`If-Match` or `_expectedVersion` during migration).
- On stale token mismatch, return `412 PRECONDITION_FAILED`.
- Include retry-safe guidance in `details[]`.
- Never silently overwrite newer data.

## Rollback Procedure (Data-Safe)

Use this procedure if release health degrades.

1. Stop new migration behavior behind feature flag (leave reads enabled).
2. Keep compatibility `bulk` endpoint online in guarded mode.
3. Restore previous mutation handler code path for canonical endpoints.
4. Replay audit logs to verify APP-02 integrity:
  - no unrelated appliance deactivations,
  - no hard deletes,
  - per-user active appliance counts within expected deltas.
5. If anomaly found, run targeted restore from pre-deploy snapshot for impacted users only.
6. Publish incident note with request correlation IDs and timeline.

## Verification Commands

- Contract trace check:
  - `grep -nE "APP-01|APP-02|APP-04|412|details\[\]|bulk|rollback" .planning/phases/08-appliance-domain-hardening/08-CONTRACT-MATRIX.md .planning/phases/08-appliance-domain-hardening/08-MIGRATION-SAFETY.md`
- Wave-0 backend checks:
  - `npm --prefix backend test -- --runInBand tests/appliance.contract.test.js tests/appliance.non_destructive.test.js tests/appliance.concurrency.contract.test.js tests/appliance.validation.test.js`

## Exit Criteria

- Compatibility period has a dated sunset decision.
- APP-02 non-destructive assertions are green in CI.
- APP-04 stale-write conflict tests are green with `412` behavior.
- Bulk endpoint deprecation plan is approved and documented.
