# Phase 8: Appliance Domain Hardening - Research

**Researched:** 2026-03-24
**Domain:** Appliance CRUD hardening (Express + Mongoose + Flutter Riverpod)
**Confidence:** HIGH

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| APP-01 | User can add an appliance with validated fields and receive success or error feedback. | Route-level request validation, deterministic success/error envelope, and client-side field mapping guidance. |
| APP-02 | User can edit appliance details without losing unrelated appliance records. | Replace destructive bulk overwrite with per-item PATCH semantics or guarded bulk transaction strategy. |
| APP-03 | User can delete an appliance with confirmation and immediate list refresh. | Soft-delete contract + confirmation UX + optimistic local update with rollback/reload fallback. |
| APP-04 | Appliance updates are concurrency-safe to avoid overwriting newer data from another session. | Optimistic concurrency strategy (document version/ETag + precondition checks) and conflict response model. |

</phase_requirements>

## Summary

Phase 8 should be a hardening phase, not a rewrite. The backend already exposes appliance CRUD endpoints under `/api/v1/appliances`, and the app already has a Manage Appliances flow. The main risk is that current mobile save behavior still posts a full replacement list to `/appliances/bulk`, while backend bulk behavior deactivates all active records then recreates from the payload. This is destructive under partial edits and highly vulnerable to multi-session stale writes.

The current backend appliance routes do not apply `validation.middleware` and rely primarily on Mongoose/runtime errors for malformed input handling. That undermines deterministic field-level feedback and weakens APP-01/APP-02 acceptance quality. In parallel, the current profile domain already demonstrates the desired shape: route-bound validation, normalized error envelopes with `details[]`, typed repository exceptions, and explicit retry UX states. Phase 8 should mirror those proven patterns.

Concurrency safety for APP-04 needs explicit preconditions. As currently implemented, `findOneAndUpdate()` is atomic for a single operation, but there is no stale-write check for "client edited older snapshot" cases. Recommended direction: enforce optimistic concurrency with version checks (`__v`/revision token) and return conflict responses when versions mismatch, plus client conflict recovery guidance.

**Primary recommendation:** Move appliance mutations to validated per-resource contracts (`POST`, `PATCH /:id`, `DELETE /:id`) with optimistic concurrency preconditions; keep `/bulk` only as a guarded migration/backward-compatible path.

## Architecture Map

### Current Flow (Observed)

```text
Flutter UI
  profile_screen.dart -> manage_appliances_screen.dart -> add_appliance_screen.dart
    -> onBoardingPage5Provider.finishSetup(selectedAppliances)
      -> ApplianceRepository.saveAppliances()
        -> POST /api/v1/appliances/bulk

Backend
  routes/index.js -> /appliances -> routes/appliance.routes.js
    -> appliance.controller.updateAppliancesBulk()
      -> updateMany(isActive=false) for all current user appliances
      -> insertMany(new list)
```

### Target Hardened Flow

```text
Flutter
  ManageAppliancesNotifier (feature/profile domain)
    - load list
    - create appliance
    - patch appliance (with revision)
    - delete appliance (with confirmation)
    - reconcile conflict/retry

Backend
  appliance.routes.js
    - POST /appliances           + validate(createAppliance)
    - PATCH /appliances/:id      + validate(patchAppliance)
    - DELETE /appliances/:id     + validate(deleteAppliance)
    - optional POST /bulk (guarded and explicit)

  appliance.controller.js
    - deterministic envelope
    - conflict detection (412/409) for stale writes
    - non-destructive per-record updates
```

### Key Gaps Found

