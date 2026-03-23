# Architecture Patterns

**Domain:** WattWise v2.1 profile and utility screen integration (Flutter + Node)
**Researched:** 2026-03-23
**Confidence:** HIGH

## Recommended Architecture

Use an extension-first architecture, not a rewrite:

1. Keep existing Flutter feature-first structure and Riverpod style.
2. Keep existing backend controller -> service -> repository layering.
3. Extend `GET/PUT /users/me` as the profile aggregate contract.
4. Introduce narrowly scoped endpoints only for utility modules that are list-like or operational (`/notifications`, `/support/*`).

This aligns with existing patterns already in the repo:
- Auth/profile hydration already flows through `/users/me` and cache fallback.
- Settings UI is currently local state and can be upgraded to remote-backed state without changing navigation.
- Backend already supports cached profile reads and partial profile updates.

---

## Integration Points (Best Places to Hook In)

## 1) Flutter Profile Domain (Primary Integration Point)

Create a dedicated profile data slice under `feature/profile` instead of pushing logic into auth providers.

### New component boundary

```text
feature/profile/
  model/
    profile_settings_model.dart
    utility_resource_model.dart
  repository/
    profile_repository.dart
  provider/
    profile_provider.dart
    settings_provider.dart
    utility_resources_provider.dart
  screens/
    edit_profile_screen.dart
    utility_resource_screen.dart
```

### Why here
- Preserves current feature-scoped organization.
- Avoids overloading `auth_provider.dart` (auth lifecycle stays auth-only).
- Allows independent invalidation/refresh of profile settings while keeping auth stream stable.

## 2) Flutter Core Network Contract (Secondary Integration Point)

Extend constants and keep all calls through `ApiClient`.

### Modify
- `core/network/api_constants.dart`

### Add route constants
- `/users/me`
- `/users/me/settings` (optional if split endpoint used)
- `/support/resources`
- `/support/contact`

### Why
- Existing app already uses typed constants + singleton `ApiClient` + standard `{ success, message, data }` envelope.

## 3) Backend User Aggregate (Primary Server Integration Point)

Extend `User` document with settings fields and keep profile updates in user service.

### Modify
- `models/User.model.js`
- `services/UserService.js`
- `controllers/user.controller.js`
- `routes/user.routes.js` (only if adding dedicated settings route)

### Why
- Current `PUT /users/me` is already the convergence point for mutable user profile state.
- Existing cache invalidation strategy is centered on user profile keys.

## 4) Backend Utility Content (New Module Boundary)

Utility actions in profile menu should map to either:
- static deep links (legal pages), or
- data-backed resources (FAQ/help articles/contact metadata).

Create dedicated support module instead of bloating user controller:

```text
backend/src/
  routes/support.routes.js
  controllers/support.controller.js
  services/SupportService.js
  repositories/SupportRepository.js   # only if persisted DB content is needed
  models/SupportResource.model.js     # optional for CMS-style content
```

---

## Module Boundaries

| Layer | Owns | Must Not Own |
|-------|------|--------------|
| Flutter UI screens/widgets | Rendering, user intents, navigation | API payload shaping, persistence logic |
| Flutter Riverpod providers | Async state, optimistic updates, invalidation | direct Dio calls in widgets |
| Flutter repositories | DTO <-> API mapping, endpoint invocation | UI concerns |
| User controller | HTTP parsing + response envelope | business rules |
| User service | profile/settings business rules and merge logic | transport concerns |
| User repository/model | persistence and query projection | API response formatting |
| Support module | utility resource retrieval and contact workflows | user profile mutation |

---

## Data Flow (Target)

## A) Profile Screen Load

```text
ProfileScreen
  -> ref.watch(profileProvider)
  -> ProfileNotifier.load()
  -> ProfileRepository.getMe()
  -> GET /api/v1/users/me
  -> UserController.getMe -> UserService.getUserProfile
  -> { success, message, data }
  -> provider state (AsyncData)
  -> widgets render (header/stats/settings summary)
```

## B) Edit Profile Save

```text
EditProfileScreen submit
  -> ProfileNotifier.updateProfile(patch)
  -> optimistic local merge (optional)
  -> ProfileRepository.updateMe(patch)
  -> PUT /api/v1/users/me
  -> UserController.updateMe
  -> UserService.updateProfile
  -> cache bust profile key
  -> ack response
  -> provider refresh + auth state invalidate (if display identity changed)
```

