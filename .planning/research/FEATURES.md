# Feature Research

**Domain:** Production-grade collaborative multi-agent energy planning backend (milestone v2.0)
**Researched:** 2026-03-23
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist for a production system. Missing these = system feels untrustworthy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Persistent shared workspace memory with provenance | Users expect all agents to use the same context and not contradict prior turns | HIGH | User-visible: plan references prior facts consistently across steps. Operator-visible: each memory item has source, timestamp, and writer agent metadata. Concerns: memory, orchestration, reliability. |
| Agent self-reflection and self-validation before publishing output | Users expect the system to catch obvious mistakes before showing recommendations | MEDIUM | User-visible: fewer internally inconsistent recommendations. Operator-visible: per-agent reflection checklist pass/fail logged before publish. Concerns: validation, reliability. |
| Cross-agent validation gate (challenge + verify) | Users expect claims to be challenged, not blindly accepted by downstream agents | HIGH | User-visible: recommendations include resolved rationale when challenged. Operator-visible: challenge records contain claim, challenger, response, resolution state. Concerns: validation, orchestration. |
| Quality scoring with hard release threshold (>=85) and fail-closed behavior | Users expect low-quality plans to be blocked rather than shipped | MEDIUM | User-visible: low-confidence plans return actionable retry/fallback messaging, not fabricated certainty. Operator-visible: score components and gate decision are logged for every run. Concerns: validation, reliability. |
| Execution trace transparency for each run | Users expect explainability for why a plan exists; operators need auditability | MEDIUM | User-visible: concise explanation trail (what changed and why). Operator-visible: full trace graph with node inputs/outputs, retries, and guardrail decisions. Concerns: orchestration, reliability. |

### Differentiators (Competitive Advantage)

Features that materially improve trust and decision quality beyond baseline production expectations.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Structured debate protocol with bounded rounds and explicit resolution outcomes | Improves recommendation quality by forcing adversarial testing of weak assumptions | HIGH | User-visible: contentious recommendations include "debated and resolved" justification. Operator-visible: debate transcript with per-round outcome and termination reason (resolved/timeout/escalated). Concerns: validation, orchestration. |
| Weighted consensus model across specialist agents | Produces better final decisions than majority vote by weighting domain expertise and confidence | HIGH | User-visible: final recommendation prioritizes strongest specialist evidence. Operator-visible: weight vector, confidence inputs, and final consensus math are exposed. Concerns: orchestration, validation. |
| Quality score decomposition (factuality, actionability, consistency, safety, personalization) | Makes quality actionable instead of opaque, enabling rapid tuning and SLO ownership | MEDIUM | User-visible: transparent reason when plan is blocked (for example, low factuality). Operator-visible: component scores with threshold policy and trend monitoring. Concerns: validation, reliability. |
| Trace replay mode for post-incident debugging | Reduces MTTR by replaying execution with same inputs and policy version | HIGH | User-visible: improved stability over time from faster fixes. Operator-visible: deterministic replay artifacts linked to incident IDs. Concerns: reliability, orchestration. |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem attractive but degrade correctness, reliability, or operability.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Unlimited/open-ended debate loops | "More debate means better answers" | Creates non-terminating orchestration, latency blowups, and cost volatility | Bounded debate rounds with clear stop conditions and escalation policy |
| Opaque single-number quality score without evidence | "Keep scoring simple" | Hides failure modes and prevents targeted remediation or policy tuning | Multi-component quality scorecard with per-component thresholds |
| Auto-publish when one agent fails (silent partial success) | "Never block output" | Encourages hallucinated completions and hides degraded quality | Fail-closed for critical validations; explicit degraded-mode response for users |
| Shared mutable memory without versioning/provenance | "Fast collaboration" | Causes context corruption, race conditions, and un-auditable decisions | Append-first memory model with revision IDs, provenance, and conflict resolution |
| Hidden fallback/mocked data in production responses | "Keep UX smooth" | Breaks trust and contaminates decision quality when synthetic data is presented as real | Explicit fallback labeling plus operator alerting and retry policy |

## Expected Behavior Contracts

### User-Visible Behavior

| Capability | Observable Behavior | Testability |
|------------|---------------------|-------------|
| Persistent memory | Follow-up plans reuse confirmed prior constraints without re-asking | Given prior accepted constraint, next run references same constraint in final plan |
| Self-reflection | Agent removes contradictions before final output | Inject contradictory draft; verify contradiction is removed or run is blocked |
| Cross-validation | Claims can be challenged and either corrected or rejected | Seed false claim; verify challenge event and non-acceptance in final plan |
| Quality gate | Low-quality output is blocked with actionable message | Force score <85; verify no final publish and user receives retry/degraded guidance |
| Trace transparency | User can view concise "why this plan" trail | Verify summary trace contains major decisions and quality gate outcome |

### Operator-Visible Behavior

