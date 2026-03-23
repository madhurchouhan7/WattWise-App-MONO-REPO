# Phase 2: Compatibility Foundation and Dual-Path Routing - Research

**Researched:** 2026-03-23  
**Domain:** Express 5 API orchestration + LangGraph dual-path routing compatibility  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
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

### Deferred Ideas (OUT OF SCOPE)
- Rollout and observability strategy details (shadow/canary depth and advanced telemetry policy) were not selected for deep-dive in this session.
- Any new capabilities beyond Phase 2 boundary (e.g., debate scoring semantics, full quality-gate enforcement behavior) remain for later phases.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-01 | Existing legacy linear files/entrypoints must remain functional | Additive routing wrapper pattern keeps `efficiencyPlanApp` callable unchanged and validates parity via legacy-path regression tests. |
| COMP-02 | New collaborative path must be isolated and routable via explicit orchestration entrypoint/flags | Use strict mode resolver (`x-ai-mode` + env default) with explicit enum validation and deterministic branch selection. |
| OPS-03 | Errors must be centralized and recoverable without crashing the whole workflow | Keep all route failures propagating to `next(err)` and strengthen structured API errors without in-controller crash handling or process exits. |
</phase_requirements>

## Summary

Phase 2 should be implemented as a thin orchestration compatibility layer in the AI controller, not as a rewrite of current graph code. The current backend already has three strong anchors to leverage: a stable legacy LangGraph compile/invoke path (`efficiencyPlanApp`), a centralized error middleware returning structured payloads (`errorCode`, `requestId`), and request-level IDs injected globally. This means the planning focus should be mode resolution, compatibility-safe response shaping, and route-level test coverage.

The safest structure is a dual-entry orchestrator contract where both legacy and collaborative executors return a normalized envelope (`finalPlan` + metadata), and only one execution path runs per request. Keep mode parsing deterministic (env default + header override), reject unknown/conflicting modes early with 400 errors, and rely on Express 5 async error propagation to route all failures into centralized middleware. Do not implement fallback from collaborative to legacy in this phase because that directly conflicts with locked decision D-07.

**Primary recommendation:** Plan this phase as four sequential work packets: strict mode resolver, additive collaborative entrypoint stub, compatibility response adapter, and regression/integration tests that enforce legacy parity and structured error behavior.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| express | 5.2.1 | API routing + middleware + centralized error flow | Express 5 automatically forwards rejected async handlers to error middleware, reducing custom wrapper complexity. |
| @langchain/langgraph | 1.2.5 | Graph orchestration for legacy and collaborative entrypoints | Existing production path already uses `StateGraph` and `.compile().invoke()`; additive path should stay in same orchestration runtime. |
| @langchain/core | 1.1.35 | Shared LangChain primitives | Required peer/core dependency for LangGraph workflows and node composition. |
| zod | 4.3.6 | Strict mode/header/schema validation | Already used in error handling branch; ideal for strict enum contracts and structured metadata guards. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| @langchain/openai | 1.3.0 | Provider bindings for node logic | Keep for existing node implementations; no migration needed in Phase 2. |
| jest | 30.3.0 | Test runner | Existing backend tests use Jest; expand with route-level compatibility tests. |
| supertest | 7.2.2 | HTTP assertion for Express endpoints | Add for deterministic API contract/error-shape tests on `/api/v1/ai/generate-plan`. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Header-based mode override | Query/body mode override | Header keeps routing concern out of payload contract; query/body increases conflict surface now and violates current lock decisions. |
| Controller-level resolver function | Dedicated middleware pre-route | Middleware improves reuse, but controller-level is acceptable and lower-change for one endpoint. |
| Zod enum validation | Manual string checks | Manual checks are faster to write but increase drift risk and inconsistent 400 payload formatting. |

**Installation:**
```bash
cd backend
npm install -D supertest
```

**Version verification (npm registry):**
- express: 5.2.1 (published 2025-12-01)
- @langchain/langgraph: 1.2.5 (published 2026-03-20)
- @langchain/core: 1.1.35 (published 2026-03-22)
- @langchain/openai: 1.3.0 (published 2026-03-17)
- zod: 4.3.6 (published 2026-01-22)
- jest: 30.3.0 (published 2026-03-10)
- supertest: 7.2.2 (published 2026-01-06)

## Architecture Patterns

