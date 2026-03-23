# Pitfalls Research

**Domain:** Production-grade collaborative multi-agent orchestration for LLM planning systems
**Researched:** 2026-03-23
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Hallucination Leakage Through Multi-Agent Agreement

**What goes wrong:**
Multiple agents repeat the same unverified claim and consensus scoring marks it as high confidence, so fabricated numbers or unsupported advice reaches `finalPlan`.

**Why it happens:**
Consensus is treated as truth, while source-grounding and evidence quality are not scored separately from fluency.

**How to avoid:**
- Add evidence-anchored claims schema: every non-trivial claim requires `evidence_type`, `evidence_ref`, and `confidence`.
- Add a verifier node that rejects claims lacking evidence or using out-of-bounds values.
- Use strict structured outputs + runtime schema validation before writing to shared memory.
- Gate publish with dual threshold: quality >= 85 and factuality >= threshold (separate metric).

**Warning signs:**
- Different agents produce near-identical claims with no citations.
- Output confidence rises while verifier rejection rate is also rising.
- Sudden spikes in high-savings recommendations not supported by user data.

**Test strategy:**
- Build adversarial prompts with contradictory or insufficient data and assert verifier blocks publication.
- Property tests for numeric bounds (e.g., rupee savings cannot exceed feasible monthly baseline).
- Golden-set evaluation with known-truth scenarios and measured factual precision/recall.

**Phase to address:**
Phase 2.2 - Structured Debate + Evidence Validation Layer

---

### Pitfall 2: Context Drift and Memory Contamination

**What goes wrong:**
Agents debate using stale or cross-user memory, causing plans to reference wrong appliance profiles, old anomalies, or unrelated threads.

**Why it happens:**
Weak namespace discipline (`thread_id`, `user_id`, memory namespace), broad memory retrieval, and no recency/relevance filters.

**How to avoid:**
- Enforce strict memory keying with tuple namespace: `(tenant_id, user_id, memory_type)`.
- Require `thread_id` on every invocation and reject missing IDs at API boundary.
- Add recency + semantic relevance filters; limit retrieved memories and include provenance tags.
- Add memory TTL and invalidation policy for derived/ephemeral reasoning artifacts.

**Warning signs:**
- Plans mention appliances not present in current `userData`.
- Same user request produces different context snapshots without data changes.
- Increasing token use from memory payload growth over time.

**Test strategy:**
- Cross-thread isolation tests: write memory in thread A, assert unreadable in thread B unless explicitly shared.
- Cross-user leak tests with synthetic tenants and canary markers.
- Replay/time-travel tests asserting deterministic context reconstruction from checkpoints.

**Phase to address:**
Phase 2.1 - Persistent Memory Foundation and Isolation Controls

---

### Pitfall 3: Retry Storms and Cascading Overload

**What goes wrong:**
Transient model/API failures trigger layered retries (node-level + orchestration-level + queue-level), amplifying traffic and causing latency collapse.

**Why it happens:**
Retries are implemented independently across layers, without global budgets, jitter, or idempotency keys.

**How to avoid:**
- Single retry owner per request path (usually orchestrator).
- Exponential backoff with jitter, bounded retries, and retry budget per request.
- Add idempotency keys for side-effecting operations (memory writes, scoring writes).
- Introduce circuit-breaker/degradation mode: fail closed on publish, not fail open with mock success.

**Warning signs:**
- Attempt count per request > expected cap.
- Error rates and request volume rise together.
- Queue depth and p95 latency climb during dependency incidents.

**Test strategy:**
- Fault injection tests (429/5xx/timeouts) asserting capped retries and bounded tail latency.
- Load tests validating no multiplicative retry behavior under partial outage.
- Idempotency tests ensuring repeated requests do not duplicate memory or scores.

**Phase to address:**
Phase 2.4 - Reliability, Retry Governance, and Graceful Degradation

---

### Pitfall 4: Non-Deterministic Consensus Loops

**What goes wrong:**
Debate and adjudication cycles fail to converge, or converge inconsistently, producing unstable outputs for identical inputs.

**Why it happens:**
No termination criteria, high model temperature variance, and circular challenge routing without quorum/iteration limits.

**How to avoid:**
- Define finite-state debate protocol with max rounds, quorum rule, and tie-break policy.
- Freeze candidate set before final scoring; do not allow unbounded new claims after round N.
- Use deterministic settings for judge/verifier roles (low temperature, fixed rubric weights).
- Add loop detector using `(state_hash, round, participants)` fingerprints.

**Warning signs:**
- Repeated round transitions with minimal delta in score.
- Same input yields materially different winners across runs.
- Orchestration traces show recurring subgraph patterns beyond expected rounds.

**Test strategy:**
- Determinism tests: run N times on fixed seed/config and assert bounded variance.
- Convergence tests with adversarial disagreement cases; assert termination within max rounds.
- Stateful fuzzing of debate transitions to detect illegal or looping state transitions.