## C) Settings Toggle (Utility Preferences)

```text
SettingsScreen toggle
  -> SettingsNotifier.setBillReminders(bool)
  -> local optimistic state update
  -> ProfileRepository.updateSettings(settingsPatch)
  -> PUT /users/me (settings field) OR PATCH /users/me/settings
  -> UserService.updateSettings
  -> cache bust profile key
  -> on failure: rollback toggle + show error banner/snackbar
```

## D) Utility Resources (FAQ, Help, Legal Metadata)

```text
Utility screen open
  -> UtilityResourcesNotifier.fetch(type)
  -> ProfileRepository.getSupportResources(type)
  -> GET /api/v1/support/resources?type=faq|bill_help|legal
  -> SupportController/Service
  -> normalized resource list
  -> UI list/detail rendering
```

---

## API Design (Recommended Contracts)

## 1) User Aggregate Response

`GET /api/v1/users/me`

```json
{
  "success": true,
  "message": "User profile fetched.",
  "data": {
    "id": "...",
    "email": "user@example.com",
    "name": "Aarav",
    "avatarUrl": "https://...",
    "monthlyBudget": 3500,
    "currency": "INR",
    "address": {
      "state": "Maharashtra",
      "city": "Pune",
      "discom": "MSEDCL",
      "lat": 18.52,
      "lng": 73.85
    },
    "household": {
      "peopleCount": 3,
      "familyType": "Small",
      "houseType": "Apartment"
    },
    "settings": {
      "notifications": {
        "billReminders": true,
        "planAlerts": true,
        "weeklyInsights": false
      },
      "app": {
        "theme": "light",
        "units": "kWh",
        "biometricLock": true
      },
      "privacy": {
        "marketingConsent": false,
        "dataSharingConsent": false
      }
    },
    "streak": 7,
    "lastCheckIn": "2026-03-23T06:20:00.000Z",
    "longestStreak": 14,
    "onboardingCompleted": true
  }
}
```

## 2) Update Profile + Settings

Prefer single aggregate mutation for compatibility:

`PUT /api/v1/users/me`

```json
{
  "name": "Aarav Singh",
  "avatarUrl": "https://...",
  "currency": "INR",
  "settings": {
    "notifications": {
      "billReminders": false
    },
    "app": {
      "biometricLock": false
    }
  }
}
```

Response remains lightweight acknowledgement (existing behavior):

```json
{
  "success": true,
  "message": "Profile updated.",
  "data": {
    "updated": true,
    "updatedAt": "2026-03-23T06:32:00.000Z"
  }
}
```

Optional split endpoint if payload ownership must be explicit:
- `PATCH /api/v1/users/me/settings`

## 3) Support Resources

`GET /api/v1/support/resources?type=faq`

```json
{
  "success": true,
  "message": "Support resources fetched.",
  "data": [
    {
      "id": "faq_001",
      "type": "faq",
      "title": "Why is my bill estimate different?",
      "content": "...",
      "updatedAt": "2026-03-01T00:00:00.000Z"
    }
  ]
}
```

---

## New vs Modified Components

## Flutter - New
- `wattwise_app/lib/feature/profile/model/profile_settings_model.dart`
- `wattwise_app/lib/feature/profile/model/utility_resource_model.dart`
- `wattwise_app/lib/feature/profile/repository/profile_repository.dart`
- `wattwise_app/lib/feature/profile/provider/profile_provider.dart`
- `wattwise_app/lib/feature/profile/provider/settings_provider.dart`
- `wattwise_app/lib/feature/profile/provider/utility_resources_provider.dart`
- `wattwise_app/lib/feature/profile/screens/edit_profile_screen.dart`
- `wattwise_app/lib/feature/profile/screens/utility_resource_screen.dart`

## Flutter - Modified
- `wattwise_app/lib/feature/profile/screens/profile_screen.dart` (wire static menu actions to providers/navigation)
- `wattwise_app/lib/feature/profile/screens/settings_screen.dart` (replace local bool fields with provider state)
- `wattwise_app/lib/feature/profile/widgets/profile_header.dart` (consume profile data model instead of auth-only fields)
- `wattwise_app/lib/feature/profile/widgets/profile_stats_card.dart` (optionally source bills/savings counters from profile aggregate)
- `wattwise_app/lib/core/network/api_constants.dart` (add support/profile route constants)
- `wattwise_app/lib/feature/auth/repository/auth_repository.dart` (small: include settings in cached profile map if needed)

