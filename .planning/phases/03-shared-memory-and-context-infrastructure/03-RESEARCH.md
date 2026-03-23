# Phase 3: Shared Memory and Context Infrastructure - Research

**Researched:** 2026-03-23
**Domain:** Redis-backed shared memory, provenance contracts, bounded context retrieval, and trace correlation in Node/Express + LangGraph orchestration
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Persistence model and isolation keys

- **D-01:** Use Redis-backed persistence as primary shared-memory store, with optional in-process hot-read cache.
- **D-02:** Canonical key model is `tenantId:userId:threadId`; `runId` is recorded at event level.
- **D-03:** Cross-thread reads are allowed for the same user only through controlled retrieval logic (not global unrestricted merge).
- **D-04:** Missing required identity keys (tenant/user/thread) must fail with HTTP 400 and explicit missing-key errors.

### Conversation retention policy

- **D-05:** Retain full active thread history for 30 days, then archive.
- **D-06:** Default agent input is bounded: recent window + retrieved relevant historical items.
- **D-07:** Archive is write-only cold storage in Phase 3 (not runtime-queryable by default).
- **D-08:** Sensitive fields in persisted history must be redacted/tokenized.

### Provenance schema contract

- **D-09:** Every memory write must include: `agentId`, `timestamp`, `sourceType`, `evidenceRefs`, `revisionId`, `confidenceScore`.
- **D-10:** Revisions use immutable append-only events with new `revisionId` per update.
- **D-11:** Missing `evidenceRefs` is allowed only when confidence is downgraded/flagged (no hard rejection).
- **D-12:** Include trace linkage (`requestId`, `runId`) when available on every event.

### Retrieval strategy per agent call

- **D-13:** Default retrieval strategy is recent-window-first plus relevance retrieval over older events.
- **D-14:** Default recent window size is last 12 events.
- **D-15:** Retrieval must enforce hard token budget with ranking + truncation.
- **D-16:** If relevance retrieval yields no useful matches, continue with recent-window-only fallback.

### the agent's Discretion

- Exact Redis schema primitives (hash/list/json) as long as key semantics and provenance contract are preserved.
- Exact ranking function for relevance retrieval as long as hard token caps and fallback behavior are enforced.
- Redaction implementation details (hashing/tokenization library) as long as sensitive data is not stored raw.

### Deferred Ideas (OUT OF SCOPE)

- Archive readback search and analytics dashboards are deferred beyond Phase 3 baseline.
- Advanced adaptive retrieval tuning (learned ranking/weights) is deferred to later phases.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MEM-01 | All agents must read from and write to a shared persistent workspace that stores full run context and artifact history. | Use Redis append-only event model keyed by `tenantId:userId:threadId`, with per-thread event stream + artifact index; enforce required identity keys and centralized memory service APIs. |
| MEM-02 | Conversation history must be retained across node/agent transitions and available to every agent on each turn. | Implement recent-window + relevance retrieval planner, thread history query APIs, and per-turn memory hydration at orchestrator boundary before each agent invocation. |
| MEM-03 | Memory records must include provenance metadata (agent, timestamp, source/evidence, revision). | Enforce event schema with required provenance fields and append-only revision semantics; validate with Zod and reject invalid writes except explicit low-confidence/no-evidence allowance. |
| OPS-02 | System must emit structured logs and execution trace for each run. | Carry `requestId` + `runId` (+ optional `traceId`) in each memory event and structured logs; correlate memory writes and retrieval decisions with execution metadata. |
</phase_requirements>

## Summary

Phase 3 should be planned as a storage-contract phase, not a model-behavior phase. The codebase already has major prerequisites: Redis client infrastructure (`ioredis` via `CacheService`), request-level correlation IDs (`req.id`), centralized error responses, and an additive collaborative orchestration structure introduced in Phase 2. The most reliable path is to add a dedicated shared-memory module that owns persistence, validation, retrieval, redaction, and trace-correlation logic, then wire it at orchestration boundaries.

For the locked decisions, Redis Streams are the best fit for append-only auditable event history because they are explicitly append-only logs, preserve ordered IDs, support range retrieval, and support bounded trimming strategies. Store thread event history and provenance as immutable events; maintain lightweight secondary indexes for retrieval and recency windows. Enforce hard token budgets before prompt assembly using deterministic ranking + truncation.

