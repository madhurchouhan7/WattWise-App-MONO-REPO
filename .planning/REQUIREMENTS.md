# Milestone v2.0 Requirements

## Scope
Upgrade the existing linear efficiency-plan pipeline (Analyst -> Strategist -> Copywriter) into a production-grade collaborative multi-agent system while preserving backward compatibility with current entrypoints.

## Functional Requirements

### Shared Memory and Context (MEM)
- [ ] **MEM-01**: All agents must read from and write to a shared persistent workspace that stores full run context and artifact history.
- [ ] **MEM-02**: Conversation history must be retained across node/agent transitions and available to every agent on each turn.
- [ ] **MEM-03**: Memory records must include provenance metadata (agent, timestamp, source/evidence, revision).

### Agent Intelligence and Validation (AGENT)
- [ ] **AGENT-01**: Each agent must perform self-reflection/self-check before publishing output to shared workspace.
- [ ] **AGENT-02**: Each agent output must pass strict schema validation and evidence validation before downstream use.
- [ ] **AGENT-03**: Cross-agent validation must be supported so one agent can challenge/correct another agent's proposal.

### Debate and Consensus (DEBATE)
- [ ] **DEBATE-01**: System must support bounded multi-round debate with explicit stop conditions.
- [ ] **DEBATE-02**: Consensus must use weighted voting across agent roles and produce an auditable decision log.
- [ ] **DEBATE-03**: Unresolved debates must route to revision or safe fallback, never silent publish.

### Quality and Hallucination Control (QA)
- [ ] **QA-01**: Final output must pass multi-layer quality gate with minimum score threshold >= 85.
- [ ] **QA-02**: Hallucination detection must block unsupported or invented claims from final publish.
- [ ] **QA-03**: Gate results must include per-dimension score breakdown and failure reasons.

### Reliability and Observability (OPS)
- [ ] **OPS-01**: Orchestration must include retry, timeout, and graceful degradation policies.
- [ ] **OPS-02**: System must emit structured logs and execution trace for each run.
- [ ] **OPS-03**: Errors must be centralized and recoverable without crashing the whole workflow.

### Compatibility and Delivery (COMP)
- [ ] **COMP-01**: Existing legacy linear files/entrypoints must remain functional.
- [ ] **COMP-02**: New collaborative path must be isolated and routable via explicit orchestration entrypoint/flags.
- [ ] **COMP-03**: Deliver docs, integration tests, and example execution trace for debugging and operations handoff.

## Non-Functional Targets
- [ ] **NFR-01**: End-to-end execution target under 30 seconds for standard runs (excluding severe provider outages).
- [ ] **NFR-02**: Consensus resolution target >= 80% across representative test scenarios.
- [ ] **NFR-03**: First-pass acceptance target (no major revision loop) >= 70% in integration tests.

## Out of Scope for v2.0
- Full replacement of model providers or complete backend rewrite.
- Frontend redesign unrelated to agent orchestration quality/reliability.
- Automatic learned policy tuning for weights (keep deterministic weighting for v2.0).

## Traceability
Roadmap mapping and phase coverage will be maintained in `.planning/ROADMAP.md`.