## Backend - New
- `backend/src/routes/support.routes.js`
- `backend/src/controllers/support.controller.js`
- `backend/src/services/SupportService.js`
- `backend/src/models/SupportResource.model.js` (optional; required if resources are DB-managed)

## Backend - Modified
- `backend/src/models/User.model.js` (add `settings` sub-schema)
- `backend/src/services/UserService.js` (add `updateSettings`, include settings in projection)
- `backend/src/controllers/user.controller.js` (accept `settings` patch in `updateMe`)
- `backend/src/routes/index.js` (mount `/support` routes)
- `backend/src/middleware/validation.middleware.js` (add schema for settings payload)

---

## Build Order (Dependency-Aware)

## Phase 1: Contract Foundation (Backend First)
1. Add `settings` schema to `User.model.js` with defaults.
2. Extend `UserService.updateProfile` or add `updateSettings` merge path.
3. Accept and validate `settings` in `PUT /users/me`.
4. Keep response envelope unchanged.

Reason: Frontend can only migrate safely after API contract exists.

## Phase 2: Flutter Data Layer
1. Add profile/settings models.
2. Add `profile_repository.dart` with typed `getMe` + `updateMe`.
3. Add `profile_provider.dart` and `settings_provider.dart` with optimistic update and rollback.

Reason: Isolates network complexity before screen rewiring.

## Phase 3: Screen Wiring (Low-Risk Incremental)
1. Wire `settings_screen.dart` toggles to `settingsProvider`.
2. Wire `Edit Profile` action to new edit screen and submit flow.
3. Update `profile_header.dart` to consume profile provider first, auth fallback second.

Reason: Avoids all-at-once UI migration.

## Phase 4: Utility Resources
1. Add backend support routes/service (or static adapter first).
2. Add Flutter utility resource provider + screen.
3. Connect FAQ/How to read bill/Legal/Contact menu items to real data routes or external links from config.

Reason: Utility module is independent of core profile mutation and can ship later.

## Phase 5: Hardening + Compatibility Checks
1. Verify auth refresh still works when profile cache contains new settings keys.
2. Verify cache invalidation (`profile` key) after settings update.
3. Add tests for partial settings patch merge and unknown field rejection.
4. Ensure old clients without `settings` field continue to work (defaults from model).

---

## Anti-Breakage Rules

1. Do not change existing response envelope (`success/message/data`).
2. Keep `/users/me` auth + cache behavior intact; only extend payload.
3. Keep `authStateProvider` as lifecycle source; profile/settings providers should not replace auth routing logic.
4. Keep feature ownership clear: profile/settings APIs in user domain, utility content APIs in support domain.
5. Prefer additive schema changes with defaults to preserve backward compatibility.

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Overloading auth stream with settings writes | unnecessary auth-driven rebuilds | keep settings in dedicated providers; only invalidate auth when identity fields change |
| Partial update clobbers nested settings | user preference loss | deep-merge server-side (`notifications`, `app`, `privacy`) |
| Utility endpoints mixed into user controller | bloated controller and unclear ownership | isolate in support module |
| Stale profile cache after update | inconsistent UI | bust `profile` cache key and refetch provider after save |
| Static menu links diverge across app versions | navigation regressions | centralize utility action registry in profile provider/repository |

---

## Sources (Codebase Evidence)

- `.planning/PROJECT.md`
- `wattwise_app/lib/feature/profile/screens/profile_screen.dart`
- `wattwise_app/lib/feature/profile/screens/settings_screen.dart`
- `wattwise_app/lib/feature/auth/repository/auth_repository.dart`
- `wattwise_app/lib/core/network/api_client.dart`
- `wattwise_app/lib/core/network/api_constants.dart`
- `wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart`
- `wattwise_app/lib/feature/notifications/providers/notification_provider.dart`
- `backend/src/routes/user.routes.js`
- `backend/src/controllers/user.controller.js`
- `backend/src/services/UserService.js`
- `backend/src/repositories/UserRepository.js`
- `backend/src/models/User.model.js`
- `backend/src/routes/notification.routes.js`
- `backend/src/controllers/notification.controller.js`
- `backend/src/routes/index.js`
- `backend/src/middleware/validation.middleware.js`