**Primary recommendation:** Plan Phase 3 in six implementation slices: schema + key contract, write-path persistence with provenance validation, retrieval engine with token budget enforcement, controller/orchestrator integration, observability correlation, and requirement-mapped tests.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| ioredis | 5.10.1 | Redis persistence client for shared memory workspace | Already in backend dependencies; supports streams, pipelines, reconnect behavior, and operational features needed for robust event persistence. |
| zod | 4.3.6 | Enforce memory write/read schemas and provenance contract | Already used in error handling path; ideal for explicit validation errors and strict schema guards. |
| @langchain/langgraph | 1.2.5 | Orchestration runtime where memory context is injected per turn | Existing orchestration runtime and supports thread/state persistence concepts aligned with this phase. |
| express | 5.2.1 | Request lifecycle and centralized error surface for missing key failures | Existing API runtime; async errors route to centralized handler for contract violations. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| js-tiktoken | 1.0.21 | Hard token-budget estimation for bounded context retrieval | Use when implementing D-15 hard token cap before LLM prompt construction. |
| @opentelemetry/api | 1.9.0 | Optional trace-context propagation standardization | Use if Phase 3 includes distributed trace propagation beyond current `requestId`/`runId` fields. |
| supertest | 7.2.2 | API-level test coverage for memory key validation and trace metadata contracts | Use for route/integration verification under MEM/OPS requirements. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Redis Streams for event history | Redis Lists + Hash metadata | Lists are simpler but lose built-in stream IDs/range idioms and event-log ergonomics for audited revisions. |
| In-house token estimation by character length | js-tiktoken token counting | Character heuristics are cheaper but violate hard budget guarantees under multilingual/structured content. |
| Custom ad-hoc context merge logic | Deterministic retrieval policy (recent-first + ranked historical) | Ad-hoc merge leads to prompt bloat and nondeterministic context shape. |

**Installation:**
```bash
cd backend
npm install js-tiktoken
# optional if distributed tracing instrumentation is adopted in this phase
npm install @opentelemetry/api
```

**Version verification (npm registry):**
- ioredis: 5.10.1 (published 2026-03-19)
- zod: 4.3.6 (published 2026-01-22)
- @langchain/langgraph: 1.2.5 (published 2026-03-20)
- express: 5.2.1 (published 2025-12-01)
- js-tiktoken: 1.0.21 (published 2025-08-09)
- @opentelemetry/api: 1.9.0 (published 2024-06-05)
- supertest: 7.2.2 (existing dependency)

## Architecture Patterns

### Recommended Project Structure
```text
backend/src/
├── agents/efficiency_plan/
│   ├── shared/
│   │   ├── memoryKeys.js                 # tenant:user:thread key builder + validation
│   │   ├── memorySchema.js               # zod schemas for write/read contracts
│   │   ├── memoryStore.redis.js          # low-level Redis read/write primitives
│   │   ├── memoryService.js              # write events, revisions, retrieval plans
│   │   ├── retrievalPlanner.js           # recent-window + relevance + token budget
│   │   └── redaction.js                  # sensitive field redaction/tokenization
│   ├── collaborative.index.js            # memory service wiring before/after node calls
│   └── state.js                          # memory refs + retrieval payload channels
├── controllers/
│   └── ai.controller.js                  # pass identity + run metadata into memory layer
├── middleware/
│   ├── errorHandler.js                   # 400s for missing keys and schema failures
│   └── logging.middleware.js             # structured logs with memory trace fields
└── services/
    └── CacheService.js                   # existing Redis client foundation to reuse/extend
```

### Pattern 1: Append-only Memory Event Log
**What:** Persist every write as immutable event with revision metadata.
**When to use:** All memory writes and revisions (D-10).
**Example:**
```javascript
// Source: https://redis.io/docs/latest/develop/data-types/streams/
// Stream is append-only with monotonic IDs generated by XADD.
await redis.xadd(
  streamKey,
  "*",
  "eventType", "artifact_update",
  "agentId", input.agentId,
  "timestamp", new Date().toISOString(),
  "revisionId", input.revisionId,
  "sourceType", input.sourceType,
  "confidenceScore", String(input.confidenceScore),
  "requestId", input.requestId ?? "",
  "runId", input.runId ?? "",
  "payload", JSON.stringify(input.payload)
);
```

