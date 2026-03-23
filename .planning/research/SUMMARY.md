# Project Research Summary

**Project:** WattWise
**Domain:** Production-grade collaborative multi-agent energy planning backend
**Researched:** 2026-03-23
**Confidence:** MEDIUM-HIGH

## Executive Summary

WattWise v2.0 is a reliability-first upgrade of an existing LangGraph-based linear planning pipeline into a collaborative multi-agent orchestration system. The research converges on an additive migration strategy: preserve the current API contract and legacy execution path, then introduce a feature-gated collaborative path with persistent shared memory, cross-agent validation, quality gating, and stronger observability. This is the standard expert approach for high-risk orchestration upgrades where regressions are costly.

The recommended implementation is not a stack rewrite. Keep Node.js + Express, keep existing LangGraph orchestration foundations, and add Redis-backed LangGraph checkpointing/store, deterministic quality controls, and production telemetry. Pair this with bounded debate and consensus patterns only after core memory, validation, and fail-closed publication behavior are stable. In short: compatibility first, then collaborative intelligence, then optimization.

The primary risk is false confidence: multiple agents can agree on unsupported claims unless evidence validation, factuality scoring, and publish controls are strict. Secondary risks are memory contamination across threads/users, retry storms during provider incidents, and observability blind spots. Mitigations are clear and should be mandatory: namespace isolation, required thread IDs, single retry owner with budgets, hard loop limits, and correlated trace/log/metric telemetry with auditable gate decisions.

## Key Findings

### Recommended Stack

Research recommends a targeted additive stack extension around the current backend, not replacement.

**Core technologies:**

- Node.js + Express (keep current runtime, express 5.2.1): API/control surface remains stable while orchestration internals evolve.
- LangGraph (keep current baseline, 1.2.5): Existing orchestration capability already supports durable, stateful multi-agent patterns.
- Redis-backed checkpoint/store (add `@langchain/langgraph-checkpoint-redis` 1.0.4): Enables durable thread continuity, replayability, and shared workspace memory.

**Supporting additions (high impact):**

- Reliability policy layer: `cockatiel` for bounded retry/timeout/circuit-breaker behavior.
- Observability baseline: OpenTelemetry + `prom-client` + `pino`/`pino-http` for trace-metric-log correlation.
- Test hardening: `supertest`, `testcontainers`, `nock` for contract regression, persistence, and fault-injection scenarios.

**What should remain unchanged (mandatory):**

- Existing linear graph entrypoint/exports in efficiency plan module.
- Existing state channels and node contracts used by current analyst/strategist/copywriter flow.
- Existing Express controller/response contract for AI plan generation.
- Existing Redis/Mongo platform foundations (reuse operational footprint; no datastore migration this milestone).

### Expected Features

The feature research separates launch-critical capabilities from post-baseline differentiators.

**Must have (table stakes):**

- Persistent shared memory with provenance and revision metadata.
- Self-reflection plus cross-agent validation before publication.
- Hard quality gate (>=85) with fail-closed behavior.
- End-to-end trace transparency for every run.
- Reliability controls: explicit retries/timeouts/degraded-mode signaling.

**Should have (competitive):**

- Structured, bounded debate protocol with explicit resolution outcomes.
- Weighted specialist consensus (not naive majority voting).
- Quality score decomposition (factuality/actionability/consistency/safety/personalization).
- Deterministic replay artifacts for faster incident triage.

**Anti-features to reject in this milestone:**

- Unbounded debate loops.
- Opaque single-number quality scoring without evidence.
- Silent partial success or auto-publish on agent failure.
- Shared mutable memory without provenance/versioning.
- Hidden synthetic fallback data presented as real output.

**Defer (v2.0.x / v3+):**

- Advanced debate/weighted consensus enhancements can follow baseline stability.
- Adaptive learned agent weighting and policy simulation should remain v3+ exploration.

### Architecture Approach

Architecture should follow a dual-path strangler pattern: keep the legacy graph untouched and introduce a new collaborative graph behind a service facade and feature flags. Roll out in shadow mode first, then canary cohorts, then progressive ramp with a kill switch and config-only rollback.

**Major components:**

1. Orchestration facade (`service.js`) - stable controller integration, mode routing, fallback governance.
2. Collaborative graph subtree - workspace builder, debate/revision nodes, consensus, and quality gates.
3. Memory/checkpoint adapter - durable thread state with strict `thread_id` discipline.
4. Contract adapter - guarantees output remains API-compatible with current `finalPlan` shape.
5. Observability hooks - node-level traces, score/gate events, retries, and route decisions.

### Critical Pitfalls

1. **Hallucination leakage via false consensus** - enforce evidence-bound claim schema, verifier node, and separate factuality threshold in gate policy.
2. **Context drift and memory contamination** - require strict namespace keys (`tenant_id`, `user_id`, `thread_id`), recency/relevance filters, and TTL/invalidation.
3. **Retry storms and cascading overload** - set a single retry owner, exponential backoff + jitter, and request-level retry budgets with circuit-breaker behavior.
4. **Non-deterministic debate loops** - enforce max rounds, quorum/tie-break rules, loop detection, and low-variance judge settings.
5. **Observability gaps** - require correlated IDs and structured events for retrieval, validation, scoring, gate decisions, and retries.

## Implications for Roadmap

