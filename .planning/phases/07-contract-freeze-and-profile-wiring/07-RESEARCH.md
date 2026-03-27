# Phase 7: Contract Freeze and Profile Wiring - Research

**Researched:** 2026-03-23
**Domain:** Profile contract stabilization (Express + Flutter Riverpod)
**Confidence:** HIGH

## User Constraints

No `*-CONTEXT.md` file exists yet for this phase. Constraints are taken from roadmap + requirements only.

### Locked Decisions

- Phase 7 scope is `Contract Freeze and Profile Wiring`.
- Must cover requirements: `PRO-01`, `PRO-02`, `PRO-03`, `PRO-04`.
- Keep existing architecture (Express backend, Flutter + Riverpod client); no migration away from Riverpod.

### the agent's Discretion

- Exact response contract shape for profile update path (`PUT /users/me`) as long as it is frozen and documented.
- Riverpod provider composition for profile load/edit UX.
- Test granularity for profile contract and provider behavior.

### Deferred Ideas (OUT OF SCOPE)

- Appliance hardening (Phase 8).
- Content hub endpoints (Phase 9).
- Support/Solar workflows (Phase 10).
- Cross-feature reliability closure (Phase 11).

<phase_requirements>

## Phase Requirements

| ID     | Description                                                                                              | Research Support                                                                                             |
| ------ | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| PRO-01 | User can view current profile details and settings with clear loading and error states.                  | Contract matrix + Riverpod `AsyncValue` wiring pattern + retry strategy on `/users/me`.                      |
| PRO-02 | User can edit profile fields (name, avatar, phone or equivalent supported fields) and save successfully. | Frozen `PUT /users/me` request/response schema + editable field map + backend validation alignment guidance. |
| PRO-03 | User sees inline validation feedback for invalid profile inputs before submission.                       | Client-side validator map aligned to backend Zod/User model constraints + error envelope mapping.            |
| PRO-04 | Updated profile data persists and is reflected after app restart or screen revisit.                      | Cache write-through + post-save refresh/invalidate pattern across SharedPreferences and Riverpod providers.  |

</phase_requirements>

## Summary

Phase 7 is primarily a consistency phase, not a feature invention phase. The codebase already has profile-capable backend routes (`GET/PUT /api/v1/users/me`) and a mobile auth/profile fetch path, but there are contract drift points that will cause regressions if implementation starts before freezing the wire contract. The most important drift is response behavior of `PUT /users/me` (sometimes lightweight acknowledgment, sometimes full profile), plus a backend/mobile naming mismatch (`name`/`avatarUrl` in backend vs Firebase `displayName`/`photoUrl` in app model).

The mobile profile screen currently has placeholders for `Edit Profile` and no dedicated profile edit provider/form. Existing Riverpod patterns in the app can be reused, but profile-specific load/save state should be centralized into a dedicated notifier rather than scattered across widgets and auth stream side-effects. This is necessary to satisfy `PRO-01` through `PRO-04` deterministically and to avoid stale UI after save/reopen.

Validation exists in backend infrastructure (`validation.middleware.js`) but is not currently applied on `PUT /users/me`; additionally, there is a schema mismatch (`name` minimum differs between Zod and Mongoose). If Phase 7 does not resolve this mismatch and define one canonical validation contract, inline field validation UX (`PRO-03`) will diverge from server behavior.

**Primary recommendation:** Freeze a single profile API contract first (request schema, response envelope, field names, and error mapping), then implement one Riverpod profile editor flow that owns load/save/retry/cache refresh.

## Architecture Map

### Current Backend Map

- Entry routing: `backend/src/routes/index.js` mounts `/users`.
- Profile endpoints: `backend/src/routes/user.routes.js`
  - `GET /api/v1/users/me`
  - `PUT /api/v1/users/me`
- Controller behavior: `backend/src/controllers/user.controller.js`
  - `getMe`: cache-first profile fetch via `cacheService`.
  - `updateMe`: multi-branch update; returns either ack payload or full profile (activePlan branch).
- Domain logic: `backend/src/services/UserService.js`
  - `getUserProfile` excludes large fields (`bills`, `activePlan`) by default.
  - `updateProfile` allows only `name`, `monthlyBudget`, `currency`, `avatarUrl`, `address`, `onboardingCompleted`.
- Response envelope utilities: `backend/src/utils/ApiResponse.js` + `backend/src/middleware/errorHandler.js`.

### Current Mobile Map