### Pattern 2: Identity-Key Gate Before Any Read/Write
**What:** Fail fast when `tenantId`, `userId`, or `threadId` is missing.
**When to use:** Controller boundary and memory service public methods (D-04).
**Example:**
```javascript
// Source: Phase 3 locked decision D-04
const RequiredContext = z.object({
  tenantId: z.string().min(1),
  userId: z.string().min(1),
  threadId: z.string().min(1),
  runId: z.string().min(1).optional(),
});

function assertMemoryContext(ctx) {
  const parsed = RequiredContext.safeParse(ctx);
  if (!parsed.success) {
    throw new ApiError(400, "Missing required memory identity keys: tenantId, userId, threadId");
  }
  return parsed.data;
}
```

### Pattern 3: Bounded Retrieval Assembly
**What:** Build prompt context via recent-window first, then relevance-ranked history until token cap.
**When to use:** Every agent call where memory is injected (D-13, D-14, D-15, D-16).
**Example:**
```javascript
// Source: Phase 3 decisions + js-tiktoken package docs
const recent = await memoryStore.getRecentEvents(scope, { limit: 12 });
const ranked = await memoryStore.searchHistorical(scope, query, { limit: 40 });

const selected = [];
for (const item of [...recent, ...ranked]) {
  const candidate = [...selected, item];
  if (countTokens(candidate) > tokenBudget) break;
  selected.push(item);
}

return selected.length ? selected : recent;
```

### Anti-Patterns to Avoid
- **Mutable “current memory blob” overwrites:** Breaks auditability and revision traceability.
- **Global cross-thread merges:** Violates D-03 isolation intent.
- **Unbounded history injection:** Causes prompt bloat and unstable runtime costs.
- **Trusting caller-supplied provenance without validation:** Creates unverifiable audit trails.
- **Storing raw sensitive payloads without redaction:** Violates D-08 and increases compliance risk.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Ordered audited event storage | Custom file/db append logic | Redis Streams + explicit schema | Stream IDs and range access are already built for append-only event logs. |
| Token budgeting | Character-count heuristics | `js-tiktoken` exact token counting | Hard budget enforcement requires token-aware accounting, not rough length estimates. |
| Trace standards | Ad-hoc trace ID semantics across modules | Existing `requestId` + explicit `runId` + optional OTel context model | Prevents incompatible trace semantics and improves cross-log correlation. |
| Provenance validation | Manual per-call object checks | Central Zod schemas in memory service | Ensures consistent contract enforcement and clear 400 errors. |

**Key insight:** The hard parts in this phase are consistency and invariants, not CRUD. Use strong contracts and native Redis primitives rather than custom memory bookkeeping.

## Common Pitfalls

### Pitfall 1: Ambiguous Scope Keys
**What goes wrong:** Writes land in mixed namespaces; retrieval leaks context between threads.
**Why it happens:** Keys composed inconsistently or optional identity fields tolerated.
**How to avoid:** One canonical key builder and required identity schema gate.
**Warning signs:** Same event appears under multiple threads; unexpected cross-thread recalls.

### Pitfall 2: Retrieval Without Hard Budgeting
**What goes wrong:** Prompt sizes spike and latency/cost become nondeterministic.
**Why it happens:** Only count item count, not tokens.
**How to avoid:** Tokenize candidate context before assembly; truncate deterministically.
**Warning signs:** Intermittent model context-length errors or sudden latency increases.

### Pitfall 3: Missing Provenance on Partial Writes
**What goes wrong:** Artifacts become non-auditable and cannot be trusted in later validation phases.
**Why it happens:** Optional fields accepted silently in convenience paths.
**How to avoid:** Make provenance required by schema, with explicit downgrade handling for missing evidence refs (D-11).
**Warning signs:** Events without `agentId`/`revisionId`/`timestamp` in store inspection.

### Pitfall 4: Retention Drift
**What goes wrong:** “30-day active history” policy is not actually enforced.
**Why it happens:** TTL only set at key creation, not refreshed or archived correctly.
**How to avoid:** Explicit retention worker/command path with archive write + active trim policy.
**Warning signs:** Active keys older than 30 days or archived keys queryable at runtime.

### Pitfall 5: Trace Correlation Gaps
**What goes wrong:** Memory writes cannot be tied back to API/log events.
**Why it happens:** `requestId`/`runId` not propagated through memory service boundaries.
**How to avoid:** Include trace fields in every memory write/read decision log.
**Warning signs:** Logs contain request IDs, but memory records do not.

## Code Examples

Verified patterns from official sources:

### Redis Stream as Append-only Event Log
```javascript
// Source: https://redis.io/docs/latest/develop/data-types/streams/
const id = await redis.xadd("memory:tenant:user:thread:events", "*", "k", "v");
const history = await redis.xrange("memory:tenant:user:thread:events", "-", "+", "COUNT", 50);
```

### Redis Retention Semantics
```javascript
// Source: https://redis.io/docs/latest/commands/expire/
await redis.expire(activeThreadKey, 60 * 60 * 24 * 30); // 30 days
// EXPIRE updates TTL if key already exists; use NX/XX/GT/LT when needed.
```

### LangGraph Thread Persistence Concept
```typescript
// Source: https://docs.langchain.com/oss/javascript/langgraph/persistence
const config = { configurable: { thread_id: "thread-123" } };
await graph.invoke(input, config);
const snapshot = await graph.getState(config);
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Stateless per-request orchestration with ephemeral context | Thread-scoped persisted state + retrieval planning | Mature LangGraph persistence/checkpointer model (2025-2026) | Enables continuity, replay, and audited multi-agent collaboration. |
| Free-form prompt stuffing | Token-budgeted retrieval pipelines | Token-cost and context-limit pressure in production LLM systems | Predictable latency/cost and fewer context overflow failures. |
| Basic request correlation IDs only | End-to-end trace context (`requestId`, `runId`, optional trace propagation) | Wider observability standardization (OTel + structured logs) | Better debugging and causality mapping across services. |

**Deprecated/outdated:**
- “Keep all conversation history in prompt every turn” for production systems; replaced by bounded retrieval with deterministic budget controls.

## Open Questions

1. **Archive implementation target for D-07 in Phase 3**
   - What we know: Archive is required to be write-only cold storage and not runtime-queryable.
   - What’s unclear: Whether to use Redis cold namespace, S3/object storage, or Mongo archival collection in this phase.
   - Recommendation: Lock one archive sink before planning tasks; keep runtime retrieval limited to active Redis workspace.

2. **Trace model depth for OPS-02**
   - What we know: `requestId` exists globally and `runId` is required at event level when available.
   - What’s unclear: Whether full OpenTelemetry instrumentation is in-scope for Phase 3 or deferred.
   - Recommendation: Treat OTel as optional enhancement; baseline requirement is structured logs + deterministic `requestId/runId` correlation.

3. **Relevance ranking function under “agent’s discretion”**
   - What we know: Ranking algorithm is discretionary if token caps/fallback are enforced.
   - What’s unclear: BM25-style keyword scoring vs embedding similarity in Phase 3 baseline.
   - Recommendation: Start with deterministic lexical ranking + recency bias, then defer semantic embeddings to later phase if needed.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Jest 30.x + Supertest 7.2.2 |
| Config file | none (Jest defaults from `backend/package.json`) |
| Quick run command | `cd backend && npm test -- --runInBand tests/sanity.test.js` |
| Full suite command | `cd backend && npm test -- --runInBand` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MEM-01 | Shared workspace persists artifacts/messages/revisions per thread/run | integration | `cd backend && npm test -- --runInBand tests/memory.workspace.persistence.test.js` | ❌ Wave 0 |
| MEM-02 | Full conversation continuity available on each agent turn | integration | `cd backend && npm test -- --runInBand tests/memory.context.continuity.test.js` | ❌ Wave 0 |
| MEM-03 | Write schema enforces provenance fields and revision semantics | unit + integration | `cd backend && npm test -- --runInBand tests/memory.provenance.schema.test.js` | ❌ Wave 0 |
| OPS-02 | Structured logs/events include correlatable `requestId`/`runId` trace linkage | integration | `cd backend && npm test -- --runInBand tests/memory.trace.correlation.test.js` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `cd backend && npm test -- --runInBand tests/memory.*.test.js`
- **Per wave merge:** `cd backend && npm test -- --runInBand tests/ai.compat.*.test.js tests/memory.*.test.js`
- **Phase gate:** Full suite green and one captured sample execution trace showing memory write/read correlation

### Wave 0 Gaps
- [ ] `backend/tests/memory.workspace.persistence.test.js` - MEM-01 contract coverage
- [ ] `backend/tests/memory.context.continuity.test.js` - MEM-02 thread continuity coverage
- [ ] `backend/tests/memory.provenance.schema.test.js` - MEM-03 schema/revision enforcement
- [ ] `backend/tests/memory.trace.correlation.test.js` - OPS-02 log/trace correlation
- [ ] `backend/tests/memory.retrieval.budget.test.js` - D-15 hard token budget + D-16 fallback behavior
- [ ] `backend/tests/helpers/memoryFixtures.js` - deterministic fixtures for history/relevance ranking
- [ ] Install tokenizer dependency: `cd backend && npm install js-tiktoken`

## Practical Planning Guidance

### Constraints to Preserve
- Keep legacy and collaborative path compatibility from Phase 2 intact; Phase 3 should be additive.
- Enforce `tenantId:userId:threadId` identity contract before every memory operation.
- Preserve strict centralized error semantics (`ApiError` + `errorHandler`) for key/schema failures.
- Guarantee append-only revision history and required provenance fields in all writes.
- Enforce bounded retrieval at orchestrator boundary before each agent call.

### Recommended Implementation Sequencing
1. **Contract Foundation**
   - Define key builder, Zod schemas, provenance contract, and error codes.
   - Add identity validation utility and 400 failure tests.
2. **Write Path and Revision Model**
   - Implement append-only event write API, revision IDs, and redaction pipeline.
   - Include `requestId/runId` on event records.
3. **Read Path and Retrieval Planner**
   - Implement recent-window retrieval (last 12), relevance search, token-budget truncation, fallback behavior.
   - Add deterministic ranking tests.
4. **Controller/Orchestrator Wiring**
   - Inject memory context into collaborative execution cycle and record post-node outputs.
   - Extend state annotation with memory references.
5. **Retention + Archive Baseline**
   - Apply 30-day active retention and archive-write workflow.
   - Ensure archive is not used by runtime retrieval in Phase 3.
6. **Observability + Verification**
   - Emit structured logs for memory writes/reads and capture execution trace correlation.
   - Run full requirement-mapped test matrix.

### Risks and Mitigations
- **Risk:** Redis available but memory layer silently bypassed during errors.
  - **Mitigation:** Fail closed for required persistence operations in collaborative mode; explicit health/metrics.
- **Risk:** Prompt inflation despite retrieval policy.
  - **Mitigation:** Enforce token limit in code, not by convention; add dedicated unit tests.
- **Risk:** Provenance drift across call sites.
  - **Mitigation:** Single write entrypoint with schema validation and lint rule/code review guard.
- **Risk:** Retention policy incorrectly implemented with stale TTL behavior.
  - **Mitigation:** Add retention integration test and periodic audit command for old keys.

## Sources

### Primary (HIGH confidence)
- `.planning/phases/03-shared-memory-and-context-infrastructure/03-CONTEXT.md` - locked decisions and constraints
- `.planning/REQUIREMENTS.md` - MEM-01, MEM-02, MEM-03, OPS-02 requirement definitions
- `.planning/ROADMAP.md` - phase goal and success criteria
- `backend/src/controllers/ai.controller.js` - integration seam for memory injection
- `backend/src/agents/efficiency_plan/state.js` - orchestration state extension target
- `backend/src/agents/efficiency_plan/collaborative.index.js` - collaborative execution scaffold
- `backend/src/agents/efficiency_plan/orchestrators/modeResolver.js` - strict validation pattern
- `backend/src/agents/efficiency_plan/orchestrators/responseEnvelope.js` - metadata correlation pattern
- `backend/src/middleware/errorHandler.js` and `backend/src/middleware/logging.middleware.js` - centralized errors + structured logging baseline
- https://redis.io/docs/latest/develop/data-types/streams/ - append-only log model, range reads, trimming, consumer semantics
- https://redis.io/docs/latest/commands/expire/ - TTL/retention and expiration semantics
- https://docs.langchain.com/oss/javascript/langgraph/persistence - threads/checkpoints/memory-store concepts
- https://docs.langchain.com/oss/javascript/langgraph/overview - durable/stateful orchestration baseline
- https://opentelemetry.io/docs/specs/otel/trace/api/ - trace ID/span context standards

### Secondary (MEDIUM confidence)
- https://github.com/redis/ioredis - client capabilities, reconnect/pipeline/streams behavior and maintenance notes
- npm registry metadata (`npm view ...`) for package versions/publish dates

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - validated with live npm registry and current repository dependencies.
- Architecture: HIGH - directly constrained by locked decisions and existing backend integration points.
- Pitfalls: MEDIUM-HIGH - based on official Redis/LangGraph behavior plus project-specific code patterns.

**Research date:** 2026-03-23
**Valid until:** 2026-04-22
