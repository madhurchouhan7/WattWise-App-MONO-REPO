# Project: WattWise

## What This Is

WattWise is an energy intelligence platform that helps households understand electricity usage, reduce avoidable energy waste, and act on clear recommendations. The product includes a Flutter consumer app and a Node backend that powers profile, appliance, billing education, and intelligent energy planning features.

## Core Value

Help users monitor their electricity consumption, discover insights, and generate actionable plans to reduce energy bills and carbon footprint.

## Current Milestone: v2.1 Functional Profile and Utility Screens

**Goal:** Make currently static profile utility surfaces fully functional, backend-connected, and production-ready while preserving the existing WattWise design language and Riverpod architecture.

**Target features:**

- Fully functional Edit Profile and synchronized user settings
- Reliable Manage Appliances flows with safer mutation and refresh behavior
- Dynamic utility content: FAQs, How to Read Bill, and Legal hub
- Contact Support workflow with durable submission and user feedback states
- Solar Calculator v1 with transparent assumptions and dynamic estimates

## Requirements

### Validated

- [x] Build collaborative orchestration with persistent shared context and complete conversation memory (Phases 2-3)
- [x] Introduce agent self-reflection and self-validation before output publication (Phase 4)
- [x] Add cross-agent challenge, debate resolution, and consensus scoring (Phases 4-5)
- [x] Enforce strict anti-hallucination checks and final quality gating at >=85 score (Phases 4-5)
- [x] Deliver production-ready observability and graceful error recovery paths (Phase 6 baseline)

### Active

- [ ] Deliver profile and settings data flows backed by stable API contracts
- [ ] Ship utility content modules with versioned, refresh-safe delivery
- [ ] Implement support and legal consent workflows with auditability
- [ ] Ship Solar Calculator v1 with transparent estimate assumptions
- [ ] Close milestone with reliability hardening and UAT-ready verification

### Out of Scope

- Replacing the app architecture with a new state-management stack - Riverpod remains the standard
- Re-platforming backend frameworks (for example, GraphQL rewrite) during this milestone
- Financing-grade solar optimization and installer quotation workflows - deferred beyond v2.1

## Context

- Existing profile menu has placeholder actions for several utility entries.
- Riverpod, Dio, and current backend modules are already in place and should be extended, not replaced.
- This milestone focuses on product-surface completion and data-flow reliability, not a visual redesign.

## Constraints

- **UX Consistency**: Preserve existing WattWise UI/UX patterns and component behavior.
- **Architecture**: Keep Riverpod-centered state management and existing repository/service boundaries.
- **Compatibility**: Additive API evolution only; avoid breaking existing mobile flows.
- **Reliability**: Support loading/error/retry states and avoid destructive writes in appliance operations.

## Key Decisions

| Decision                                                                        | Rationale                                                             | Outcome   |
| ------------------------------------------------------------------------------- | --------------------------------------------------------------------- | --------- |
| Keep v2.1 implementation additive to existing Flutter and backend modules       | Minimizes migration risk and accelerates delivery                     | - Pending |
| Use versioned utility content delivery for FAQ/Bill/Legal surfaces              | Prevents stale or inconsistent guidance text in production            | - Pending |
| Keep Solar Calculator scoped to transparent estimates (not financing optimizer) | Delivers immediate value while avoiding precision and compliance risk | - Pending |

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

_Last updated: 2026-03-23 after milestone v2.1 start_