- Mobile save path is bulk replace, not granular mutation (`wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart`).
- Bulk endpoint deactivates all and recreates, causing unrelated-record loss risk under partial payload (`backend/src/controllers/appliance.controller.js`).
- No route-level validation attached on appliance routes (`backend/src/routes/appliance.routes.js`).
- No explicit optimistic concurrency contract for `PATCH /appliances/:id`.
- Manage screen save branch checks `if (!mounted)` before success snackbar/navigation, which suppresses intended success UX on mounted state (`wattwise_app/lib/feature/profile/screens/manage_appliances_screen.dart`).

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| express | 5.2.1 | Route/middleware pipeline | Existing backend architecture and middleware composition are already Express-first. |
| mongoose | 9.3.2 (latest), repo currently 9.2.3 | Persistence + schema + atomic updates | Existing model stack uses Mongoose, including appliance schema/indexes and soft-delete fields. |
| zod | 4.3.6 | Request contract validation | Existing deterministic validation envelope (`details[]`) already implemented in middleware. |
| flutter_riverpod | 2.6.1 (locked) | UI state and async orchestration | Existing profile hardening patterns already use Riverpod notifier + retry state model. |
| dio | 5.9.1 (locked) | Authenticated API client + typed error path | Existing interceptor stack already handles auth and maps network exceptions. |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| jest | 30.3.0 (latest), repo currently 30.2.0 | Backend contract/unit tests | Route and controller contract hardening for appliance endpoints. |
| supertest | 7.2.2 | HTTP contract tests | Endpoint-level behavior, status codes, and error envelope assertions. |
| flutter_test | SDK | Provider/widget tests | Retry, conflict messaging, and immediate list refresh behavior assertions. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Version-token preconditions on PATCH | MongoDB multi-document transaction around bulk replace only | Prevents partial-write inconsistencies but still keeps stale-write risk and payload clobber semantics. |
| Per-resource mutation endpoints | Keep only `/appliances/bulk` | Simpler API surface, but APP-02 and APP-04 remain fragile in multi-session edits. |
| 412 precondition response | 409 conflict response | Both are acceptable; 412 is clearer for failed preconditions (`If-Match`/revision mismatch). |

**Installation:**

```bash
# Phase 8 can be delivered with current stack; no mandatory new dependencies.
# Optional (only if adding API-level tests that use request assertions beyond current setup):
# npm --prefix backend install --save-dev supertest
```

**Version verification (executed 2026-03-24):**

```bash
npm view express version      # 5.2.1 (published 2025-12-01)
npm view mongoose version     # 9.3.2 (published 2026-03-23)
npm view zod version          # 4.3.6 (published 2026-01-22)
npm view jest version         # 30.3.0 (published 2026-03-10)
npm view supertest version    # 7.2.2 (published 2026-01-06)
```

## Concurrency Strategy Options

### Option A (Recommended): Version Token on Resource PATCH

- Mechanism:
  - Client reads appliance with `version` (or `__v`) and sends update with expected version.
  - Server updates using filter `{ _id, userId, isActive: true, __v: expectedVersion }` and increments version.
  - No match => stale write conflict.
- Response:
  - `412 Precondition Failed` (preferred) or `409 Conflict` with deterministic envelope and conflict hint.
- Why best fit:
  - Smallest change from current per-document update flow.
  - Directly addresses APP-04 without introducing cross-document transaction complexity.

### Option B: HTTP ETag/If-Match Preconditions

- Mechanism:
  - GET returns `ETag` derived from revision.
  - PATCH/DELETE must include `If-Match`.
  - Mismatch => `412`.
- Pros:
  - Standards-aligned for lost-update prevention.
  - Explicit API contract and cache-friendly semantics.
- Cons:
  - Slightly more plumbing in Express + mobile client header handling.

### Option C: Transactional Bulk Replace + Client Revision Gate

- Mechanism:
  - Keep `/bulk` but require `baseRevision` and run deactivate+insert in transaction.
- Pros:
  - Useful if onboarding compatibility requires full-list saves.
- Cons:
  - Larger write set; still conceptually clobber-oriented; harder to reason about item-level conflicts.

**Recommendation:** Implement Option A in Phase 8 and allow Option B-compatible headers as an extension path.

## API Contract Hardening Checklist

1. Route validation coverage
   - Add `validate("createAppliance")`, `validate("patchAppliance")`, and `validate("deleteAppliance")` schemas.
   - Keep schema strict and emit `details[]` with `path` + `message`.