---
*Architecture research for milestone v2.1 profile and utility screen integration.*# Architecture Research

**Domain:** Production-grade collaborative multi-agent orchestration for WattWise efficiency plans
**Researched:** 2026-03-23
**Confidence:** HIGH

## Standard Architecture

### System Overview

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                              API / Control Layer                            │
├──────────────────────────────────────────────────────────────────────────────┤
│  ai.controller -> orchestration facade -> execution mode router             │
│      (legacy mode)                    (collaborative mode)                  │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
┌───────────────────────────────┴──────────────────────────────────────────────┐
│                        LangGraph Orchestration Layer                         │
├──────────────────────────────────────────────────────────────────────────────┤
│  Session Init -> Shared Context Builder -> Planner/Router                   │
│                                   │                                          │
│                                   ├── Analyst                               │
│                                   ├── Strategist                            │
│                                   └── Critic/Verifier                       │
│                                          │                                   │
│                     Debate Loop (bounded evaluator-optimizer cycle)          │
│                                          │                                   │
│                        Consensus + Quality Gate Node                         │
│                                          │                                   │
│                     Publisher (Final Plan contract adapter)                  │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
┌───────────────────────────────┴──────────────────────────────────────────────┐
│                       State / Memory / Observability Layer                   │
├──────────────────────────────────────────────────────────────────────────────┤
│  LangGraph state (short-term) + checkpointer thread state (durable)         │
│  Debate ledger + quality scores + retries metadata + trace events            │
│  Optional long-term memory adapter (future: Redis/DB)                        │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| orchestration facade | Stable entrypoint from controller, mode selection, config defaults | `generatePlan(state, options)` service wrapper |
| legacy graph adapter | Preserve existing linear behavior and schema | Keep current `efficiencyPlanApp` graph untouched |
| collaborative graph | Multi-agent orchestration, debate, routing, consensus | New LangGraph `StateGraph` with conditional edges and loop counter |
| shared workspace builder | Build common context packet for all agents | Node that normalizes user data, weather, prior artifacts |
| debate loop manager | Coordinate challenge -> revise -> re-score cycles | Evaluator-optimizer pattern with max iterations |
| quality gate | Enforce score thresholds, completeness, anti-hallucination checks | Deterministic node returning pass/fail + reasons |
| final contract adapter | Emit `finalPlan` exactly matching current API contract | Output normalization and schema validation node |
| memory/checkpoint adapter | Thread-scoped persistence and resume support | LangGraph checkpointer + `thread_id` strategy |
| telemetry hooks | Node-level traces and quality metrics | Structured logs + optional LangSmith tracing |

## Recommended Project Structure

```text
backend/src/agents/efficiency_plan/
├── index.js                          # Existing linear graph (unchanged)
├── state.js                          # Existing state schema (extended, backward-compatible)
├── collaborative/
│   ├── index.js                      # New collaborative graph compile/export
│   ├── state.collab.js               # New collaborative state annotation extensions
│   ├── router.node.js                # Route strategy/debate paths by complexity/risk
│   ├── debate/
│   │   ├── challenge.node.js         # Critic challenge generation
│   │   ├── revise.node.js            # Strategist revision node
│   │   └── consensus.node.js         # Weighted consensus and merge
│   ├── quality/
│   │   ├── score.node.js             # Multi-factor scoring node
│   │   ├── gate.node.js              # Threshold gate + fail reasons
│   │   └── contract.node.js          # Final API contract validator/adapter
│   ├── memory/
│   │   ├── workspace.node.js         # Shared context assembler
│   │   └── checkpoint.js             # Checkpointer + thread config helpers
│   └── observability/
│       └── trace.js                  # Consistent event logging helpers
└── service.js                        # New facade for legacy/collab mode execution
```

### Structure Rationale

- **Keep `index.js` stable:** Existing controller import path and invoke behavior remain valid.
- **Add `collaborative/` subtree:** Isolates new complexity and avoids regressions in current chain.
- **Single `service.js` facade:** Central place for rollout policy, fallback, and kill switch.
- **Separate `quality/` from `debate/`:** Prevents policy drift and makes gate logic testable.