- Profile UI shell: `wattwise_app/lib/feature/profile/screens/profile_screen.dart`
  - `Edit Profile` action currently placeholder (`onTap: () {}`).
- Profile header display: `wattwise_app/lib/feature/profile/widgets/profile_header.dart`
  - Reads `authStateProvider` and displays Firebase-centric fields.
- Auth/profile data source: `wattwise_app/lib/feature/auth/repository/auth_repository.dart`
  - Loads `/users/me`, caches `user_profile_{uid}`, fetches `/users/me/active-plan`.
- Existing API wrapper: `wattwise_app/lib/core/network/api_client.dart`.
- Existing Riverpod patterns for async orchestration: `FutureProvider.autoDispose`, `StateNotifierProvider`, `AsyncNotifierProvider` used across modules.

### Contract Drift Detected

- `ApiConstants.userProfile` is `/users/profile` but active code uses `/users/me` (`wattwise_app/lib/core/network/api_constants.dart` vs repositories).
- Backend validation middleware defines `updateProfile` but is not applied on `PUT /users/me`.
- Validation mismatch: Zod `name` min length 1 vs Mongoose validator min length 2.
- Mobile `UserModel` stores `displayName/photoUrl` while backend returns `name/avatarUrl`; mapping is currently implicit and incomplete.

## Standard Stack

### Core

| Library            | Version (in repo)     | Purpose                                                | Why Standard                                                                                          |
| ------------------ | --------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| express            | ^5.2.1                | HTTP routing/controller middleware                     | Existing backend contract surface already uses Express 5 router layering.                             |
| zod                | ^4.3.6                | Request payload validation                             | Already present in centralized validation middleware and suitable for contract freeze enforcement.    |
| flutter_riverpod   | (unpinned in pubspec) | State management for async profile load/save UI states | Existing app-wide provider architecture is Riverpod-centric; avoid introducing alternate state layer. |
| dio                | ^5.9.1                | Mobile HTTP client/interceptors                        | Existing auth token + error interception already implemented around Dio singleton.                    |
| shared_preferences | ^2.5.4                | Profile cache persistence across app restarts          | Existing auth repository already uses this cache path for profile and active plan persistence.        |

### Supporting

| Library      | Version (in repo) | Purpose                                  | When to Use                                                       |
| ------------ | ----------------- | ---------------------------------------- | ----------------------------------------------------------------- |
| jest         | ^30.2.0           | Backend contract and controller tests    | Contract freeze verification and negative-path regression checks. |
| supertest    | ^7.2.2            | HTTP-level endpoint testing              | Validate envelope and schema behavior of `/users/me` endpoints.   |
| flutter_test | SDK               | Widget/provider tests for profile states | Validate loading/error/success and inline validation UI behavior. |

### Alternatives Considered

| Instead of                        | Could Use                        | Tradeoff                                                                                        |
| --------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------- |
| Riverpod profile notifier         | Bloc/Cubit for this feature only | Adds architecture inconsistency and migration overhead for no Phase-7 value.                    |
| Zod middleware + model validation | Mongoose-only validation         | Loses pre-controller field-level error clarity and inline error contract mapping.               |
| SharedPreferences profile cache   | Hive-only migration now          | Extra migration risk in contract freeze phase; defer unless required by later perf constraints. |

**Installation:**

```bash
# No new libraries required for Phase 7 baseline.
# Use existing stack and add tests.
```

**Version verification:**

```bash
cd backend
npm view express version
npm view zod version
npm view jest version
npm view supertest version
```

## API Contract Freeze Checklist

1. Freeze canonical endpoints:
   - `GET /api/v1/users/me`
   - `PUT /api/v1/users/me`
2. Freeze envelope shape (success and error):
   - Success: `{ success: true, message: string, data?: object }`
   - Error: `{ success: false, message: string, errorCode?: string, details?: [] }`
3. Freeze request schema for profile edit payload (minimum for PRO scope):
   - `name?: string`
   - `avatarUrl?: string`
   - `phone?: string` or explicitly document omitted + “equivalent supported fields” policy
4. Freeze response strategy for `PUT /users/me`:
   - Pick one: always return updated profile OR always return ack and require follow-up GET.
   - Recommendation for Phase 7: return updated profile for profile-edit calls to simplify client sync and PRO-04.
5. Align backend validation layers:
   - Ensure middleware validation and model-level validation are non-conflicting.
   - Resolve `name` min-length inconsistency.