| Capability | Observable Behavior | Testability |
|------------|---------------------|-------------|
| Memory provenance | Every memory write has writer, source, timestamp, and revision | Validate persisted memory records for required metadata fields |
| Debate protocol observability | Debate rounds, outcomes, and stop reason are recorded | Verify trace contains round count and terminal state |
| Weighted consensus observability | Weight and confidence inputs are inspectable per decision | Verify run artifact includes weights, inputs, and final aggregate score |
| Quality scoring observability | Component scores and gate decision are queryable | Verify dashboards/logs expose component breakdown per run ID |
| Reliability controls | Retries, timeouts, and fallback modes are explicit in traces | Inject provider failure; verify retry path and labeled degraded state |

## Feature Dependencies

```text
Persistent Shared Memory + Provenance
    --> Self-Reflection (needs stable prior context)
    --> Cross-Agent Validation (needs shared claims/evidence)

Cross-Agent Validation
    --> Structured Debate Protocol (formalizes challenge-response)

Structured Debate Protocol
    --> Weighted Consensus (consumes debated positions + confidence)

Weighted Consensus + Validation Artifacts
    --> Quality Score Decomposition

Quality Score Decomposition
    --> Hard Quality Gate (>=85)

All Above + Runtime Instrumentation
    --> Execution Trace Transparency

Execution Trace Transparency
    --> Trace Replay Mode
```

### Dependency Notes

- **Self-reflection requires persistent memory:** reflection quality drops if each node only sees local transient state.
- **Debate requires cross-validation first:** without structured challenge artifacts, debate is ungrounded conversation.
- **Weighted consensus requires debate outputs:** weighting only works when each position is explicit and evidence-backed.
- **Hard quality gates require score decomposition:** a single score cannot safely drive block/allow policy in production.
- **Trace replay depends on full trace transparency:** deterministic replay is impossible without complete inputs, policy versions, and transition logs.

## MVP Definition

### Launch With (v2.0 Milestone Core)

- [ ] Persistent shared memory with provenance and revision IDs
- [ ] Self-reflection and cross-agent validation before publish
- [ ] Hard quality gate at >=85 with fail-closed behavior
- [ ] End-to-end execution traces for every run
- [ ] Reliability baseline: retries, timeout handling, explicit degraded-mode responses

### Add After Validation (v2.0.x)

- [ ] Structured multi-round debate protocol with escalation paths
- [ ] Weighted consensus across specialist agents
- [ ] Score decomposition dashboards and alert thresholds

### Future Consideration (v3+)

- [ ] Adaptive agent weighting learned from historical outcome quality
- [ ] Policy simulation/sandbox to evaluate threshold changes before production rollout

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Persistent shared memory + provenance | HIGH | HIGH | P1 |
| Self-reflection + cross-validation gate | HIGH | HIGH | P1 |
| Hard quality gate (>=85) | HIGH | MEDIUM | P1 |
| Execution trace transparency | HIGH | MEDIUM | P1 |
| Reliability controls (retry/timeout/degraded mode) | HIGH | MEDIUM | P1 |
| Structured debate protocol | MEDIUM | HIGH | P2 |
| Weighted consensus | MEDIUM | HIGH | P2 |
| Score decomposition dashboards | MEDIUM | MEDIUM | P2 |
| Replay mode | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for milestone v2.0 production launch
- P2: Should have after production baseline is stable
- P3: Nice to have once observability and policy maturity improve

## Implementation Concern Mapping

| Feature | Memory | Validation | Orchestration | Reliability |
|---------|--------|------------|---------------|-------------|
| Persistent shared memory + provenance | Primary | Supports | Primary | Supports |
| Self-reflection + cross-validation | Depends | Primary | Primary | Supports |
| Structured debate protocol | Supports | Primary | Primary | Supports |
| Weighted consensus | Supports | Primary | Primary | Supports |
| Quality scoring + hard gate | Supports | Primary | Supports | Primary |
| Execution trace transparency | Supports | Supports | Primary | Primary |

## Sources

- Internal project scope: `.planning/PROJECT.md`
- Internal milestone requirements context: `.planning/REQUIREMENTS.md`
- Current orchestration baseline: `backend/src/agents/efficiency_plan/index.js`
- Current state schema baseline: `backend/src/agents/efficiency_plan/state.js`
- Current node behavior/fallback paths:
  - `backend/src/agents/efficiency_plan/analyst.node.js`
  - `backend/src/agents/efficiency_plan/strategist.node.js`
  - `backend/src/agents/efficiency_plan/copywriter.node.js`
- Prompt-level current behavioral constraints:
  - `backend/src/agents/efficiency_plan/analyst.prompt.js`
  - `backend/src/agents/efficiency_plan/strategist.prompt.js`
  - `backend/src/agents/efficiency_plan/copywriter.prompt.js`

---
*Feature research for: production-grade collaborative multi-agent planning milestone (v2.0)*
*Researched: 2026-03-23*