2. Endpoint semantics
   - `POST /appliances` creates one appliance only.
   - `PATCH /appliances/:id` updates only provided fields and preserves unrelated records.
   - `DELETE /appliances/:id` soft deletes and returns deterministic success envelope.
3. Concurrency contract
   - Require expected version token for PATCH/DELETE.
   - Return `412` (or `409`) with machine-readable error code on mismatch.
4. Deterministic envelope alignment
   - Success: `{ success: true, message, data? }`.
   - Error: `{ success: false, message, errorCode, details?, requestId, timestamp }`.
5. Backward compatibility control
   - Keep `/bulk` temporary; mark as compatibility path with explicit deprecation timeline.
6. Ownership and active-state guard
   - Every mutation filter must include `userId` and `isActive: true` where appropriate.
7. Refresh contract
   - After mutation, return updated resource (or at least ID + version) so client can reconcile without blind full refetch.

## Architecture Patterns

### Recommended Project Structure

```text
backend/src/
  controllers/appliance.controller.js
  routes/appliance.routes.js
  middleware/validation.middleware.js
  models/Appliance.model.js

wattwise_app/lib/feature/profile/
  provider/appliance_provider.dart          # new domain notifier for CRUD state
  repository/appliance_profile_repository.dart # new typed repository + exception mapping
  screens/manage_appliances_screen.dart
  screens/add_appliance_screen.dart
```

### Pattern 1: Contract-First Route Guard

**What:** Validate payload shape before controller logic.
**When to use:** All appliance mutation routes.
**Example:**

```javascript
// Source: repo pattern in user.routes.js + validation.middleware.js
router.patch('/:id', rateLimiters.strict, validate('patchAppliance'), applianceController.updateAppliance);
```

### Pattern 2: Repository Exception Mapping (Flutter)

**What:** Convert Dio/API errors into typed domain exceptions (validation vs retryable request errors).
**When to use:** Appliance create/update/delete operations.
**Example:**

```dart
// Source: profile_repository.dart pattern
if (apiError.statusCode == 400 && fieldErrors.isNotEmpty) {
  throw ApplianceValidationException(message: apiError.message, fieldErrors: fieldErrors);
}
throw ApplianceRequestException(message: apiError.message, isRetryable: apiError.isNetworkError || apiError.isServerError || apiError.statusCode == 409 || apiError.statusCode == 412);
```

### Pattern 3: Optimistic UI + Reconciliation

**What:** Update local list immediately for better UX, then reconcile with server response or rollback on failure/conflict.
**When to use:** Delete and edit in manage list.
**Example:**

```dart
// Source: existing Riverpod notifier patterns in profile_provider.dart
// 1) apply optimistic local mutation
// 2) attempt API call
// 3) on failure -> rollback + show retry/conflict guidance
```

### Anti-Patterns to Avoid

- **Destructive replace for simple edits:** Posting entire list to `/bulk` from Manage screen for each save.
- **Controller-only validation:** Allowing malformed fields to reach database layer and produce non-deterministic messages.
- **Silent stale overwrite:** Accepting PATCH without version precondition in multi-session scenarios.
- **Generic retry text without action:** Showing "Error saving" with no guidance on what user should do next.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Validation envelope shaping | Custom per-controller ad-hoc error JSON | Existing `validation.middleware.js` + centralized `errorHandler.js` | Already supports deterministic `VALIDATION_ERROR` with field-level `details[]`. |
| Concurrency lock manager | In-memory lock map per Node instance | DB-backed optimistic concurrency using version fields | In-memory locks break under multi-instance deployment and restarts. |
| Retry state machine in widgets | Multiple widget booleans (`isSaving`, `isError`) only | Riverpod notifier operation state (profile pattern) | Prevents state drift and simplifies testability. |
| Bulk merge algorithm on client | Full-list replacement diffing | Item-level CRUD API with server ownership checks | Reduces accidental record loss and stale overwrite risk. |

