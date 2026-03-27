# Domain Pitfalls

**Domain:** Milestone v2.1 functional profile utility features (calculator, CMS-like static pages, support flows, legal docs, appliance management)
**Researched:** 2026-03-23
**Confidence:** HIGH (repository-grounded)

## Critical Pitfalls

### Pitfall 1: Contract Drift Between Flutter Screens and Backend Endpoints
**What goes wrong:**
Profile utility screens are wired to endpoints that are deprecated, moved, or return different payload shapes, causing silent failures or partially updated UI state.

**Why it happens:**
The profile area is expanding quickly with mixed old/new patterns. The backend already contains deprecated routes (example: appliance updates via user routes), while Flutter screens can still assume legacy behavior.

**Consequences:**
Broken saves, stale UI, confusing success states, and regression loops after backend refactors.

**Prevention:**
- Establish one contract registry for v2.1 profile features (path, method, request, response, error payloads).
- Add integration tests for every profile utility route using real mobile payload fixtures.
- Reject legacy endpoint usage in code review and CI (lint/search gate on deprecated routes).
- Require each new screen PR to include a contract test and error-state screenshot/video.

**Detection (warning signs):**
- Mobile logs show 301/404/400 for profile flows after deployment.
- "Saved successfully" UI appears but data does not persist on reload.
- Frontend code references both old and new route families for the same domain action.

**Phase to address:**
**Phase v2.1-1: API Contract Freeze + Navigation Wiring**

---

### Pitfall 2: Destructive Appliance Bulk Updates Causing Data Loss
**What goes wrong:**
Appliance management uses full-list replacement semantics; partial edits from one screen overwrite or deactivate existing appliances unintentionally.

**Why it happens:**
Bulk endpoints are simple to integrate but dangerous when multiple app states can submit incomplete lists (stale provider state, interrupted sessions, background resume).

**Consequences:**
User appliance history disappears, downstream plan quality drops, and trust erodes because data appears to "randomly vanish."

**Prevention:**
- Introduce optimistic concurrency (revision/version token) for appliance list writes.
- Split update semantics: patch single appliance vs full-replace bulk operation.
- Add guardrails in Flutter submit flow: compare local count/hash vs latest server snapshot before overwrite.
- Add server-side audit trail for appliance mutations with request ID and diff.

**Detection (warning signs):**
- Sudden drops in appliance counts immediately after app updates.
- Frequent support complaints about missing appliances after editing one item.
- Multiple write operations in short time windows with conflicting payload sizes.

**Phase to address:**
**Phase v2.1-2: Appliance Domain Hardening (CRUD + Concurrency)**

---

### Pitfall 3: CMS-Like Static Content Without Versioning or Cache Invalidation
**What goes wrong:**
FAQ/how-to/legal/support content renders stale, mismatched, or inconsistent across app sessions and platforms.

**Why it happens:**
Teams treat "static" pages as simple hardcoded content or ad-hoc JSON without content version IDs, publish states, or cache busting policy.

**Consequences:**
Incorrect guidance, legal exposure (outdated policy text), and costly hotfix cycles just to update content.

**Prevention:**
- Define a content manifest contract: slug, version, locale, publishedAt, checksum.
- Keep legal content immutable by version; render the accepted version in user-facing audit logs.
- Use explicit cache TTL + ETag/content-hash invalidation strategy.
- Add kill-switch/fallback bundle when content service is unavailable.

**Detection (warning signs):**
- Different users see different legal text for the same app version.
- Content fixes require app release instead of backend/content update.
- High cache hit rates but persistent user reports of old content.

**Phase to address:**
**Phase v2.1-3: Content Platform (CMS-like Pages + Legal Versioning)**

---

### Pitfall 4: Support Flows Built as UI-Only Without Case Lifecycle
**What goes wrong:**
"Contact Support" launches but submissions are not durable, not trackable, or not correlated to user/account/app context.

**Why it happens:**
Support UI ships before a backend case model, triage queue, and SLA states are defined.

**Consequences:**
Lost tickets, no resolution tracking, repeated user submissions, and support team overload.

**Prevention:**
- Define support ticket schema up front (category, severity, metadata, status transitions).
- Generate stable case IDs and expose status timeline in app.
- Store device/app/build/request context automatically with each ticket.
- Add anti-spam throttling and idempotency keys for repeated submissions.

**Detection (warning signs):**
- Support cannot map user complaints to submitted tickets.
- Users resubmit identical issues multiple times.
- Ticket state transitions are manual or happen outside system logs.

**Phase to address:**
**Phase v2.1-4: Support Workflow + Operational Integration**

---

### Pitfall 5: Missing Compliance and Consent Traceability for Legal Flows
**What goes wrong:**
Users can access legal docs, but acceptance/version proof and data-export/deletion pathways are incomplete or unverifiable.

**Why it happens:**
Legal screens are treated as content-only work instead of compliance workflows with data lineage.

**Consequences:**
Compliance risk, inability to prove consent history, and incident escalation during audits.

**Prevention:**
- Record legal acceptance events with document version, timestamp, locale, and user ID.
- Implement explicit privacy actions (data export/delete) with auditable status states.
- Define retention and redaction policies for support/legal attachments.
- Add compliance-focused tests for consent replay and audit export.

**Detection (warning signs):**
- No reliable answer to "which terms version did user X accept?"
- Manual scripts needed to reconstruct consent history.
- Legal copy changes without corresponding version bump in backend records.