### Recommended Project Structure
```text
backend/src/
├── controllers/
│   └── ai.controller.js                 # Mode resolution + orchestration invocation
├── agents/efficiency_plan/
│   ├── index.js                         # Existing legacy entrypoint (unchanged)
│   ├── collaborative.index.js           # New additive collaborative entrypoint
│   └── orchestrators/
│       └── modeResolver.js              # Strict routing/validation helper (optional)
├── middleware/
│   └── errorHandler.js                  # Centralized structured failures (reuse)
└── utils/
    └── ApiResponse.js                   # Compatibility response envelope helper
```

### Pattern 1: Mode Resolver + Single Dispatch
**What:** Resolve mode once, validate once, dispatch once.
**When to use:** Every request that can run multiple orchestration paths.
**Example:**
```javascript
// Source: https://expressjs.com/en/guide/error-handling.html
const allowedModes = new Set(["legacy", "collaborative"]);

function resolveMode(req) {
  const envDefault = process.env.NODE_ENV === "production" ? "legacy" : "collaborative";
  const headerMode = req.get("x-ai-mode");
  const requestedMode = headerMode || envDefault;

  if (!allowedModes.has(requestedMode)) {
    throw new ApiError(400, "Invalid x-ai-mode. Allowed: legacy, collaborative");
  }

  return { requestedMode, executionPath: requestedMode };
}
```

### Pattern 2: Compatibility Response Adapter
**What:** Normalize both path outputs into the same contract.
**When to use:** During additive rollout where old clients must continue parsing old shape.
**Example:**
```javascript
// Source: backend/src/utils/ApiResponse.js + phase context decisions
function toPlanEnvelope({ finalPlan, modeMeta, req }) {
  return {
    finalPlan,
    metadata: {
      executionPath: modeMeta.executionPath,
      requestedMode: modeMeta.requestedMode,
      requestId: req.id,
      orchestrationVersion: "v2-phase2",
      qualityScore: modeMeta.qualityScore ?? null,
      debateRounds: modeMeta.debateRounds ?? 0,
    },
  };
}
```

### Pattern 3: No-Fallback Error Propagation
**What:** Collaborative errors pass directly into centralized error middleware.
**When to use:** When policy explicitly forbids hidden fallback behavior.
**Example:**
```javascript
// Source: https://expressjs.com/en/guide/error-handling.html
const result = await selectedApp.invoke(initialState); // rejected promise auto -> next(err) in Express 5
if (!result?.finalPlan) {
  throw new ApiError(500, "Orchestration completed without finalPlan");
}
```

### Anti-Patterns to Avoid
- **Silent fallback to legacy on collaborative failure:** Violates D-07 and hides defects.
- **Mutating legacy graph internals for routing logic:** Increases COMP-01 risk; keep legacy entrypoint untouched.
- **Embedding metadata inside `finalPlan`:** Can break existing clients expecting only plan schema there.
- **Best-effort mode coercion (e.g., typo tolerance):** Violates strict enum contract and creates nondeterministic behavior.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Mode validation | Manual scattered `if/else` checks in controller and route | Single resolver + Zod/enum guard | Prevents drift and inconsistent 400 responses. |
| Error formatting | Per-controller ad hoc error JSON | Existing centralized `errorHandler` middleware | Already returns structured payload with `errorCode` and `requestId`. |
| Graph compatibility mapping | Custom deep plan transform logic | Envelope adapter around `finalPlan` | Lowest-risk compatibility path and easier regression testing. |
| HTTP endpoint testing | Custom request mocks | Supertest + Jest | Faster, realistic route contract tests with auth/middleware behavior. |

**Key insight:** Phase 2 is a compatibility layer problem, not an orchestration redesign problem. Hand-rolled transformations and fallback logic create hidden regressions faster than they add value.

## Common Pitfalls

### Pitfall 1: Breaking Legacy Success Payload Shape
**What goes wrong:** Clients expecting legacy payload parsing fail when response root shape changes unexpectedly.
**Why it happens:** Adding metadata by replacing or nesting the old payload instead of extending safely.
**How to avoid:** Keep `finalPlan` directly available and add metadata in a clearly additive envelope.
**Warning signs:** Mobile/web client deserialization errors or missing fields after deploy.

### Pitfall 2: Non-Deterministic Mode Resolution
**What goes wrong:** Same request executes different paths across environments or retries.
**Why it happens:** Multiple mode sources parsed in multiple layers without precedence rules.
**How to avoid:** One canonical resolver with clear precedence (header > env default) and strict enum check.
**Warning signs:** Logs show mismatch between requested mode and executed path.

