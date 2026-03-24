# Phase 7 Contract Matrix: Profile and Settings

This matrix freezes profile/settings API contracts for Phase 7 implementation and test wiring.

## Global Envelope Contract

### Success Envelope

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Human-readable status",
  "data": {}
}
```

### Error Envelope

```json
{
  "success": false,
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "code": "INVALID_VALUE",
      "message": "Name must be at least 2 characters"
    }
  ]
}
```

## Frozen Endpoint Matrix

| Endpoint                             | Purpose                                                 | Request Fields                                                                                                                                                                    | Success Response (`data`)                                                                                                                                                                                            | Error Envelope Notes                                                                                                                                                               | Retry Semantics                                                                                                                                    | Persistence Notes                                                                                                           |
| ------------------------------------ | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `GET /api/v1/users/me`               | Load profile/settings source of truth                   | None                                                                                                                                                                              | Full user profile object including `name`, `avatarUrl`, `monthlyBudget`, `currency`, `household`, `planPreferences`, `onboardingCompleted`, `streak`, `lastCheckIn`, optional lightweight profile fields used by app | `401` unauthorized, `404` user not found, `500` transient backend/cache failures                                                                                                   | Retry allowed for `5xx` and network failures with bounded client retry (max 2 attempts, exponential backoff). No retry on `401/403` until re-auth. | Response is canonical source for profile screen hydration and local cache refresh.                                          |
| `PUT /api/v1/users/me`               | Save profile edits and settings mutations               | Any subset of: `name`, `avatarUrl`, `monthlyBudget`, `currency`, `address`, `onboardingCompleted`, `household`, `planPreferences`, optional `activePlan`, `streak`, `lastCheckIn` | **Frozen strategy:** always return the updated full profile payload in `data` after every successful update (including non-`activePlan` updates)                                                                     | `400` invalid payload (field-level `errors[]` required), `401/403` auth issues, `404` user not found, `409` conflicting mutation (if applicable), `500` transient backend failures | Retry only for network/`5xx` or explicit retryable `409` responses. Do not auto-retry `400` validation failures; surface inline field messages.    | Updated payload must be directly persisted client-side and reflected after restart (PRO-01/PRO-04 verification dependency). |
| `PATCH /api/v1/users/me/household`   | Settings companion endpoint for household-only updates  | Partial household object (`peopleCount`, `familyType`, `houseType`)                                                                                                               | Updated user profile payload (or profile subset containing updated household block)                                                                                                                                  | Same normalized error envelope. `errors[].field` should include `household.peopleCount`, etc.                                                                                      | Retry for network/`5xx` only. Validation errors are non-retryable until corrected.                                                                 | If used, must remain consistent with `PUT /users/me` semantics and cache invalidation.                                      |
| `PATCH /api/v1/users/me/preferences` | Settings companion endpoint for preference-only updates | Partial preferences object (`mainGoals`, `focusArea`, related preference fields)                                                                                                  | Updated user profile payload (or profile subset containing updated preferences block)                                                                                                                                | Same normalized error envelope. `errors[].field` should include `planPreferences.mainGoals`, etc.                                                                                  | Retry for network/`5xx` only. Validation errors are non-retryable until corrected.                                                                 | Companion path may be used by focused settings flows but cannot diverge from frozen profile field schema.                   |

## Field Mapping Contract

| API Field         | App/UI Mapping                                       | Notes                                           |
| ----------------- | ---------------------------------------------------- | ----------------------------------------------- |
| `name`            | Display name and edit profile name input             | Primary editable identity field.                |
| `avatarUrl`       | Profile avatar image URL                             | Null/empty means fallback avatar UI.            |
| `monthlyBudget`   | Budget display and budget-edit controls              | Numeric currency-aware value.                   |
| `currency`        | Currency formatting for budget and billing summaries | Defaults handled server-side if absent.         |
| `household`       | Settings household section                           | Nested object, field-level validation expected. |
| `planPreferences` | Settings preference section                          | Nested object, supports partial updates.        |

## Contract Locks

- Lock 1: `GET /api/v1/users/me` is the canonical profile read endpoint for Phase 7.
- Lock 2: `PUT /api/v1/users/me` is the canonical profile save endpoint for Edit Profile flow.
- Lock 3: `PUT /api/v1/users/me` must return full updated profile payload on success (no lightweight ack-only response).
- Lock 4: All profile/settings endpoints use normalized success envelope and error envelope.
- Lock 5: Retry behavior is bounded and only for transient failure classes.

## Test Wiring Notes

- Backend contract tests in `backend/tests/profile.contract.test.js` validate envelope shape and frozen load/save response behavior.
- Backend validation tests in `backend/tests/profile.validation.test.js` validate field-level `errors[]` mapping.
- Flutter profile tests consume this matrix to enforce load, validation, and persistence states without endpoint drift.
