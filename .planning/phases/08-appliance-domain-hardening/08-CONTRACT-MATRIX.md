# Phase 08 Appliance Mutation Contract Matrix

Status: Frozen for implementation plans 08-02 and 08-03.

Scope: `POST /api/v1/appliances`, `PATCH /api/v1/appliances/:id`, `DELETE /api/v1/appliances/:id`, and temporary compatibility path `POST /api/v1/appliances/bulk`.

## Envelope Rules

All mutation endpoints MUST return normalized envelopes.

### Success envelope

```json
{
  "success": true,
  "message": "<deterministic message>",
  "data": { "...": "endpoint payload" }
}
```

### Error envelope

```json
{
  "success": false,
  "message": "Validation failed",
  "errorCode": "VALIDATION_ERROR",
  "timestamp": "2026-03-24T00:00:00.000Z",
  "requestId": "<request-id>",
  "details": [
    {
      "path": "field.path",
      "message": "human readable reason"
    }
  ]
}
```

For non-validation failures where field-level guidance is not available, `details[]` MAY be omitted.

## Endpoint Matrix

| Endpoint                                       | Purpose                                  | Success                                                         | Deterministic error contract                                                                                           | Requirement trace |
| ---------------------------------------------- | ---------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `POST /api/v1/appliances`                      | Add one appliance                        | `201` + `success=true` + created appliance in `data`            | `400 VALIDATION_ERROR` with `details[]`; `401` auth; `409 DUPLICATE_ERROR` when uniqueness guard is introduced         | APP-01            |
| `PATCH /api/v1/appliances/:id`                 | Edit one appliance                       | `200` + updated appliance in `data`                             | `400 VALIDATION_ERROR` + `details[]`; `404` not found; `412 PRECONDITION_FAILED` on stale write with recovery guidance | APP-01, APP-04    |
| `DELETE /api/v1/appliances/:id`                | Soft delete one appliance                | `200` + deterministic message `Appliance deleted successfully.` | `404` not found; `401` auth                                                                                            | APP-01            |
| `POST /api/v1/appliances/bulk` (compatibility) | Temporary bridge for legacy client saves | `200` + resulting appliance list in `data`                      | `400 VALIDATION_ERROR` + `details[]`; MUST NOT silently remove unrelated records                                       | APP-02            |

## Conflict Semantics (APP-04)

`PATCH /api/v1/appliances/:id` MUST enforce conditional update semantics.

- Client sends precondition token using one of:
  - `If-Match: "<revision>"`, or
  - body field `_expectedVersion` during transition.
- Server behavior:
  - If token matches latest revision, apply update and return `200`.
  - If token is stale, return `412 PRECONDITION_FAILED` with recoverable payload.

Conflict payload contract:

```json
{
  "success": false,
  "message": "Precondition failed: stale appliance revision.",
  "errorCode": "PRECONDITION_FAILED",
  "details": [
    {
      "path": "revision",
      "message": "Client revision does not match latest appliance state. Refresh and retry."
    }
  ]
}
```

## Validation Shape (APP-01)

Validation failures MUST keep deterministic `details[]` shape.

- Each entry MUST contain:
  - `path`: normalized dot path (for example `appliances.0.usageHours`)
  - `message`: deterministic user-safe text
- Unsupported fields MUST emit `message: "Unsupported field"`.

## Bulk Compatibility Guardrails (APP-02)

While `POST /bulk` remains enabled:

- It is compatibility-only, not canonical behavior.
- It MUST be constrained to touched appliance IDs; unrelated active records must remain unchanged.
- It MUST preserve soft-delete semantics via `isActive` instead of hard delete.
- It MUST reject malformed payloads with `400 VALIDATION_ERROR` and `details[]`.

## Trace Notes

- APP-01: Deterministic add/edit/delete success and error envelopes.
- APP-02: Bulk compatibility path cannot destructively deactivate unrelated records.
- APP-04: Stale write handling uses `412 PRECONDITION_FAILED` with retry-friendly `details[]` guidance.