### Pitfall 3: Duplicate Error Handling in Controller
**What goes wrong:** Mixed error formats and partial responses bypass centralized handler.
**Why it happens:** Controllers catch and respond directly instead of forwarding errors.
**How to avoid:** Throw `ApiError` and call `next(error)` only; no custom response body in failure path.
**Warning signs:** Some error responses lack `requestId` or `errorCode`.

### Pitfall 4: Hidden Fallback During Collaborative Failures
**What goes wrong:** Production appears healthy while collaborative path is broken.
**Why it happens:** Automatic fallback masks defect rates and invalidates telemetry.
**How to avoid:** No fallback in Phase 2; fail fast with structured error.
**Warning signs:** Legacy success rate too high despite collaborative exceptions in logs.

## Code Examples

Verified patterns from official sources:

### Express 5 Async Error Propagation
```javascript
// Source: https://expressjs.com/en/guide/error-handling.html
app.get('/user/:id', async (req, res, next) => {
  const user = await getUserById(req.params.id);
  res.send(user);
});
// Rejections automatically call next(err) in Express 5
```

### LangGraph Minimal Sequential Workflow
```typescript
// Source: https://docs.langchain.com/oss/javascript/langgraph/overview
import { StateSchema, MessagesValue, GraphNode, StateGraph, START, END } from "@langchain/langgraph";

const State = new StateSchema({ messages: MessagesValue });
const mockLlm: GraphNode<typeof State> = () => ({ messages: [{ role: "ai", content: "hello world" }] });

const graph = new StateGraph(State)
  .addNode("mock_llm", mockLlm)
  .addEdge(START, "mock_llm")
  .addEdge("mock_llm", END)
  .compile();

await graph.invoke({ messages: [{ role: "user", content: "hi" }] });
```