6. Freeze field mapping document:
   - Backend `name` <-> mobile display name
   - Backend `avatarUrl` <-> mobile photo URL
7. Freeze retry semantics:
   - On save failure: preserve form state, show inline/global error, allow retry.
8. Freeze cache invalidation behavior:
   - After successful save, update local cache and invalidate profile provider.
9. Freeze contract tests:
   - Positive and negative cases for GET/PUT envelopes and fields.
10. Freeze changelog note:

- Add versioned contract table in phase docs to prevent silent drift in later phases.

## Architecture Patterns

### Recommended Project Structure

```
wattwise_app/lib/feature/profile/
├── screens/
│   ├── profile_screen.dart
│   └── edit_profile_screen.dart
├── provider/
│   ├── profile_provider.dart
│   └── profile_form_validators.dart
└── repository/
    └── profile_repository.dart

backend/src/
├── routes/user.routes.js
├── controllers/user.controller.js
├── middleware/validation.middleware.js
└── services/UserService.js
```

### Pattern 1: Contract-First Handler Guard

**What:** Apply validation middleware on route boundary for `PUT /users/me`, then keep controller focused on orchestration.
**When to use:** Any user-facing profile mutation endpoint.
**Example:**

```javascript
// Source: backend/src/routes/address.routes.js pattern + Express docs
router.put("/me", validate("updateProfile"), userController.updateMe);
```

### Pattern 2: Riverpod Profile Async State Owner

**What:** Use one profile notifier/provider to own fetch, save, and refresh semantics.
**When to use:** Profile screen/edit screen needs deterministic loading/error/retry flow.
**Example:**

```dart
// Source: Riverpod providers + refs docs
final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.fetchProfile();
  }

  Future<void> save(ProfileUpdateInput input) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    final updated = await repo.updateProfile(input);
    if (!ref.mounted) return;
    state = AsyncData(updated);
  }
}
```

### Pattern 3: UI Error/Retry via AsyncValue + ref.listen

**What:** Render loading/error states from `AsyncValue`; use `ref.listen` for one-off side effects (snackbars/navigation).
**When to use:** Form submit and profile refresh feedback.
**Example:**

```dart
// Source: Riverpod refs docs
ref.listen(profileProvider, (previous, next) {
  if (next.hasError) {
    // show snackbar
  }
});
```

### Anti-Patterns to Avoid

- **Dual source of truth for profile names:** Rendering Firebase `displayName` while updating backend `name` without explicit reconciliation.
- **Validation only in controller/model:** Causes inconsistent field-level feedback and weak inline UX.
- **Widget-triggered provider init side effects:** Riverpod docs warn against init-in-widget patterns due to race behavior.
- **Mixed update response contracts:** Returning full object in one branch and ack in another without client guard code.

## Riverpod Wiring Pattern (Recommended)

1. Create `profileRepositoryProvider` wrapping profile GET/PUT API calls only.
2. Create `profileProvider` (`AsyncNotifierProvider`) as canonical read model.
3. Create `profileEditControllerProvider` for mutable submit flow or keep in same notifier with clear method boundaries.
4. On screen open: `ref.watch(profileProvider)` drives loading/content/error UI.
5. On submit:
   - Run synchronous local validators first (name/avatar/phone or equivalent).
   - If valid, call notifier `save`.
   - On success: patch cache + `ref.invalidate(profileProvider)` or set `AsyncData(updated)`.
6. Use `ref.listen` for submit side effects (toast/snackbar/navigation), not inside provider init.

## Don't Hand-Roll

| Problem                | Don't Build                                                          | Use Instead                                        | Why                                                                  |
| ---------------------- | -------------------------------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------- |
| Request validation     | Ad-hoc `if` trees across controller methods                          | Existing Zod schema middleware                     | Keeps contract centralized, parseable, and testable.                 |
| Async UI state machine | Manual booleans (`isLoading`, `hasError`, etc.) scattered in widgets | Riverpod `AsyncValue` and notifier pattern         | Prevents inconsistent state transitions and improves retry handling. |
| Auth header injection  | Per-call token plumbing                                              | Existing Dio auth interceptor                      | Reduces drift and avoids missing token edge cases.                   |
| Persistence sync logic | New local storage abstraction in Phase 7                             | Existing SharedPreferences profile/plan cache path | Minimizes migration risk during contract freeze.                     |

**Key insight:** Phase 7 risk is integration inconsistency, not missing infrastructure. Reuse existing primitives and enforce a strict profile contract boundary.

## Common Pitfalls

