# Architecture Research

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
