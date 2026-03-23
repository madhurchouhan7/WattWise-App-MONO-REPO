# Plan: Fix Plan Activation Navigation and UI Consistency

Fixes the navigation issue where activating a plan hides the bottom navigation bar and allows the back button to return to the design flow.

## Research Findings
- `PlanReadyScreen` pushes `ActivePlanScreen` onto the root navigator, covering the `RootScreen`'s bottom nav bar.
- `pushAndRemoveUntil((route) => route.isFirst)` keeps `RootScreen` but adds `ActivePlanScreen` on top.
- `PlansScreen` has a race condition: it might show `DesignPlanScreen` while `authState` is reloading after activation because the staging plan is cleared immediately.
- `DesignPlanScreen` has an unconditional back button that might try to pop the root navigator.

## Proposed Changes

### 1. wattwise_app/lib/feature/plans/screens/plan_ready_screen.dart
- Change `pushAndRemoveUntil` to `popUntil((route) => route.isFirst)`.
- This ensures the user returns to the `RootScreen` context where the bottom nav is visible.
- Since `authStateProvider` is invalidated and `aiPlanProvider` is cleared, the `PlansScreen` tab will automatically show the `ActivePlanScreen`.

### 2. wattwise_app/lib/feature/plans/screens/plans_screen.dart
- Improve the loading guard to prevent flickering to `DesignPlanScreen` during auth state transitions.
- The condition should ensure that if `authState` is loading, we wait for it to resolve before deciding to show `DesignPlanScreen`.

### 3. wattwise_app/lib/feature/plans/screens/design_plan_screen.dart
- Hide the back button if the navigator cannot pop, or handle it more gracefully.
- Since it's a top-level tab screen, a back button is often not needed unless it was pushed from somewhere else.

## Verification Plan
- **Manual Verification**:
    1. Navigate through the plan design flow (Design -> Crafting -> Ready).
    2. Click "Activate Plan".
    3. Verify that the app transitions to `ActivePlanScreen` with the bottom navigation bar visible.
    4. Verify that pressing the back button on `ActivePlanScreen` does not go back to `DesignPlanScreen` (it should likely exit the app or do nothing if it's the root).
    5. Verify that `DesignPlanScreen` does not show a back button if it's the entry point of the tab.
- **Automated Tests**:
    - Add/Update widget tests to verify navigation stack behavior if possible. (Will check existing tests first).