### Pitfall 1: Validation mismatch between layers

**What goes wrong:** UI accepts/rejects values differently than backend model.
**Why it happens:** Zod schema and Mongoose validators diverge (`name` min length mismatch).
**How to avoid:** Define one canonical rule table and align middleware + model + UI validators in the same phase.
**Warning signs:** 400 errors for seemingly valid inputs or server accepts values UI rejects.

### Pitfall 2: Stale profile after successful save

**What goes wrong:** User saves but old data appears on revisit/restart.
**Why it happens:** No post-save cache refresh/invalidate path.
**How to avoid:** On successful PUT, immediately update local cache and invalidate/refetch profile provider.
**Warning signs:** Save success toast but unchanged header/avatar after navigation cycle.

### Pitfall 3: Placeholder navigation left in production flow

**What goes wrong:** `Edit Profile` appears tappable but no functional route.
**Why it happens:** UI shell was built ahead of provider/repository wiring.
**How to avoid:** Add route + screen + provider wiring in one vertical slice.
**Warning signs:** `onTap: () {}` placeholders in profile menu.

### Pitfall 4: Contract drift via undocumented endpoint aliases

**What goes wrong:** Some code calls stale path constants (`/users/profile`) while others use `/users/me`.
**Why it happens:** Legacy constant not pruned after endpoint evolution.
**How to avoid:** Single source of truth constants + contract tests asserting path usage.
**Warning signs:** 404s in specific flows, mixed route constants in code search.

## Code Examples

Verified patterns from official sources and repo conventions:

### Express route-level validation middleware

```javascript
// Source: Express routing docs + backend/src/routes/address.routes.js pattern
router.put("/me", validate("updateProfile"), userController.updateMe);
```

### Riverpod provider + watch/listen separation

```dart
// Source: https://riverpod.dev/docs/concepts2/providers
// and https://riverpod.dev/docs/concepts2/refs
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    ref.listen(profileProvider, (prev, next) {
      if (next.hasError) {
        // side effect only
      }
    });

    return switch (profile) {
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError() => const Text('Failed to load profile'),
      AsyncData(:final value) => Text(value.name),
    };
  }
}
```

## State of the Art

| Old Approach                                                       | Current Approach                                      | When Changed                          | Impact                                                                       |
| ------------------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------- | ---------------------------------------------------------------------------- |
| Widget-managed ad-hoc async flags                                  | `AsyncValue` + notifier-driven flow                   | Riverpod 2.x to 3.x best-practice era | Cleaner loading/error/success transitions and easier testing.                |
| Multiple provider interface variants (`AutoDisposeNotifier`, etc.) | Unified provider APIs in Riverpod 3                   | Riverpod 3.0                          | Simpler notifier wiring and fewer lifecycle mistakes.                        |
| Validation inside business logic only                              | Route-bound schema validation + typed error envelopes | Modern API contract-first practice    | Better client-side inline validation mapping and deterministic API behavior. |

**Deprecated/outdated:**

- `StateNotifierProvider` as default choice for new mutable state is now discouraged in Riverpod 3 docs (kept for backward compatibility); prefer Notifier/AsyncNotifier for new profile wiring.

## Risks

1. Contract ambiguity risk: `PUT /users/me` dual response modes may break profile sync logic.
2. Data mapping risk: backend `name/avatarUrl` not explicitly bridged to mobile display fields.
3. Validation regression risk: un-applied validation middleware on profile route enables invalid payload acceptance.
4. QA risk: existing tests are AI-path focused; profile contract and UI state coverage is currently missing.

## Recommended Plan Breakdown

1. Contract Freeze
   - Produce endpoint matrix for `/users/me` GET/PUT including request/response/error fields.
   - Decide and document single response strategy for `PUT /users/me`.
   - Align validation schema (Zod + Mongoose + client validator table).
2. Backend Wiring
   - Attach validation middleware to profile update route.
   - Normalize profile update response payload to frozen contract.
   - Add contract tests for success + invalid input + error envelope.
3. Mobile Data Layer Wiring
   - Add `profile_repository.dart` for GET/PUT profile operations.
   - Add profile provider/notifier for load/save/retry.
   - Remove stale endpoint constant drift (`/users/profile`).
4. UI Wiring
   - Implement `Edit Profile` screen and hook from `ProfileScreen`.
   - Inline validation before submit (name/avatar/phone-or-equivalent fields).
   - Ensure loading/error/retry/success states are user-visible.
