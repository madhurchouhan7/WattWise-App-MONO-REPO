# Proposed Roadmap

**1 phase** | **5 requirements mapped** | All covered ✓

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Navigation and Cache Fixes | Redirect users to the Active Plan correctly without losing the Bottom NavBar | NAV-01, NAV-02, NAV-03, CACHE-01, CACHE-02 | 3 |

### Phase Details

**Phase 1: Navigation and Cache Fixes**
Goal: Ensure `plan_ready_screen` logic directs exactly to `active_plan_screen` retaining the bottom navigation bar and that deletion sweeps cache.
Requirements: NAV-01, NAV-02, NAV-03, CACHE-01, CACHE-02
Success criteria:
1. Activating a plan directly reveals the generated plan via BottomNavigationBar rendering `ActivePlanScreen`.
2. Hardware back button / App bar back button does not inadvertently clear active plan unexpectedly.
3. Actual manual Deletion of Plan correctly wipes cache making `PlanReadyScreen` / `DesignPlanScreen` reappear accurately.
