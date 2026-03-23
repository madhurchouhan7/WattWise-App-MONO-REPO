# Phase 3: Shared Memory and Context Infrastructure - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish persistent, auditable shared memory infrastructure for collaborative orchestration. This phase defines storage/isolation, retention, provenance, and bounded retrieval contracts used by agents at runtime.

</domain>

<decisions>
## Implementation Decisions

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

</decisions>

<specifics>
## Specific Ideas

- Keep continuity with Phase 2 metadata and request tracing by carrying `requestId` and `runId` through memory events.
- Preserve controller-driven orchestration style while adding reusable memory service modules under efficiency plan infrastructure.
- Treat memory as a first-class audited event stream, not mutable blobs.

</specifics>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase anchors and requirements

- `.planning/ROADMAP.md` — Phase 3 goal, requirements, and success criteria.
- `.planning/REQUIREMENTS.md` — MEM-01, MEM-02, MEM-03, OPS-02 requirement constraints.
- `.planning/PROJECT.md` — Milestone intent and compatibility/reliability priorities.
- `.planning/STATE.md` — Current planning position and active focus.

### Prior-phase locked decisions

- `.planning/phases/02-compatibility-foundation-and-dual-path-routing/02-CONTEXT.md` — Phase 2 routing/error/metadata decisions to preserve.
- `.planning/phases/02-compatibility-foundation-and-dual-path-routing/02-RESEARCH.md` — Foundation guidance and risk context.

### Current orchestration integration points

- `backend/src/controllers/ai.controller.js` — Current entrypoint and metadata envelope flow.
- `backend/src/agents/efficiency_plan/state.js` — Existing state annotation to extend for memory context.
- `backend/src/agents/efficiency_plan/collaborative.index.js` — Collaborative path scaffold where memory wiring can be introduced.
- `backend/src/agents/efficiency_plan/orchestrators/modeResolver.js` — Existing routing contract that should remain stable while memory layer is added.
- `backend/src/agents/efficiency_plan/orchestrators/responseEnvelope.js` — Existing metadata envelope contract to align with memory trace IDs.
- `backend/src/middleware/errorHandler.js` — Centralized error shape for memory-validation failures.

</canonical_refs>

<code_context>

## Existing Code Insights

### Reusable Assets

- Resolver + response-envelope utilities already exist and can carry memory-related identifiers.
- Controller currently centralizes orchestration dispatch and response assembly, making it the primary integration seam for memory context injection.
- Existing request ID middleware in app startup provides trace key foundation.

### Established Patterns

- Additive module pattern under `backend/src/agents/efficiency_plan/` is already established from Phase 2.
- Strict validation via `ApiError` + centralized `errorHandler` is the current reliability baseline.
- Legacy path preservation remains non-negotiable; memory additions should be additive and mode-safe.

### Integration Points

- Introduce memory workspace modules under `backend/src/agents/efficiency_plan/shared/` (or equivalent) and wire through collaborative path first.
- Extend state annotation to carry memory event references and retrieval payloads.
- Add retrieval budget and provenance enforcement at orchestrator/service boundary before agent node invocation.

</code_context>

<deferred>
## Deferred Ideas

- Archive readback search and analytics dashboards are deferred beyond Phase 3 baseline.
- Advanced adaptive retrieval tuning (learned ranking/weights) is deferred to later phases.

</deferred>

---

_Phase: 03-shared-memory-and-context-infrastructure_
_Context gathered: 2026-03-23_
