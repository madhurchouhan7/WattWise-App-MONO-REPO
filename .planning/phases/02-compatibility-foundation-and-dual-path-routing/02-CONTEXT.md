# Phase 2: Compatibility Foundation and Dual-Path Routing - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Build an additive dual-path orchestration entrypoint for AI plan generation that preserves the existing legacy linear flow and response compatibility. This phase defines routing and compatibility behavior, not full collaborative quality/debate/memory features.

</domain>

<decisions>
## Implementation Decisions

### Dual-path routing trigger model
- **D-01:** Default mode is environment-based: production defaults to `legacy`, non-production (dev/staging) defaults to `collaborative`.
- **D-02:** Runtime override is accepted via request header only (`x-ai-mode`) in Phase 2.
- **D-03:** Mode contract is strict enum (`legacy | collaborative`). Unknown values return `400` with allowed values.
- **D-04:** If conflicting mode inputs are ever detected (e.g., future body/query extension), return `400` conflict error; do not silently coerce.
- **D-05:** Collaborative mode is available to any authenticated user in Phase 2.
- **D-06:** Successful responses must include executed path metadata (`executionPath`) to make routing transparent.

### Failure and fallback policy
- **D-07:** Authoritative policy for Phase 2: **no automatic fallback** from collaborative to legacy on runtime errors.
- **D-08:** If collaborative execution fails, route through centralized API error handling and return structured error payloads with `errorCode` and `requestId`.
- **D-09:** Metadata may describe attempted mode/path, but fallback execution is disabled for this phase.

### API contract and response shape policy
- **D-10:** Preserve the existing successful payload contract (`finalPlan`) without breaking existing clients.
- **D-11:** Add orchestration metadata in response envelope (not inside `finalPlan`) to preserve compatibility.
- **D-12:** Required metadata keys in Phase 2 success responses: `executionPath`, `requestedMode`, `requestId`, `orchestrationVersion`, `qualityScore`, `debateRounds`.
- **D-13:** Include `metadata.orchestrationVersion` (e.g., `v2-phase2`) for traceability.
- **D-14:** Backward compatibility guarantee: clients can ignore unknown metadata fields safely.

### the agent's Discretion
- Validation middleware placement (controller-level vs shared middleware) as long as mode validation behavior stays strict.
- Exact metadata nesting/shape naming beyond locked keys, as long as `finalPlan` compatibility is preserved.
- Internal feature-flag implementation mechanism (env/config module) as long as routing decisions above are enforced.

</decisions>

<specifics>
## Specific Ideas

- Preserve the current controller invoke shape while introducing mode-based routing to legacy vs collaborative entrypoint.
- Keep routing transparent by returning the actual execution path in metadata.
- Enforce strict input validation and explicit errors instead of silent coercion.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase and requirement anchors
- `.planning/ROADMAP.md` — Defines Phase 2 goal, success criteria, and requirement mapping.
- `.planning/REQUIREMENTS.md` — Defines COMP-01, COMP-02, OPS-03 constraints for this phase.
- `.planning/PROJECT.md` — Milestone intent and compatibility-first strategy.
- `.planning/STATE.md` — Current workflow position and active planning context.

### Existing orchestration baseline (legacy path)
- `backend/src/agents/efficiency_plan/index.js` — Current linear LangGraph topology and compilation entrypoint.
- `backend/src/agents/efficiency_plan/state.js` — Current state schema that compatibility must preserve.
- `backend/src/agents/efficiency_plan/analyst.node.js` — Legacy Analyst behavior and fallback patterns.
- `backend/src/agents/efficiency_plan/strategist.node.js` — Legacy Strategist behavior and fallback patterns.
- `backend/src/agents/efficiency_plan/copywriter.node.js` — Legacy Copywriter final payload behavior.

### API integration and error semantics
- `backend/src/controllers/ai.controller.js` — Current `/generate-plan` invocation path and output contract.
- `backend/src/routes/ai.routes.js` — Authenticated route binding for plan generation.
- `backend/src/middleware/errorHandler.js` — Centralized structured error contract required by Phase 2.
- `backend/src/app.js` — Request-id middleware and API middleware stack affecting routing integration.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `efficiencyPlanApp` in `backend/src/agents/efficiency_plan/index.js` is the stable legacy path to preserve.
- Existing centralized `errorHandler` already provides structured `errorCode` + `requestId` response semantics.
- Existing request-id middleware in `backend/src/app.js` already sets `req.id` and `X-Request-ID` for trace metadata.

### Established Patterns
- Controller-centric orchestration invocation (`ai.controller.js`) with explicit input checks and `ApiError` usage.
- Sequential legacy graph and typed state annotation are currently stable and should remain callable unchanged.
- Auth guard is route-level (`authMiddleware` on `/api/v1/ai/generate-plan`) and should remain intact.

### Integration Points
- Primary insertion point for dual-path routing: `backend/src/controllers/ai.controller.js` before graph invocation.
- Legacy entrypoint remains `backend/src/agents/efficiency_plan/index.js`.
- New collaborative entrypoint should be additive in `backend/src/agents/efficiency_plan/` (or submodule) and selected by validated mode.

</code_context>

<deferred>
## Deferred Ideas

- Rollout and observability strategy details (shadow/canary depth and advanced telemetry policy) were not selected for deep-dive in this session.
- Any new capabilities beyond Phase 2 boundary (e.g., debate scoring semantics, full quality-gate enforcement behavior) remain for later phases.

</deferred>

---

*Phase: 02-compatibility-foundation-and-dual-path-routing*
*Context gathered: 2026-03-23*