**Phase to address:**
Phase 2.3 - Debate Protocol, Consensus Scoring, and Termination Guards

---

### Pitfall 5: Observability Gaps and Untraceable Failures

**What goes wrong:**
Production incidents cannot be diagnosed because traces do not connect node attempts, memory operations, validation decisions, and final output lineage.

**Why it happens:**
Logs are uncorrelated, no request/trace IDs, and quality-gate decisions are not emitted as structured telemetry.

**How to avoid:**
- Instrument traces, metrics, and logs with shared correlation IDs (`request_id`, `thread_id`, `user_id_hash`, `run_id`).
- Emit structured events for: retrieval set, verifier failures, score breakdown, gate decision, retries.
- Define SLO-driven dashboards: pass rate, hallucination reject rate, retry budget burn, loop termination rate.
- Add audit trail table for publish decisions with reproducible inputs (redacted).

**Warning signs:**
- Cannot answer "why was this plan published/rejected" within 5 minutes.
- High error budget burn with unknown top failing node.
- Missing lineage from final plan back to source anomalies/strategies.

**Test strategy:**
- Telemetry contract tests asserting required fields on every critical event.
- Incident game-days: inject failures and verify on-call can root-cause via traces alone.
- Regression tests that fail if dashboards/alerts lose required dimensions.

**Phase to address:**
Phase 2.5 - Observability, Auditability, and Quality Gate Telemetry

---

### Pitfall 6: Silent Fallbacks That Mask Real Failures

**What goes wrong:**
When provider calls fail, mock/fallback payloads are returned as valid outputs, hiding outages and contaminating quality metrics.

**Why it happens:**
Fail-open behavior is optimized for demo continuity, not production correctness.

**How to avoid:**
- Distinguish `degraded` from `success` in response schema and metrics.
- Block final publish when critical nodes are in fallback mode unless explicit operator override.
- Tag all fallback outputs with `synthetic=true` and exclude from model quality KPIs.

**Warning signs:**
- Stable success rates during known provider outages.
- Repeated generic plan text despite diverse inputs.
- Sudden drop in variance of outputs and score inflation.

**Test strategy:**
- Chaos tests that disable model providers and assert `degraded` status propagates.
- Contract tests ensuring fallback outputs cannot pass production publish gate.

**Phase to address:**
Phase 2.4 - Reliability, Retry Governance, and Graceful Degradation

---

### Pitfall 7: Schema Drift Between Prompts, Validators, and Storage

**What goes wrong:**
Agents emit fields that parse locally but fail downstream contracts, or pass parsing but violate domain constraints.

**Why it happens:**
Prompt-defined schemas diverge from runtime validators and persistence schema over time.

**How to avoid:**
- Single source of truth for schemas (versioned JSON Schema + generated types).
- Validate at every boundary: model output, inter-node state, DB write.
- CI rule: fail build on schema mismatch between prompts/contracts/types.

**Warning signs:**
- Increased JSON parse/validation failures after prompt edits.
- Breaking changes in downstream consumer without code changes in consumers.
- Frequent hotfixes around field names or enum values.

**Test strategy:**
- Contract tests from canonical schema fixtures.
- Backward-compatibility tests for N-1 schema versions.
- Mutation tests that inject extra/renamed fields and assert rejection.

**Phase to address:**
Phase 2.2 - Structured Debate + Evidence Validation Layer

---

### Pitfall 8: Prompt/Policy Injection in Shared Debate Context

**What goes wrong:**
One agent or untrusted user input injects instructions that alter validator or judge behavior, bypassing quality gates.

**Why it happens:**
System policy and untrusted content are concatenated without role separation and sanitization.

**How to avoid:**
- Strict role separation: system policy immutable, user/memory content treated as untrusted data.
- Sanitization and quoting of retrieved memory blocks before reuse in prompts.
- Add policy-violation detector before consensus scoring.

**Warning signs:**
- Judge output references instructions that only appeared in user text.
- Sudden changes in rubric application after adversarial inputs.
- Gate bypass events clustered around specific prompt patterns.

**Test strategy:**
- Red-team prompt-injection suite against each agent role.
- Regression tests for known jailbreak strings in memory and user input.

