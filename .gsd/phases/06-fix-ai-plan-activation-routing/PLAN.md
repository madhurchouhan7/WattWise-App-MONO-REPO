---
phase: 6-fix-ai-plan-routing
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - backend/src/controllers/user.controller.js
  - wattwise_app/lib/feature/auth/repository/user_repository.dart
  - wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart
autonomous: true
requirements: [REQ-06]
must_haves:
  truths:
    - "User can activate a plan and see it immediately without a flash of the design screen."
    - "Activating a plan updates the backend and local state synchronously."
  artifacts:
    - path: "backend/src/controllers/user.controller.js"
      provides: "Returns updated user with active plan on PUT /users/me"
    - path: "wattwise_app/lib/feature/auth/repository/user_repository.dart"
      provides: "Parses and returns the updated user data on saveActivePlan"
    - path: "wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart"
      provides: "Updates state synchronously before navigating"
  key_links:
    - from: "wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart"
      to: "wattwise_app/lib/feature/auth/repository/user_repository.dart"
      via: "saveActivePlan"
---

# PLAN.md - Phase 6: Fix AI Plan Activation Routing

<objective>
Fix the AI Plan Activation routing issue where users experience a "Design Plan" screen flash or incorrect routing after activating a plan.

Purpose: Improve the UX of plan activation by ensuring the frontend and backend states are synchronized instantly, preventing race conditions during navigation.
Output: Synchronous state updates and smooth transition to the Active Plan view.
</objective>

<execution_context>
@F:/Flutter Projects/WattWise Mono Repo/.gemini/get-shit-done/workflows/execute-plan.md
@F:/Flutter Projects/WattWise Mono Repo/.gemini/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.gsd/phases/6/RESEARCH.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Update Backend to Return Full User on Plan Activation</name>
  <files>backend/src/controllers/user.controller.js</files>
  <action>
    Modify the `updateMe` method in `user.controller.js`. Currently, it returns a lightweight `{ updated: true }` object to save bandwidth.
    When `activePlan` is included in the request body (meaning a plan is being activated), the controller should fetch the fully updated user profile (using `userService.getUserProfile(req.user._id)`) and return it in the response, so the frontend can immediately update its state.
    Keep the lightweight response for other updates (like `planPreferences` or `household`).
  </action>
  <verify>
    <automated>Check if the PUT /api/v1/users/me response contains the updated user object when activePlan is provided.</automated>
  </verify>
  <done>PUT /api/v1/users/me returns the full user object when activePlan is updated.</done>
</task>

<task type="auto">
  <name>Task 2: Update UserRepository to Return Updated State</name>
  <files>wattwise_app/lib/feature/auth/repository/user_repository.dart</files>
  <action>
    Modify `saveActivePlan` to parse the response from the backend. Instead of returning `void`, it should return `Future<Map<String, dynamic>?>` containing the updated user data returned from the API, or at least the active plan data.
    Ensure `SharedPreferences` is still updated correctly.
  </action>
  <verify>
    <automated>Verify the return type of saveActivePlan is changed and it correctly parses the response.</automated>
  </verify>
  <done>saveActivePlan returns the updated data from the backend.</done>
</task>

<task type="auto">
  <name>Task 3: Refine PlanReadyScreen Navigation and State</name>
  <files>wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart</files>
  <action>
    Update the `Activate Plan` button's `onPressed` logic.
    1. Await the result from `saveActivePlan`.
    2. Instead of just invalidating `authStateProvider`, if possible, eagerly update the local auth state with the new data from `saveActivePlan` before navigating. If Riverpod's `authStateProvider` allows for direct state mutation or refreshing synchronously via a method, use it. Otherwise, await the invalidation or ensure `PlansScreen` handles the transition gracefully.
    3. Ensure `Navigator.of(context).popUntil((route) => route.isFirst);` correctly lands on `PlansScreen` which will now re-evaluate `authUser?.activePlan != null` without flickering.
  </action>
  <verify>
    <automated>flutter analyze wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart</automated>
  </verify>
  <done>PlanReadyScreen navigates back without a flash of the Design Plan screen.</done>
</task>

</tasks>

<verification>
Start the backend server and the Flutter app.
Navigate through the Plan Generation flow.
Click "Activate Plan".
Verify that the app immediately transitions to the Active Plan dashboard without showing the "Design Plan" placeholder briefly.
</verification>

<success_criteria>
- Backend `updateMe` returns the full profile when `activePlan` is updated.
- Frontend synchronizes state immediately.
- No flickering or infinite refresh loops upon plan activation.
</success_criteria>
