# Project Research Summary

**Project:** WattWise
**Domain:** Consumer energy app profile utility functionalization (milestone v2.1)
**Researched:** 2026-03-23
**Confidence:** MEDIUM-HIGH

## Executive Summary

WattWise v2.1 is a product-surface milestone: convert profile utility placeholders into reliable, backend-connected features without architectural churn. The research is consistent across stack, feature, architecture, and pitfalls outputs: ship via additive changes on the existing Flutter Riverpod + Dio and Node Express + Zod foundations, using `GET/PUT /users/me` as the primary profile aggregate contract and a small support module for utility resources.

The recommended implementation is intentionally minimal-risk. On Flutter, the only required dependency addition is `url_launcher` for legal/support links; all other needs are satisfied by current app patterns. On backend, no required package additions are needed; focus is endpoint completion, validation hardening, and data-contract stability. Build order should stay dependency-aware: API contract first, then Flutter data layer, then UI wiring, then utility resources, then reliability/UAT closure.

Primary delivery risks are contract drift, destructive appliance bulk writes, stale legal/FAQ content, and support/legal flows that look complete in UI but lack lifecycle traceability. Mitigation is straightforward and should be mandatory in roadmap planning: contract freeze tests, non-destructive appliance update strategy, versioned content manifest, and auditable support-case and consent events.

## Key Findings

### Recommended Stack

v2.1 should extend the current stack, not replace it.

**Core technologies:**
- Flutter + Riverpod + Dio: Keep current state/network architecture to minimize migration risk.
- Node.js + Express + Zod: Reuse existing route/service validation pipeline for profile and support contracts.
- url_launcher `^6.3.2`: Required to open support/legal channels cross-platform from profile utilities.

**Stack additions and constraints:**
- Required: Flutter `url_launcher` only.
- Optional: `flutter_markdown` for richer remote content rendering.
- Optional backend docs tooling: `@asteasolutions/zod-to-openapi`, `swagger-ui-express`, `openapi-typescript`.

### Expected Features

Feature research separates launch-critical table stakes from differentiators.

**Must have (table stakes):**
- Edit Profile fully functional with validation, save/retry states, and backend persistence.
- Manage Appliances CRUD hardening with reliable refresh and invalid-state prevention.
- FAQs with topic/search and direct escalation path into Contact Support.
- Contact Support baseline form with category, durable submission, ticket reference, and fallback channels.
- Legal hub with Terms/Privacy/Consent links plus visible version/date metadata.
- Bill Reading Education v1 with bill anatomy walkthrough and glossary.
- Solar Calculator v1 with transparent assumption-based range output.

**Should have (differentiators):**
- Personalized/contextual bill-change explainers.
- Intent-aware FAQ ranking.
- Smart support triage with auto-attached context.
- Appliance health/efficiency nudges.

**Defer (v2.2+):**
- Solar financing optimizer and installer-grade outputs.
- Full support inbox/threading and advanced personalization layers.

### Architecture Approach

Use extension-first architecture centered on clear module ownership. Keep profile mutation in the user aggregate (`/users/me`) and isolate utility resources/contact workflows in a support module (`/support/*`). On Flutter, introduce profile-domain repositories/providers under `feature/profile` and avoid overloading auth providers. This preserves current navigation/auth behavior while enabling independent profile/settings/resource invalidation.

**Major components:**
1. Backend user aggregate contract: profile + settings read/write with deep-merge semantics.
2. Backend support module: FAQ, bill-help, legal metadata, and contact operations.
3. Flutter profile data layer: models, repository, providers for profile/settings/resources.
4. Flutter screen wiring: profile menu actions and settings/edit flows connected to real providers.
5. Reliability/test layer: contract, negative-path, and cache/rollback coverage.

### Critical Pitfalls

1. **Contract drift between UI and APIs** - freeze contracts and add per-route integration tests with mobile payload fixtures.
2. **Destructive appliance bulk writes** - add revision tokens/compare-before-save and prefer patch semantics where possible.
3. **Unversioned FAQ/legal content** - implement content manifest with version/checksum and explicit cache invalidation.
4. **UI-only support flow (no durable case lifecycle)** - define ticket schema, case IDs, status transitions, and idempotency.
5. **Missing consent/legal traceability** - persist acceptance events with version/timestamp/locale and expose audit-export paths.

## Implications for Roadmap

Based on combined research, use a 5-phase v2.1 structure.