## Architectural Patterns

### Pattern 1: Dual-Path Strangler (Compatibility-First)

**What:** Run legacy and collaborative orchestrators behind one facade; choose path by feature flag.
**When to use:** Migration where API contract cannot break.
**Trade-offs:** Slight duplication initially, but safest deployment path.

**Example:**
```javascript
async function generatePlan(initialState, opts) {
  if (!opts.enableCollaborative) {
    return legacyApp.invoke(initialState);
  }
  try {
    return await collaborativeApp.invoke(initialState, opts.graphConfig);
  } catch (err) {
    // Controlled degradation to preserve SLA
    return legacyApp.invoke(initialState);
  }
}
```

### Pattern 2: Evaluator-Optimizer Debate Loop (Bounded)

**What:** Candidate output is challenged and revised in loop until quality passes or max iterations reached.
**When to use:** Need higher factual consistency and actionability.
**Trade-offs:** Better quality but higher latency/token usage.

**Example:**
```javascript
const routeAfterGate = (state) => {
  if (state.qualityScore >= state.requiredScore) return "publish";
  if (state.iteration >= state.maxIterations) return "publish_with_flags";
  return "debate_revise";
};
```

### Pattern 3: State-Centric Shared Workspace

**What:** All nodes read/write a structured shared workspace (artifacts, claims, critiques, scores).
**When to use:** Multi-agent collaboration with traceability requirements.
**Trade-offs:** More schema design upfront, but deterministic audits and easier testing.

**Example:**
```javascript
const workspaceUpdate = {
  artifacts: [{ author: "Strategist", version: 2, planDraft }],
  critiques: [{ by: "Critic", severity: "high", claimId: "c1", reason: "unsupported" }],
  quality: { score: 82, missingEvidence: ["tariff assumptions"] }
};
```

## Data Flow

### Request Flow

```text
POST /ai/generate-plan
  -> ai.controller
  -> efficiency_plan/service.generatePlan
  -> mode router (legacy | collaborative)
  -> collaborative graph invoke(thread_id, config)
       -> workspace build
       -> analyst + strategist draft
       -> critic challenge
       -> quality score
       -> conditional route (accept or revise loop)
       -> contract adapter
  -> return { finalPlan } (same response shape)
```

### State Management

```text
Shared Graph State
  - Existing keys: userData, weatherContext, anomalies, strategies, finalPlan
  - New keys: workspace, debateRound, critiques, qualityScore, gateResults,
              consensusMeta, routeDecision, trace, failureMode

Reducers
  - Append-only reducers for debate artifacts/critiques
  - Replace reducers for latest draft/score/finalPlan
```

### Key Data Flows

1. **Workspace hydration flow:** Input + weather + prior outputs become canonical shared context before any agent work.
2. **Debate-revision flow:** Critic findings route back to strategist until gate pass or iteration cap.
3. **Quality publication flow:** Only contract-validated outputs are publishable; otherwise return degraded-safe output with flags.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k users | Single process graph execution with in-memory defaults, synchronous gate checks |
| 1k-100k users | Durable checkpointer store, queue-based execution for long runs, per-node timeout/retry budgets |
| 100k+ users | Dedicated orchestration workers, sharded thread storage, async publish pipeline + backpressure controls |

### Scaling Priorities

1. **First bottleneck:** LLM latency/token cost from debate loops. Mitigate with adaptive routing and strict max iterations.
2. **Second bottleneck:** State persistence I/O. Mitigate with async durability mode for non-critical paths and batched telemetry.

## Anti-Patterns

### Anti-Pattern 1: Big-Bang Graph Rewrite

**What people do:** Replace linear graph directly with new collaborative graph in-place.
**Why it's wrong:** High regression risk and no safe rollback.
**Do this instead:** Keep legacy graph intact and add collaborative graph behind feature flags.

### Anti-Pattern 2: Unbounded Debate Loops