**Key insight:** The hard part is not CRUD endpoints; it is preserving data integrity under partial, stale, and retried writes.

## Retry/Recovery UX Guidance

1. Failure taxonomy in UI
   - Validation failure (400): show inline field errors near edited controls.
   - Conflict (412/409): show "This appliance was changed elsewhere" with actions: `Reload` and `Review Changes`.
   - Network/server transient (5xx/timeout/offline): show retry banner with safe retry action.
2. Preserve user intent
   - Keep unsaved draft values on failure; do not reset controls.
3. Immediate feedback path
   - Save button states: `idle -> saving -> success|error`.
   - On delete, require confirmation then optimistic remove with undo/reload fallback if API fails.
4. Recovery copy (recommended)
   - Conflict: "We found a newer appliance version. Reload latest data, then re-apply your edits."
   - Retryable: "Could not reach server. Check connection and tap Retry."
5. Deterministic refresh
   - After successful create/update/delete, refresh list provider (or patch local cache) immediately.

## Common Pitfalls

### Pitfall 1: Record loss through full-list replacement

**What goes wrong:** Editing one item deactivates others not included in payload.
**Why it happens:** `/bulk` deactivates all active appliances before insert.
**How to avoid:** Use per-item PATCH/DELETE for manage flow; reserve bulk for explicit migration cases.
**Warning signs:** User reports "other appliances disappeared" after saving.

### Pitfall 2: Hidden stale-write overwrite

**What goes wrong:** Later save from older session silently overwrites newer edit.
**Why it happens:** No revision precondition in update filter.
**How to avoid:** Require expected revision/version and reject mismatches.
**Warning signs:** Conflicting values after concurrent edits from multiple devices.

### Pitfall 3: Inconsistent error payload parsing on Flutter

**What goes wrong:** App shows generic snackbar for field-level validation errors.
**Why it happens:** Repository not mapping `details[]` into domain field errors.
**How to avoid:** Copy profile repository exception-mapping pattern for appliance domain.
**Warning signs:** 400 responses with details present, but no inline hints in UI.

### Pitfall 4: Transaction misuse for bulk writes

**What goes wrong:** Parallel operations inside a transaction create undefined behavior.
**Why it happens:** Using `Promise.all` within transaction executor.
**How to avoid:** Keep transaction operations sequential.
**Warning signs:** Intermittent transaction errors under load.

## Code Examples

Verified patterns from official sources and repo conventions:

### Optimistic concurrency with version key (Mongoose)

```javascript
// Source: https://mongoosejs.com/docs/guide.html (versionKey, optimisticConcurrency)
const appliance = await Appliance.findOneAndUpdate(
  {
    _id: req.params.id,
    userId: req.user._id,
    isActive: true,
    __v: req.body.expectedVersion,
  },
  {
    $set: { ...req.body.patch, lastUpdated: new Date() },
    $inc: { __v: 1 },
  },
  { returnDocument: 'after', runValidators: true },
);

if (!appliance) {
  throw new ApiError(412, 'Precondition failed: appliance was updated elsewhere.');
}
```

### HTTP precondition semantics

```http
# Source: MDN If-Match + 412 docs
PATCH /api/v1/appliances/abc123
If-Match: "7"

# if current version != 7
HTTP/1.1 412 Precondition Failed
```

### Flutter retry-state pattern

