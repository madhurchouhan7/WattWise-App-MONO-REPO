# Project: WattWise

## What This Is

WattWise is an energy intelligence platform that helps households understand electricity usage, detect inefficiency patterns, and receive actionable AI plans to reduce bills. The backend contains a LangGraph-based multi-agent planning engine that currently runs in a linear pipeline. This milestone upgrades that engine into a production-grade collaborative multi-agent workspace with persistent memory, debate, and strict quality gating.

## Core Value

Help users monitor their electricity consumption, discover insights, and generate AI-driven efficiency plans to save energy and reduce their carbon footprint.

## Current Milestone: v2.0 Production-Grade Collaborative Multi-Agent System

**Goal:** Transform the existing linear Analyst -> Strategist -> Copywriter flow into a collaborative, memory-enabled, self-validating multi-agent system that is production ready and hallucination resistant.

**Target features:**

- Shared persistent workspace memory and conversation history across all agents
- Structured debate protocol, cross-validation, and weighted consensus
- Multi-layer quality gates with minimum quality score enforcement
- Production-grade reliability controls (retry, error handling, logging, traceability)

## Requirements

### Validated

- [x] Build collaborative orchestration with persistent shared context and complete conversation memory (Phases 2-3)
- [x] Introduce agent self-reflection and self-validation before output publication (Phase 4)
- [x] Add cross-agent challenge, debate resolution, and consensus scoring (Phases 4-5)
- [x] Enforce strict anti-hallucination checks and final quality gating at >=85 score (Phases 4-5)
- [x] Deliver production-ready observability and graceful error recovery paths (Phase 6 baseline)

### Active

- [ ] Finalize production docs/runbook/performance baseline artifacts for milestone closure

### Out of Scope

- Replacing the full technology stack outside the efficiency planning subsystem - this milestone targets the agentic architecture upgrade
- Frontend redesign unrelated to AI planning collaboration - not needed for milestone success

## Context

- Existing backend implementation already uses LangGraph and three specialist nodes.
- Current flow is mostly sequential and lacks robust shared-memory collaboration guarantees.
- Milestone intent is to elevate reliability, transparency, and output quality for production use.

## Constraints

- **Compatibility**: Keep existing linear files and entrypoints functional - backward compatibility is required.
- **Reliability**: Avoid runtime crashes and provide graceful degradation paths - production readiness mandate.
- **Quality**: Prevent fabricated outputs with strict validation and quality scoring - zero hallucination objective.

## Key Decisions

| Decision                                                                   | Rationale                                                 | Outcome   |
| -------------------------------------------------------------------------- | --------------------------------------------------------- | --------- |
| Keep legacy linear pipeline files while adding enhanced collaborative path | Reduces migration risk and allows controlled rollout      | - Pending |
| Use explicit validation and debate layers before final output              | Needed for auditability, self-correction, and consistency | - Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):

1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):

1. Full review of all sections
2. Core Value check - still the right priority?
3. Audit Out of Scope - reasons still valid?
4. Update Context with current state

---

_Last updated: 2026-03-23 after milestone v2.0 start_