**What people do:** Keep revising until subjective quality is reached.
**Why it's wrong:** Cost/latency blowups and potential infinite loops.
**Do this instead:** Gate by deterministic thresholds with `maxIterations` and explicit publish fallback.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| OpenWeather API | Pre-graph enrichment in controller (existing) | Keep as-is; include weather confidence in workspace metadata |
| OpenRouter / model providers | Node-local LLM calls | Move provider errors into structured `failureMode` state |
| Gemini API | Final synthesis and/or verifier role | Maintain output contract adapter after model response |
| Checkpointer store (new) | LangGraph compile with checkpointer + thread IDs | Required for durable execution and resumability in production |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| ai.controller <-> efficiency_plan/service | Direct async function call | Preserve current controller API and success envelope |
| service <-> legacy graph | Direct invoke | Always available as fallback path |
| service <-> collaborative graph | Direct invoke + config | Feature-gated and canary controlled |
| collaborative nodes <-> quality gates | Shared state keys | Keep gate logic deterministic and model-agnostic |
| graph <-> observability | Structured events | Emit node start/end, score deltas, route decisions |

## Safe Migration Sequence

### Phase 1: Foundation (No Behavior Change)
- Add `service.js` facade and route all controller calls through it.
- Keep default mode as legacy.
- Add new state keys in backward-compatible way (`default` values, no required consumers).

### Phase 2: Collaborative Graph in Shadow
- Create `collaborative/index.js` and run it in shadow mode for sampled traffic.
- Do not serve collaborative outputs; compare quality and contract parity offline.

### Phase 3: Quality Gates + Fallback Guarantees
- Enable collaborative output for internal/canary cohorts only.
- If gate fails or graph errors, fallback to legacy path automatically.
- Record gate fail reasons and regression metrics.

### Phase 4: Progressive Rollout
- Ramp feature flag by cohort/percentage.
- Add hard kill switch to force legacy globally.
- Keep rollback path as config-only change (no redeploy required).

### Phase 5: Default Collaborative, Legacy Retained
- Make collaborative default after SLO and quality stability.
- Retain legacy mode for emergency rollback until milestone hardening complete.

## New vs Modified Files (Recommended)

### New files
- `backend/src/agents/efficiency_plan/service.js`
- `backend/src/agents/efficiency_plan/collaborative/index.js`
- `backend/src/agents/efficiency_plan/collaborative/state.collab.js`
- `backend/src/agents/efficiency_plan/collaborative/router.node.js`
- `backend/src/agents/efficiency_plan/collaborative/debate/challenge.node.js`
- `backend/src/agents/efficiency_plan/collaborative/debate/revise.node.js`
- `backend/src/agents/efficiency_plan/collaborative/debate/consensus.node.js`
- `backend/src/agents/efficiency_plan/collaborative/quality/score.node.js`
- `backend/src/agents/efficiency_plan/collaborative/quality/gate.node.js`
- `backend/src/agents/efficiency_plan/collaborative/quality/contract.node.js`
- `backend/src/agents/efficiency_plan/collaborative/memory/workspace.node.js`
- `backend/src/agents/efficiency_plan/collaborative/memory/checkpoint.js`
- `backend/src/agents/efficiency_plan/collaborative/observability/trace.js`

### Modified files
- `backend/src/controllers/ai.controller.js` (import/use facade instead of direct graph invoke)
- `backend/src/agents/efficiency_plan/state.js` (add optional collaborative state keys)
- `backend/src/agents/efficiency_plan/index.js` (optional: export both legacy app and helper metadata, no edge changes)

## Sources

- Existing implementation reviewed in:
  - `.planning/PROJECT.md`
  - `backend/src/agents/efficiency_plan/index.js`
  - `backend/src/agents/efficiency_plan/state.js`
  - `backend/src/controllers/ai.controller.js`
  - `backend/src/agents/efficiency_plan/analyst.node.js`
  - `backend/src/agents/efficiency_plan/strategist.node.js`
  - `backend/src/agents/efficiency_plan/copywriter.node.js`
- LangGraph official docs (JavaScript):
  - https://docs.langchain.com/oss/javascript/langgraph/overview
  - https://docs.langchain.com/oss/javascript/langgraph/workflows-agents
  - https://docs.langchain.com/oss/javascript/langgraph/durable-execution
  - https://docs.langchain.com/oss/javascript/langgraph/interrupts

---
*Architecture research for: WattWise milestone v2.0 collaborative orchestration*
*Researched: 2026-03-23*