**Phase to address:**
**Phase v2.1-4: Support Workflow + Operational Integration**

## Moderate Pitfalls

### Pitfall 1: Auth and Environment Fragility on Utility Endpoints
**What goes wrong:**
Profile utility requests fail in non-standard environments (Firebase config missing, token refresh race, expired token retry loops).

**Prevention:**
- Add environment readiness checks before enabling profile utility navigation.
- Standardize 401/403/503 handling in one Flutter error adapter.
- Add synthetic health checks for auth + profile utility API paths.

**Phase to address:**
**Phase v2.1-1: API Contract Freeze + Navigation Wiring**

### Pitfall 2: Rate Limiting Colliding with Burst UX
**What goes wrong:**
Rapid edits (appliance updates, support retries) hit strict rate limits and present generic failures.

**Prevention:**
- Calibrate per-endpoint limits to expected mobile interaction bursts.
- Surface rate-limit retry-after hints in API and UI.
- Add client-side request coalescing/debouncing for repetitive saves.

**Phase to address:**
**Phase v2.1-5: Reliability, Telemetry, and UAT Closure**

### Pitfall 3: Inconsistent Error Envelope Handling in Flutter
**What goes wrong:**
Some screens parse success-only payloads and ignore structured backend error fields, leading to poor recovery UX.

**Prevention:**
- Enforce one typed API error model for all profile utilities.
- Add golden tests for empty, partial, timeout, unauthorized, and validation-error states.
- Ban raw exception string rendering in production UX.

**Phase to address:**
**Phase v2.1-5: Reliability, Telemetry, and UAT Closure**

## Minor Pitfalls

### Pitfall 1: Utility Screens Ship as Dead Menu Items
**What goes wrong:**
Profile menu entries exist without route wiring, permission checks, or analytics events.

**Prevention:**
- Use feature flags and route guards before exposing menu tiles.
- Add smoke tests that tap each tile and assert expected route/result.

**Phase to address:**
**Phase v2.1-1: API Contract Freeze + Navigation Wiring**

### Pitfall 2: Incomplete Localization/Currency Formatting in Calculator and Legal Copy
**What goes wrong:**
Units, symbols, and legal language appear inconsistent with user locale.

**Prevention:**
- Externalize all utility copy and numeric formatting rules.
- Add locale snapshot tests for key profile utility pages.

**Phase to address:**
**Phase v2.1-3: Content Platform (CMS-like Pages + Legal Versioning)**

## Integration Pitfalls (Milestone-Specific)

| Integration Area | Common Mistake | Prevention | Phase |
|---|---|---|---|
| Flutter profile menu -> backend routes | Wiring placeholder onTap handlers directly to unstable APIs | Introduce typed route/use-case layer between UI and API client | v2.1-1 |
| Appliance provider state -> bulk API | Sending stale/incomplete appliance list as authoritative truth | Add server revision token + client compare-before-save | v2.1-2 |
| CMS-like pages -> cache | Treating content as hardcoded constants with no manifest/version | Use manifest with checksum/version and cache invalidation strategy | v2.1-3 |
| Legal docs -> consent records | Showing legal text without storing accepted version | Persist versioned acceptance event and audit export endpoint | v2.1-4 |
| Support form -> ops tooling | Capturing message only (no metadata/case lifecycle) | Add case model, status workflow, and correlation IDs | v2.1-4 |
| Mobile retries -> strict rate limiters | Immediate blind retries after failures | Add retry budget, exponential backoff, and Retry-After UX | v2.1-5 |

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|---|---|---|
| v2.1-1 API contracts and navigation | Hidden use of deprecated user appliance endpoints | CI guard + contract tests on all profile utility paths |
| v2.1-2 Appliance management | Data loss from full-list overwrite writes | Versioned writes + patch endpoints + mutation audit logs |
| v2.1-3 Calculator/content/legal rendering | Hardcoded formulas/content with no versioning | Config-driven formulas and content manifest with publish workflow |
| v2.1-4 Support/legal operations | No durable case/compliance lifecycle | Ticket state machine + legal consent event store |
| v2.1-5 Reliability/UAT | "Happy path only" testing misses mobile edge failures | End-to-end negative-path suite + telemetry SLO checks |

## What to Verify Before Marking v2.1 Done

- [ ] Every profile utility screen has contract-tested API integration and deterministic fallback UI.
- [ ] Appliance edits are non-destructive under concurrent sessions and offline-resume scenarios.
- [ ] FAQ/how-to/legal content is versioned, cache-safe, and remotely updatable.
- [ ] Support submissions produce traceable case IDs and status transitions.
- [ ] Legal acceptance is versioned and exportable for audit requests.
- [ ] Rate-limit and auth failures are user-recoverable, not generic dead ends.

## Sources

- Repository contract and implementation evidence (HIGH):
  - wattwise_app/lib/feature/profile/screens/profile_screen.dart
  - wattwise_app/lib/feature/profile/provider/manage_appliances_provider.dart
  - wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart
  - wattwise_app/lib/core/network/api_client.dart
  - backend/src/routes/user.routes.js
  - backend/src/routes/appliance.routes.js
  - backend/src/controllers/user.controller.js
  - backend/src/controllers/appliance.controller.js
  - backend/src/middleware/authMiddleware.js
  - backend/src/middleware/rateLimit.middleware.js
  - backend/src/middleware/errorHandler.js