**Phase to address:**
Phase 2.2 - Structured Debate + Evidence Validation Layer

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Parse model JSON via regex/trim only | Fast to ship | Fragile parsing, silent corruption | Never for production publish path |
| In-memory checkpointer/store in production | Simple setup | Data loss, no replay/audit fidelity | Only local dev and CI smoke tests |
| Mock success fallback on provider failure | Better demos | Masks outages and quality regressions | Only explicit sandbox mode |
| Consensus by averaging agent scores only | Low implementation effort | Shared hallucinations pass as "agreement" | Never without evidence verifier |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| LangGraph checkpointer/store | Using only in-memory persistence and missing `thread_id` | Use persistent saver/store (Postgres/Redis) and enforce required `thread_id` in API contract |
| Multi-provider LLM calls | Env var mismatch and provider-specific fallback confusion | Provider adapter layer with explicit health checks and normalized error taxonomy |
| JSON contracts | Prompt schema differs from runtime validators | Generate validators/types from one versioned JSON Schema source |
| Telemetry backend | Logs only, no trace correlation across nodes | Emit OpenTelemetry traces + metrics + structured logs with shared IDs |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unbounded memory retrieval into prompts | Rising token cost, latency spikes | Top-k retrieval, summarization, token budgets per node | Typically at 1k+ active users or long-lived threads |
| Debate round explosion | Tail latency and cost variance | Max rounds, loop detector, deterministic judge | During noisy inputs or model instability |
| Retry multiplication across layers | Error storm and queue saturation | Single retry owner, jitter, bounded retry budget | During partial provider outages |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Storing raw PII in long-term memory without minimization | Privacy breach and compliance risk | PII redaction/tokenization before memory write; encryption at rest |
| Cross-tenant memory namespace collisions | Data leakage across users | Tenant-scoped namespace keys and access-control checks |
| Prompt injection from retrieved memory | Gate bypass and unsafe plans | Treat memory as untrusted input; sanitize and policy-check before model call |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Non-deterministic plan outputs for same input | Trust erosion | Deterministic consensus config + explainable score breakdown |
| Hidden degraded mode | Users act on low-quality fallback plans | Show clear degraded status and confidence bands |
| Opaque quality gate rejection | Confusing "try again" loop | Return actionable rejection reasons and missing evidence hints |

## "Looks Done But Isn't" Checklist

- [ ] **Persistent memory:** Often missing strict namespace isolation - verify cross-user/thread leak tests pass.
- [ ] **Debate consensus:** Often missing termination guards - verify max rounds and loop detector metrics.
- [ ] **Quality gating:** Often missing separate factuality metric - verify hallucination red-team suite blocks publish.
- [ ] **Retry logic:** Often missing global retry budget - verify fault-injection tests cap attempts.
- [ ] **Observability:** Often missing end-to-end lineage - verify final plan can be traced to source evidence.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Hallucination leakage in production outputs | HIGH | Freeze publish gate, replay affected runs, invalidate impacted plans, patch verifier rules, re-evaluate golden set |
| Context contamination/data leak | HIGH | Disable shared retrieval, rotate namespaces, run leak audit, notify security/compliance workflow |
| Retry storm incident | MEDIUM | Activate retry kill-switch, enforce fixed low retry cap, drain queues, restore with jittered ramp-up |
| Consensus loop deadlock | MEDIUM | Force terminate at orchestrator, emit incident artifact, patch transition rules and tie-break policy |
| Observability gap during outage | HIGH | Enable emergency verbose tracing profile, add minimal mandatory event fields, backfill missing run metadata |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Hallucination leakage | Phase 2.2 | Adversarial factuality suite + verifier pass/fail audit |
| Context drift/memory contamination | Phase 2.1 | Isolation tests + replay consistency checks |
| Retry storms | Phase 2.4 | Fault-injection load tests with retry budget assertions |
| Non-deterministic consensus loops | Phase 2.3 | Convergence and determinism test suite |
| Observability gaps | Phase 2.5 | Telemetry contract tests + incident game-day runbook drill |
| Silent fallback masking | Phase 2.4 | Chaos tests with provider outages and publish gate assertions |
| Schema drift | Phase 2.2 | CI schema compatibility and boundary validation tests |
| Prompt/policy injection | Phase 2.2 | Red-team injection tests and policy violation detector metrics |

## Sources

- LangGraph persistence (threads, checkpoints, stores): https://docs.langchain.com/oss/javascript/langgraph/persistence (MEDIUM)
- LangGraph overview (durable execution, debugging): https://docs.langchain.com/oss/javascript/langgraph/overview (MEDIUM)
- OpenAI Structured Outputs (schema adherence, refusals, JSON mode caveats): https://developers.openai.com/api/docs/guides/structured-outputs (MEDIUM)
- AWS Builders Library on retries/backoff/jitter and retry amplification: https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/ (MEDIUM)
- OpenTelemetry observability primer (traces/metrics/logs, distributed tracing): https://opentelemetry.io/docs/concepts/observability-primer/ (MEDIUM)
- Repository analysis of current orchestration implementation:
  - backend/src/agents/efficiency_plan/index.js
  - backend/src/agents/efficiency_plan/state.js
  - backend/src/agents/efficiency_plan/analyst.node.js
  - backend/src/agents/efficiency_plan/strategist.node.js
  - backend/src/agents/efficiency_plan/copywriter.node.js

---
*Pitfalls research for: v2.0 Production-Grade Collaborative Multi-Agent System*
*Researched: 2026-03-23*
