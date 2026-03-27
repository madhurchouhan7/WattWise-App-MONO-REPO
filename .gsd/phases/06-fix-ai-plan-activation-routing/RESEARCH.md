# RESEARCH.md - Phase 6: Fix AI Plan Activation Routing

## Status
- **Phase:** 6
- **Confidence:** HIGH

## Key Findings

### Backend Activation Flow
- **Route:** `PUT /api/v1/users/me`
- **Controller:** `backend/src/controllers/user.controller.js` -> `updateMe`
- **Logic:** Calls `userService.updateActivePlan`. It also invalidates `profile` and `active-plan` cache keys.
- **Payload:** Expects an `activePlan` object in the request body.

### Frontend Activation Flow
- **Screen:** `wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart`
- **Repository:** `wattwise_app/lib/feature/auth/repository/user_repository.dart` -> `saveActivePlan`
- **Process:**
  1. Calls backend API to update the active plan.
  2. Updates local `SharedPreferences`.
  3. Invalidates `authStateProvider` using `ref.invalidate(authStateProvider)`.
  4. Navigates back: `Navigator.of(context).popUntil((route) => route.isFirst)`.

## Root Cause Analysis (State Sync Issue)
The routing failure is primarily a **State Sync Issue** caused by:
1. **Race Condition:** `ref.invalidate(authStateProvider)` triggers a re-fetch. If the backend update hasn't fully propagated (though it uses `await`), or if the local provider doesn't reflect the new state immediately, the `PlansScreen` might rebuild with the old "Design Plan" state.
2. **Navigation Logic:** `popUntil((route) => route.isFirst)` returns to the root of the current navigator. If the `PlansScreen` is the root and doesn't correctly listen to the `authStateProvider` for the "Active Plan" state, it won't show the new plan.
3. **Cache Latency:** While the backend invalidates the cache, any client-side caching (e.g., in `Dio` or `Riverpod` providers) might still serve stale data.

## Proposed Fix Strategy
1. **Frontend:** Ensure `PlansScreen` (or its parent `RootScreen`) explicitly watches for changes in the `activePlan` state.
2. **Frontend:** Use a more robust navigation or state-driven routing (e.g., GoRouter) if possible, or ensure the `RootScreen` forces a refresh of the entire UI tree after activation.
3. **Backend:** Verify that the `updateMe` response includes the updated `activePlan` so the frontend can update its local state immediately without a full re-fetch.

## Pitfalls to Avoid
- **Infinite Refresh Loops:** Avoid circular invalidations between `authStateProvider` and `activePlanProvider`.
- **Stale Local Storage:** Ensure `SharedPreferences` and the server are always in sync.
- **UI Flickering:** Prevent the "Design Plan" screen from showing briefly before the "Active Plan" screen loads.
