# Milestone v2.0 Roadmap

**5 phases** | **21 requirements mapped** | Coverage complete ✓

Phase numbering continues from prior milestone phases.

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 2 | Compatibility Foundation and Dual-Path Routing | Add collaborative orchestration entrypoint while preserving legacy flow and API contract | COMP-01, COMP-02, OPS-03 | 4 |
| 3 | Shared Memory and Context Infrastructure | Implement persistent workspace and conversation continuity with provenance and isolation | MEM-01, MEM-02, MEM-03, OPS-02 | 5 |
| 4 | Agent Reflection, Validation, and Cross-Checks | Upgrade Analyst/Strategist/Copywriter agents with self-validation and cross-agent challenge | AGENT-01, AGENT-02, AGENT-03, QA-02 | 5 |
| 5 | Debate, Consensus, and Quality Gates | Add bounded debate, weighted consensus, and enforce final gate >=85 with auditable scores | DEBATE-01, DEBATE-02, DEBATE-03, QA-01, QA-03, NFR-02 | 6 |
| 6 | Reliability, Testing, and Production Readiness | Finalize retry/degradation/error handling, tests, docs, and execution-trace handoff | OPS-01, COMP-03, NFR-01, NFR-03 | 6 |

## Phase Details

### Phase 2: Compatibility Foundation and Dual-Path Routing
Goal: Build additive collaborative path without breaking current production behavior.
Requirements: COMP-01, COMP-02, OPS-03
Success criteria:
1. Existing linear entrypoint remains callable and behavior-compatible.
2. New collaborative entrypoint exists and is selectable via explicit routing/flag.
3. Output contract remains API-compatible (`finalPlan` + metadata extensions allowed).
4. Centralized error handler returns structured failure payloads without process crash.

### Phase 3: Shared Memory and Context Infrastructure
Goal: Establish persistent, auditable memory as collaboration foundation.
Requirements: MEM-01, MEM-02, MEM-03, OPS-02
Success criteria:
1. Shared workspace persists artifacts, messages, and revisions per run/thread.
2. Full conversation history is accessible to all agents each cycle.
3. Memory writes include provenance fields (agent, timestamp, evidence/source refs).
4. Execution trace IDs correlate workspace events and logs.
5. Context retrieval supports bounded/filtered recall to avoid prompt bloat.

### Phase 4: Agent Reflection, Validation, and Cross-Checks
Goal: Ensure each specialist is self-correcting and peer-checkable.
Requirements: AGENT-01, AGENT-02, AGENT-03, QA-02
Success criteria:
1. Analyst/Strategist/Copywriter each run self-reflection before publish.
2. Schema + evidence validation rejects malformed or unsupported claims.
3. Agents can raise structured challenges against prior outputs.
4. Failed validations route to revision loops with bounded retry budgets.
5. Hallucination checks block unsupported claims from advancing.

### Phase 5: Debate, Consensus, and Quality Gates
Goal: Resolve disagreement rigorously and publish only high-quality consensus.
Requirements: DEBATE-01, DEBATE-02, DEBATE-03, QA-01, QA-03, NFR-02
Success criteria:
1. Debate protocol supports bounded rounds with deterministic stop conditions.
2. Weighted voting combines specialist confidence and role priorities.
3. Consensus log records positions, votes, and rationale per round.
4. Quality gate enforces minimum score >=85 before publication.
5. Score output includes dimension breakdown and fail reasons.
6. Unresolved/tied debates route to revision or safe fallback path.

### Phase 6: Reliability, Testing, and Production Readiness
Goal: Harden system for production operation and team handoff.
Requirements: OPS-01, COMP-03, NFR-01, NFR-03
Success criteria:
1. Retry/timeout/degradation policies are implemented and tested.
2. Integration tests cover happy path, debate conflict, gate fail, and fallback behavior.
3. README documents architecture, setup, usage, and debugging flow.
4. Example execution trace demonstrates full collaboration lifecycle.
5. Observability captures per-agent attempts, revisions, and timing.
6. Baseline performance/quality checks are reported with thresholds.

## Requirement Coverage Matrix

- Phase 2 -> COMP-01, COMP-02, OPS-03
- Phase 3 -> MEM-01, MEM-02, MEM-03, OPS-02
- Phase 4 -> AGENT-01, AGENT-02, AGENT-03, QA-02
- Phase 5 -> DEBATE-01, DEBATE-02, DEBATE-03, QA-01, QA-03, NFR-02
- Phase 6 -> OPS-01, COMP-03, NFR-01, NFR-03

All active milestone requirements are mapped to at least one phase.