Based on dependencies and risk concentration, use a 5-phase v2.0 roadmap:

### Phase 1: Compatibility Foundation and Dual-Path Facade

**Rationale:** No safe collaborative rollout exists without a stable integration seam and rollback path.
**Delivers:** `service.js` orchestration facade, feature flag routing, legacy-default behavior, backward-compatible state key extensions.
**Addresses:** Contract stability and migration safety.
**Avoids:** Big-bang rewrite regressions and uncontrolled rollout risk.

### Phase 2: Persistent Memory and Isolation Controls

**Rationale:** Shared workspace quality depends on durable and isolated memory before advanced collaboration logic.
**Delivers:** Redis-backed checkpointer/store, strict thread/user/tenant namespace model, provenance metadata, isolation tests.
**Addresses:** Table-stakes persistent memory and provenance.
**Avoids:** Context drift, cross-thread/user contamination.

### Phase 3: Validation, Debate, and Consensus Core

**Rationale:** Debate/consensus is only valuable after memory foundations and strict schema controls exist.
**Delivers:** Cross-agent challenge flow, bounded debate rounds, verifier/evidence schema checks, weighted consensus mechanics.
**Addresses:** Self-validation, cross-agent validation, differentiator-level collaborative quality.
**Avoids:** Hallucination agreement, consensus deadlocks, schema drift.

### Phase 4: Quality Gate and Reliability Governance

**Rationale:** Production confidence requires deterministic publish policy and incident-safe failure behavior.
**Delivers:** Score decomposition + >=85 gate enforcement, fail-closed publish rules, retry-budget policies, degraded-mode contract semantics.
**Addresses:** Hard quality threshold and reliability baseline.
**Avoids:** Silent fallback masking, retry amplification, low-quality publication.

### Phase 5: Observability, Shadow-to-Canary Rollout, and Hardening

**Rationale:** Full rollout should happen only after telemetry can prove safety and quality.
**Delivers:** Correlated tracing/logs/metrics, gate outcome dashboards, shadow comparison reports, progressive ramp + kill switch procedures.
**Addresses:** Trace transparency and operational readiness.
**Avoids:** Untraceable incidents and slow rollback.

### Phase Ordering Rationale

- Memory/isolation must precede debate/consensus to prevent contaminated collaboration.
- Validation and bounded debate must precede hard gate tuning to avoid scoring noisy artifacts.
- Reliability and explicit degraded semantics must be in place before broad traffic exposure.
- Observability and canary controls should gate progressive rollout, not follow it.

### Research Flags

Phases likely needing deeper research during planning:

- **Phase 2:** Redis operational shape (Redis 8/Stack modules), checkpoint scaling and retention policies.
- **Phase 3:** Evidence schema design, deterministic consensus weighting, and anti-injection guardrails.
- **Phase 4:** Retry budget calibration per provider and safe degraded-mode UX contract.

Phases with standard patterns (can likely skip deep research-phase):

- **Phase 1:** Service facade + feature flag strangler rollout is a mature pattern.
- **Phase 5 (instrumentation mechanics):** OTEL + structured logging + metric baseline are well-established.

## Confidence Assessment

| Area         | Confidence  | Notes                                                                                                                 |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------------- |
| Stack        | MEDIUM-HIGH | Strong official docs support for LangGraph and OTEL; some package/infrastructure choices need environment validation. |
| Features     | HIGH        | Internally consistent with milestone intent and existing codebase constraints; clear dependency graph.                |
| Architecture | HIGH        | Migration strategy and component boundaries are concrete, compatibility-safe, and implementation-ready.               |
| Pitfalls     | MEDIUM      | Risks are well-known and actionable, but control tuning (thresholds, budgets) requires empirical calibration.         |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Consensus calibration data:** Need offline evaluation dataset to set specialist weights and gate thresholds without overfitting.
- **Redis capability validation:** Confirm target environments satisfy Redis module/version requirements before phase commitment.
- **Provider failure taxonomy:** Normalize cross-provider error classes for reliable retry/circuit-breaker policy enforcement.
- **PII handling in memory traces:** Finalize redaction/tokenization standard before long-term persistence is enabled.

## Sources

### Primary (HIGH confidence)

- https://docs.langchain.com/oss/javascript/langgraph/overview - orchestration and durable execution model
- https://docs.langchain.com/oss/javascript/langgraph/persistence - thread/checkpoint/store patterns
- https://opentelemetry.io/docs/languages/js/getting-started/nodejs/ - Node telemetry baseline
- Internal planning context: `.planning/PROJECT.md`, `.planning/research/STACK.md`, `.planning/research/FEATURES.md`, `.planning/research/ARCHITECTURE.md`, `.planning/research/PITFALLS.md`

### Secondary (MEDIUM confidence)

- https://www.npmjs.com/package/@langchain/langgraph-checkpoint-redis - Redis checkpointer requirements and package guidance
- https://github.com/siimon/prom-client - metrics instrumentation capabilities
- https://github.com/connor4312/cockatiel - resilience policy primitives
- https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/ - retry/backoff failure dynamics

### Tertiary (LOW confidence)

- None identified as roadmap-critical; all low-confidence assumptions were converted into explicit gaps/flags.

---

_Research completed: 2026-03-23_
_Ready for roadmap: yes_