### LangGraph Routing with Conditional Edges
```typescript
// Source: https://docs.langchain.com/oss/javascript/langgraph/workflows-agents
const workflow = new StateGraph(State)
  .addNode("router", llmCallRouter)
  .addNode("legacyPath", legacyNode)
  .addNode("collabPath", collabNode)
  .addEdge("__start__", "router")
  .addConditionalEdges("router", routeDecision, ["legacyPath", "collabPath"])
  .addEdge("legacyPath", "__end__")
  .addEdge("collabPath", "__end__")
  .compile();
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Express 4-era manual async `try/catch` + explicit `next(err)` everywhere | Express 5 promise rejection auto-forwarding | Express 5 adoption (documented current behavior) | Cleaner controllers; fewer missed error-forwarding cases. |
| Single-path orchestration endpoint | Explicit multi-path routing with deterministic mode selection | Current agent orchestration best practice for progressive rollout | Safer migration with backward-compatible runtime toggles. |
| Monolithic graph replacement | Additive dual-entry architecture | Current production rollout pattern in compatibility phases | Lower risk to COMP-01 while unlocking collaborative path. |

**Deprecated/outdated:**
- Implicit fallback from new path to old path as default behavior: outdated for auditable reliability goals; masks failures and blocks root-cause handling.

## Open Questions

1. **How strict should missing-mode behavior be in non-production?**
   - What we know: D-01 defines env defaults; header override remains optional.
   - What's unclear: Whether test/staging should force explicit header to improve observability.
   - Recommendation: Keep env default now; add logging metric for implicit-mode usage.

2. **Collaborative entrypoint implementation depth in Phase 2**
   - What we know: Phase scope requires routable path existence, not full debate/quality features.
   - What's unclear: Whether collaborative path should be minimal proxy to legacy vs skeletal distinct graph.
   - Recommendation: Implement distinct additive entrypoint module with explicit version metadata, even if internals are lightweight in this phase.

3. **Response envelope exact shape in `sendSuccess`**
   - What we know: Existing helper currently stores success data under `data`.
   - What's unclear: Whether to return `{ data: { finalPlan, metadata } }` or flatten while preserving clients.
   - Recommendation: Keep `sendSuccess` shape unchanged and place compatibility envelope in `data`.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Jest 30.3.0 |
| Config file | none - using Jest defaults from `backend/package.json` script |
| Quick run command | `cd backend && npm test -- --runInBand tests/sanity.test.js` |
| Full suite command | `cd backend && npm test -- --runInBand` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-01 | Legacy mode invocation remains behavior-compatible and callable | integration (route + orchestrator mock) | `cd backend && npm test -- --runInBand tests/ai.compat.legacy.test.js` | ❌ Wave 0 |
| COMP-02 | Header/env routed mode picks collaborative path deterministically | integration (header/env matrix) | `cd backend && npm test -- --runInBand tests/ai.compat.routing.test.js` | ❌ Wave 0 |
| OPS-03 | Collaborative runtime error returns structured centralized payload, no crash | integration (error-path assertion) | `cd backend && npm test -- --runInBand tests/ai.compat.errors.test.js` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `cd backend && npm test -- --runInBand tests/ai.compat.*.test.js`
- **Per wave merge:** `cd backend && npm test -- --runInBand`
- **Phase gate:** Full suite green plus explicit legacy/collaborative route matrix pass

### Wave 0 Gaps
- [ ] `backend/tests/ai.compat.legacy.test.js` - covers COMP-01
- [ ] `backend/tests/ai.compat.routing.test.js` - covers COMP-02
- [ ] `backend/tests/ai.compat.errors.test.js` - covers OPS-03
- [ ] `backend/tests/helpers/mockOrchestrators.js` - deterministic stubs for legacy/collaborative invoke behavior
- [ ] Dev dependency install: `cd backend && npm install -D supertest`

## Practical Planning Guidance

### Constraints to Preserve
- Do not modify legacy graph topology or node contracts during Phase 2.
- Keep successful payload compatibility centered on `finalPlan`.
- Ensure mode decision is explicit in response metadata (`executionPath`, `requestedMode`, `orchestrationVersion`).
- All errors must flow through centralized middleware and include `requestId`.

### Recommended Implementation Sequencing
1. **Routing Contract Layer**
   - Implement strict mode resolver and validation errors.
   - Add request metadata capture (`requestedMode`, resolved path).
2. **Collaborative Entrypoint Scaffolding**
   - Create additive collaborative orchestration module with same output contract target.
   - Keep internals minimal but explicit (no fallback).
3. **Controller Integration**
   - Branch between legacy and collaborative invoke paths.
   - Normalize result through compatibility envelope adapter.
4. **Error Path Hardening**
   - Ensure throw/next behavior reaches `errorHandler` for all branch failures.
   - Validate status and payload consistency.
5. **Regression and Matrix Tests**
   - Add route integration tests for env default, header override, invalid mode, and collaborative failure.

### Risks and Mitigations
- **Risk:** Legacy client regression from payload shape drift.
  - **Mitigation:** Snapshot tests of legacy response contract before and after routing integration.
- **Risk:** Incomplete mode precedence rules causing nondeterminism.
  - **Mitigation:** Table-driven tests for all mode input combinations.
- **Risk:** Uncaught async errors in new collaborative path.
  - **Mitigation:** Avoid custom promise wrappers; rely on Express 5 async rejection handling and centralized middleware.
- **Risk:** Missing observability for branch selection.
  - **Mitigation:** Include `executionPath` and `requestId` in all success/error responses and logs.

## Sources

### Primary (HIGH confidence)
- Phase context and constraints: `.planning/phases/02-compatibility-foundation-and-dual-path-routing/02-CONTEXT.md`
- Requirements and roadmap mapping: `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`
- Existing integration code: `backend/src/controllers/ai.controller.js`, `backend/src/agents/efficiency_plan/index.js`, `backend/src/middleware/errorHandler.js`, `backend/src/app.js`
- Express official error handling docs: https://expressjs.com/en/guide/error-handling.html
- LangGraph official JavaScript docs: https://docs.langchain.com/oss/javascript/langgraph/overview
- LangGraph workflows/routing docs: https://docs.langchain.com/oss/javascript/langgraph/workflows-agents

### Secondary (MEDIUM confidence)
- npm package metadata for `@langchain/langgraph`: https://www.npmjs.com/package/@langchain/langgraph
- LangGraph repository README/index context: https://github.com/langchain-ai/langgraphjs

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - validated against current npm registry and existing repository dependencies.
- Architecture: HIGH - derived from locked decisions plus current backend integration points and official Express/LangGraph patterns.
- Pitfalls: MEDIUM-HIGH - mostly grounded in codebase realities and explicit phase constraints; production incidence still to be validated by tests.

**Research date:** 2026-03-23  
**Valid until:** 2026-04-22