```dart
// Source: profile_provider.dart pattern in repo
state = const AsyncLoading();
state = await AsyncValue.guard(() async => repository.fetchAppliances());
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Blind overwrite updates | Conditional updates with optimistic concurrency preconditions | Matured across REST API practices; current HTTP semantics docs | Prevents lost updates in multi-session edits. |
| Controller-centric validation only | Route-bound schema validation + deterministic envelopes | Common modern API contract-first practice | Better client parsing, safer refactors, and clearer UX errors. |
| Full-list mutation for routine edits | Resource-level CRUD | Broadly standard for mutable collections | Lower blast radius and easier conflict handling. |

**Deprecated/outdated:**

- Treating Mongoose default versioning as complete optimistic concurrency for all update methods; docs explicitly note this is not full OCC for `findOneAndUpdate()` unless implemented.

## Open Questions

1. Should `/appliances/bulk` remain public for profile manage flow or only onboarding migration?
   - What we know: Current app uses bulk for manage save.
   - What's unclear: Backward compatibility requirements for older app builds.
   - Recommendation: Keep temporarily with explicit compatibility tag and migrate manage flow to item-level CRUD in this phase.

2. Conflict status code choice (`409` vs `412`)?
   - What we know: Either can communicate conflict; `412` is most semantically aligned with precondition headers/tokens.
   - What's unclear: Existing client/global error handler expectations for specific status classes.
   - Recommendation: Use `412` for precondition mismatch and reserve `409` for semantic domain conflicts (duplicate IDs, etc.).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Jest 30.x (`backend`), flutter_test (`wattwise_app`) |
| Config file | none explicit; script-driven via `backend/package.json` and Flutter defaults |
| Quick run command | `npm --prefix backend test -- --runInBand --testPathPatterns appliance` |
| Full suite command | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| APP-01 | Create appliance validates fields and returns deterministic success/error envelopes | backend contract/unit | `npm --prefix backend test -- --runInBand --runTestsByPath tests/appliance.contract.test.js` | ❌ Wave 0 |
| APP-02 | Edit one appliance does not remove unrelated records | backend integration + provider test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/appliance.non_destructive.test.js` | ❌ Wave 0 |
| APP-03 | Delete requires confirmation and refreshes list immediately | flutter widget/provider + backend contract | `cd wattwise_app && flutter test test/feature/profile/manage_appliances_delete_flow_test.dart` | ❌ Wave 0 |
| APP-04 | Stale-write attempts are rejected with conflict semantics | backend contract + flutter provider conflict test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/appliance.concurrency.contract.test.js` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** targeted backend appliance tests + one relevant Flutter profile/appliance test.
- **Per wave merge:** full backend Jest suite.
- **Phase gate:** full backend Jest + targeted Flutter appliance suite + manual two-session conflict walkthrough.

### Wave 0 Gaps

- [ ] `backend/tests/appliance.contract.test.js` - create/update/delete envelope and validation assertions.
- [ ] `backend/tests/appliance.non_destructive.test.js` - verify unrelated active records survive single-item edits.
- [ ] `backend/tests/appliance.concurrency.contract.test.js` - stale version conflict contract.
- [ ] `wattwise_app/test/feature/profile/manage_appliances_retry_states_test.dart` - retry, conflict copy, and draft preservation.
- [ ] `wattwise_app/test/feature/profile/manage_appliances_delete_flow_test.dart` - confirmation + immediate list refresh.

## Sources

### Primary (HIGH confidence)

- Repository code:
  - `backend/src/controllers/appliance.controller.js`
  - `backend/src/routes/appliance.routes.js`
  - `backend/src/middleware/validation.middleware.js`
  - `backend/src/models/Appliance.model.js`
  - `wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart`
  - `wattwise_app/lib/feature/profile/screens/manage_appliances_screen.dart`
  - `wattwise_app/lib/feature/profile/repository/profile_repository.dart`

- Official docs:
  - Mongoose schema/optimistic concurrency docs: https://mongoosejs.com/docs/guide.html
  - Mongoose `findOneAndUpdate` docs: https://mongoosejs.com/docs/tutorials/findoneandupdate.html
  - Mongoose transactions docs: https://mongoosejs.com/docs/transactions.html
  - MDN `If-Match`: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Match
  - MDN `412 Precondition Failed`: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/412

### Secondary (MEDIUM confidence)

- npm registry package metadata via `npm view` (versions + publish timestamps).

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - verified in workspace manifests and npm registry output.
- Architecture: HIGH - based on concrete backend/frontend flow tracing in repo.
- Pitfalls: HIGH - directly observed code-path risks plus official concurrency semantics.

**Research date:** 2026-03-24
**Valid until:** 2026-04-23