### Phase 1: Contract Freeze and Navigation Wiring
**Rationale:** Frontend rewiring is unsafe without stable backend contracts.
**Delivers:** Profile/settings contract finalization, endpoint matrix, and route-safe menu wiring.
**Addresses:** Edit Profile baseline, utility entry-point activation.
**Avoids:** Contract drift, dead menu items, env/auth fragility.

### Phase 2: Appliance Domain Hardening
**Rationale:** Appliance integrity is dependency-critical for profile trust and future personalization.
**Delivers:** Non-destructive CRUD semantics, concurrency safeguards, validation guardrails, mutation audit logs.
**Addresses:** Manage Appliances table stakes.
**Avoids:** Data-loss regressions from bulk overwrite behavior.

### Phase 3: Utility Content Platform (FAQ, Bill Help, Legal)
**Rationale:** Content-driven screens can ship independently once contracts are stable.
**Delivers:** Support resource APIs, versioned content manifest, cache strategy, utility resource provider/screens.
**Addresses:** FAQs, Bill Reading Education v1, Legal hub.
**Avoids:** Stale/inconsistent content and legal text drift.

### Phase 4: Support Workflow and Compliance Operations
**Rationale:** Contact/legal features are incomplete without durable operational lifecycles.
**Delivers:** Structured support case flow, status lifecycle, metadata capture, consent acceptance eventing.
**Addresses:** Contact Support baseline and legal traceability requirements.
**Avoids:** Lost tickets and audit/compliance gaps.

### Phase 5: Reliability, Telemetry, and UAT Closure
**Rationale:** Final release quality depends on edge-path resilience, not only happy-path functionality.
**Delivers:** Unified error envelope handling, rate-limit/retry UX, negative-path test suite, milestone verification checklist closure.
**Addresses:** Cross-feature production readiness.
**Avoids:** brittle launches and unresolved UAT gaps.

### Phase Ordering Rationale

- API and data contracts precede UI wiring to prevent churn.
- Appliance hardening is early because it affects profile trust and downstream calculators.
- Content and support/compliance are split so static-resource delivery is not blocked by ops workflow complexity.
- Reliability closure is last so it validates integrated behavior across all utility surfaces.

### Actionable Requirement Scoping

- Lock v2.1 acceptance criteria to observable user contracts (load, save, error recovery, persistence on reopen).
- Require a source-of-truth endpoint map with request/response/error schema per utility feature.
- Scope Solar Calculator to transparent range outputs only; explicitly exclude financing-grade precision.
- Treat legal/support as workflow requirements (versioning, consent events, case lifecycle), not only UI pages.
- Add explicit non-functional requirements for cache invalidation, idempotency, and concurrency safety.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** Concurrency/versioning strategy for appliance updates under multi-session writes.
- **Phase 4:** Ticketing integration model, SLA/status design, and compliance event retention requirements.

Phases with standard patterns (can likely skip research-phase):
- **Phase 1:** Contract freeze and provider-based route wiring are established repo patterns.
- **Phase 5:** Error normalization and negative-path hardening are standard quality practices.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Strong repo alignment and minimal required new dependencies. |
| Features | MEDIUM-HIGH | Clear table stakes and defer list; some support/legal depth depends on ops decisions. |
| Architecture | HIGH | Component boundaries and build order are concrete and dependency-aware. |
| Pitfalls | HIGH | Risks are repository-grounded with direct prevention strategies. |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- Solar estimator calibration inputs (tariff/regional assumptions) need product policy before final formula lock.
- Support platform choice (in-house ticket store vs external provider) must be decided before Phase 4 execution.
- Consent retention/export policy needs legal confirmation for final compliance scope.

## Sources

### Primary (HIGH confidence)
- `.planning/research/STACK.md`
- `.planning/research/FEATURES.md`
- `.planning/research/ARCHITECTURE.md`
- `.planning/research/PITFALLS.md`
- `.planning/PROJECT.md`

### Secondary (MEDIUM confidence)
- https://www.energy.gov/energysaver/estimating-appliance-and-home-electronic-energy-use
- https://www.pge.com/en/account/billing-and-assistance/understand-your-bill.html
- https://www.octopus.energy/help-and-faqs/
- https://www.energystar.gov/about/federal_tax_credits
- Pub package index for `url_launcher` and `flutter_markdown`
- npm package index for `@asteasolutions/zod-to-openapi`, `swagger-ui-express`, `openapi-typescript`

---

_Research completed: 2026-03-23_
_Ready for roadmap: yes_