5. Persistence Verification
   - After save, refresh provider + cache write-through.
   - Verify data survives screen revisit and app restart.
6. Test + Evidence
   - Backend Jest/Supertest contract cases.
   - Flutter widget/provider tests for profile states and inline validation.

## Open Questions

1. Should Phase 7 include `phone` as a backend field now?
   - What we know: Requirement allows “phone or equivalent supported fields.”
   - What's unclear: Whether `phone` is required in backend schema now or deferred.
   - Recommendation: Decide explicitly in contract freeze doc; if deferred, codify equivalent fields for PRO-02 acceptance.

2. Should `PUT /users/me` always return full profile?
   - What we know: Current behavior is mixed (ack vs full profile for activePlan branch).
   - What's unclear: Team preference between response size and sync simplicity.
   - Recommendation: For profile edit payloads, return full profile to reduce stale state bugs; keep activePlan heavy payload excluded unless explicitly requested.

## Validation Architecture

### Test Framework

| Property           | Value                                                  |
| ------------------ | ------------------------------------------------------ |
| Framework          | Jest ^30.2.0 (backend), flutter_test (mobile)          |
| Config file        | none explicit (defaults via package scripts)           |
| Quick run command  | `cd backend && npm test -- sanity.test.js --runInBand` |
| Full suite command | `cd backend && npm test -- --runInBand`                |

### Phase Requirements -> Test Map

| Req ID | Behavior                                             | Test Type                                | Automated Command                                                            | File Exists? |
| ------ | ---------------------------------------------------- | ---------------------------------------- | ---------------------------------------------------------------------------- | ------------ |
| PRO-01 | Profile load renders loading/error/data/retry states | widget/provider                          | `cd wattwise_app && flutter test test/profile/profile_load_states_test.dart` | ❌ Wave 0    |
| PRO-02 | Edit profile save succeeds with supported fields     | backend contract + widget                | `cd backend && npm test -- tests/profile.contract.test.js --runInBand`       | ❌ Wave 0    |
| PRO-03 | Invalid input shows inline validation before submit  | widget                                   | `cd wattwise_app && flutter test test/profile/profile_validation_test.dart`  | ❌ Wave 0    |
| PRO-04 | Saved profile persists after revisit/restart         | integration/manual + provider cache test | `cd wattwise_app && flutter test test/profile/profile_persistence_test.dart` | ❌ Wave 0    |

### Sampling Rate

- **Per task commit:** targeted backend/profile test + targeted Flutter/profile test.
- **Per wave merge:** backend full Jest suite.
- **Phase gate:** backend full suite green + Flutter profile test set green + manual restart verification.

### Wave 0 Gaps

- [ ] `backend/tests/profile.contract.test.js` - GET/PUT `/users/me` contract freeze assertions.
- [ ] `wattwise_app/test/profile/profile_load_states_test.dart` - loading/error/retry rendering behavior.
- [ ] `wattwise_app/test/profile/profile_validation_test.dart` - inline field validation behavior.
- [ ] `wattwise_app/test/profile/profile_persistence_test.dart` - save + revisit/restart cache behavior.

## Sources

### Primary (HIGH confidence)

- Repository code:
  - `backend/src/routes/user.routes.js`
  - `backend/src/controllers/user.controller.js`
  - `backend/src/services/UserService.js`
  - `backend/src/middleware/validation.middleware.js`
  - `backend/src/utils/ApiResponse.js`
  - `wattwise_app/lib/feature/profile/screens/profile_screen.dart`
  - `wattwise_app/lib/feature/auth/repository/auth_repository.dart`
  - `wattwise_app/lib/core/network/api_client.dart`
- Official docs:
  - Riverpod Providers: https://riverpod.dev/docs/concepts2/providers
  - Riverpod Refs: https://riverpod.dev/docs/concepts2/refs
  - Riverpod DO/DON'T: https://riverpod.dev/docs/root/do_dont
  - Riverpod 3.0 changes: https://riverpod.dev/docs/whats_new
  - Express routing docs: https://expressjs.com/en/guide/routing.html

### Secondary (MEDIUM confidence)

- Zod docs home + v4 pointers: https://zod.dev/

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - directly verified in workspace dependency manifests and active code usage.
- Architecture: HIGH - based on concrete route/controller/provider files in repo.
- Pitfalls: HIGH - derived from observed contract drift + official Riverpod/Express guidance.

**Research date:** 2026-03-23
**Valid until:** 2026-04-22 (30 days)
