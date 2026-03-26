# Phase 10: Support and Solar Workflows - Research

**Researched:** 2026-03-26  
**Domain:** Support ticket workflow + consent traceability + solar estimate range calculator on Express/MongoDB + Flutter Riverpod  
**Confidence:** HIGH

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SUP-01 | User can submit a support request with category, message, and contact details. | Contract-first `POST /api/v1/support/tickets` with strict Zod schema and required fields (`category`, `message`, `preferredContact`). |
| SUP-02 | User receives a durable support reference ID after successful submission. | Server-generated immutable `ticketRef` using UUID + date prefix; returned in success envelope and persisted in SupportTicket document. |
| SUP-03 | User gets clear retry guidance when support submission fails. | Error taxonomy (`VALIDATION_ERROR`, `RATE_LIMITED`, `TEMPORARY_UNAVAILABLE`) with retry hint + optional `Retry-After`; Flutter state machine preserves draft and exposes retry action. |
| SUP-04 | Support submissions and legal consent events are logged with traceable metadata. | Consent snapshot (`consentVersion`, `acceptedAt`, `policySlug`) stored in ticket + activity/audit event with `requestId`, userId, endpoint, and consent hash. |
| SOL-01 | User can input required home and consumption fields to calculate a solar estimate. | Dedicated solar input schema and DTO (`monthlyUnits`, `roofAreaSqFt`, `gridType`, `state/discom`, optional shading). |
| SOL-02 | User sees estimate output as a transparent range with stated assumptions. | Deterministic assumptions model returns low/base/high bands and explicit assumption block (CUF, system losses, tariff basis). |
| SOL-03 | User can adjust key inputs and instantly recalculate updated estimates. | Stateless calculator endpoint + Flutter `AsyncNotifier` recompute path with debounced local edits and immediate recalculation call. |
| SOL-04 | Calculator clearly communicates limits and avoids implying financing-grade precision. | Response includes `confidenceLabel`, `limitations[]`, and disclaimer text; UI always renders uncertainty banner and “informational estimate only.” |

</phase_requirements>

## Summary

Phase 10 should be implemented as two contract-driven domains under existing API and app architecture: (1) support ticket submission with durable references and compliance-grade consent traceability, and (2) a transparent solar estimate calculator that explicitly models uncertainty. The repository already has mature patterns needed for this phase: request IDs (`X-Request-ID`), normalized envelopes, Zod validation, and Riverpod retry/failure state handling from appliance and content flows.

For support, the critical design decision is to treat ticket creation as a durable write operation, not a fire-and-forget message. The API must return a stable `ticketRef` immediately on success and include metadata that enables support and compliance teams to reconstruct what consent/legal context existed at submission time. Existing middleware (`validation.middleware.js`, `errorHandler.js`, `logging.middleware.js`) already provides most infrastructure; Phase 10 primarily needs new route/controller/model contracts and deterministic error semantics.

For solar, the main risk is false precision. The phase should avoid “single-number certainty” and instead return range outputs with visible assumptions and limits. The app already communicates “up-to-date” and retry guidance in content/appliance flows; use the same UX language model for “estimate updated,” “cannot compute,” and “retry later” scenarios.

**Primary recommendation:** Implement `support` and `solar` as new API modules with strict schemas, immutable trace metadata, and a shared Flutter mutation-state pattern that preserves draft input and exposes explicit retry guidance.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| express | 5.2.1 | Support/solar route orchestration | Existing backend routing foundation in this repo. |
| mongoose | 9.3.3 (repo currently 9.2.3) | Ticket persistence + optional solar assumptions snapshot model | Existing datastore and schema/index strategy. |
| zod | 4.3.6 | Input validation for support and solar contracts | Existing deterministic validation envelope pattern. |
| uuid | 13.0.0 (repo currently 9.0.1) | Durable support reference ID generation | Already used for request IDs; avoids hand-rolled ID generation. |
| flutter_riverpod | workspace dependency | Support/solar async state and retry orchestration | Existing app state pattern in profile/content flows. |
| dio | 5.9.1 | Network client and status/error mapping | Existing centralized API client in app. |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| jest | 30.3.0 (repo currently 30.2.0) | Backend contract tests for support/solar | Endpoint envelope, validation, and retry semantics. |
| supertest | 7.2.2 | HTTP route behavior tests | Status code/header/error envelope assertions. |
| flutter_test | SDK | Widget/provider tests for retry + assumptions rendering | Support form and solar result states. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Synchronous `201 Created` for support submit | `202 Accepted` async queue model | `202` is better for deferred pipelines, but Phase 10 requires immediate durable reference and simple UX. |
| Persisting consent snapshot in ticket | Logging-only consent event | Logging-only is insufficient for long-term audit reconstruction if logs rotate or are sampled. |
| Range-based solar output | Single-point estimate | Single value appears precise and increases user trust risk (violates SOL-04 intent). |

**Installation:**

```bash
# No mandatory new packages for Phase 10.
# Existing dependencies already support implementation.
```

**Version verification (executed 2026-03-26):**

```bash
npm view express version time.modified
npm view mongoose version time.modified
npm view zod version time.modified
npm view uuid version time.modified
npm view ioredis version time.modified
npm view jest version time.modified
npm view supertest version time.modified
```

- express: 5.2.1 (2026-03-08)
- mongoose: 9.3.3 (2026-03-25)
- zod: 4.3.6 (2026-01-25)
- uuid: 13.0.0 (2025-09-08)
- ioredis: 5.10.1 (2026-03-19)
- jest: 30.3.0 (2026-03-10)
- supertest: 7.2.2 (2026-01-06)

## Architecture Patterns

### Recommended Project Structure

```text
backend/src/
├── models/SupportTicket.model.js         # durable ticket + consent snapshot
├── controllers/support.controller.js      # submit ticket handler
├── routes/support.routes.js               # /support endpoints
├── controllers/solar.controller.js        # estimate calculator
├── routes/solar.routes.js                 # /solar/estimate endpoint
└── middleware/validation.middleware.js    # add support + solar schemas

wattwise_app/lib/feature/profile/
├── screens/contact_support_screen.dart
├── provider/contact_support_provider.dart
└── repository/support_repository.dart

wattwise_app/lib/feature/solar/
├── screens/solar_calculator_screen.dart
├── provider/solar_provider.dart
├── repository/solar_repository.dart
└── models/solar_models.dart
```

### Pattern 1: Support Ticket Contract Design

**What:** Persist support submissions as first-class domain records with immutable ticket reference and consent snapshot.

**When to use:** `POST /api/v1/support/tickets` for SUP-01..SUP-04.

**Recommended request shape:**

```json
{
  "category": "billing_dispute",
  "message": "My latest bill looks 2x higher than usual.",
  "preferredContact": {
    "channel": "phone",
    "value": "+91XXXXXXXXXX"
  },
  "attachments": [],
  "consent": {
    "policySlug": "privacy",
    "consentVersion": "2026.03.1",
    "acceptedAt": "2026-03-26T12:40:11.000Z"
  }
}
```

**Recommended success envelope:**

```json
{
  "success": true,
  "message": "Support request submitted successfully.",
  "data": {
    "ticketRef": "SUP-20260326-4F19E4A1",
    "status": "OPEN",
    "submittedAt": "2026-03-26T12:40:11.000Z",
    "requestId": "ff4f3d07-..."
  }
}
```

### Pattern 2: Consent Traceability Model

**What:** Dual-write traceability for legal consent at submission time.

**When to use:** Every support ticket submission that depends on policy acceptance context.

**Persist in SupportTicket document:**
- `consent.policySlug`
- `consent.consentVersion`
- `consent.acceptedAt`
- `consent.snapshotHash` (optional deterministic hash of consent block)

**Emit structured activity/audit event:**
- `eventType: support_ticket_submitted`
- `ticketRef`
- `requestId`
- `userId`
- `consentVersion`
- `acceptedAt`
- `timestamp`

This combines durable domain data with operational observability and aligns with existing request-id logging middleware.

### Pattern 3: Solar Estimate Assumptions Model

**What:** Deterministic estimate-range calculation with explicit assumption payload.

**When to use:** `POST /api/v1/solar/estimate` for SOL-01..SOL-04.

**Input model (minimum):**
- `monthlyUnits` (number > 0)
- `roofAreaSqFt` (number > 0)
- `state` and `discom` (for tariff baseline selection)
- `sanctionedLoadKw` (optional)
- `shadingLevel` (`low|medium|high`, default `medium`)

**Output model (transparent range):**
- `recommendedSystemSizeKw`
- `estimatedMonthlyGenerationKwh: { low, base, high }`
- `estimatedMonthlySavingsInr: { low, base, high }`
- `assumptions`: tariff baseline, CUF band, losses, derivation date
- `limitations[]`: no financing, no installer quote, roof survey not included
- `confidenceLabel`: `LOW|MEDIUM`

### Pattern 4: Failure/Retry UX Pattern (Support + Solar)

**What:** Shared mutation-state machine that preserves user draft and categorizes recovery action.

**When to use:** Failed support submit or solar compute request in Flutter.

**State categories:**
- `validationError`: inline field fixes, no retry CTA
- `conflict` (if versioned resources introduced later): reload latest
- `retryableError` (408/429/5xx): retry CTA + optional wait seconds
- `unknownError`: generic retry + preserve draft

**UX contract:**
- Always preserve form/input draft on non-success
- Show `requestId` in expandable details for support scenarios
- If `Retry-After` present, show countdown hint: “Try again in N seconds”
- Use deterministic action label (`Retry`, `Reload latest`, `Fix and retry`)

### Anti-Patterns to Avoid

- **Generating ticket refs on client:** breaks durability guarantees and server-side uniqueness enforcement.
- **Logging consent without persisting in ticket record:** weak auditability when logs are pruned.
- **Returning one exact solar value without assumptions:** implies precision and violates SOL-04 intent.
- **Dropping draft on failure:** causes user frustration and data loss in support forms.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Durable unique ticket references | Timestamp+random string utility | `uuid` package + stable server format wrapper | Avoid collisions and custom entropy bugs. |
| Validation and error shape normalization | Ad-hoc field checks per controller | Existing `validate()` + Zod schemas | Reuses deterministic `VALIDATION_ERROR` envelope conventions. |
| Retry/error UX branching in each widget | Widget-local boolean flags | Riverpod mutation state machine (existing appliance pattern) | Keeps recovery actions explicit and testable. |
| Solar precision math “by instinct” | Opaque magic constants | Explicit assumptions model with low/base/high bands | Prevents misleading precision claims. |

**Key insight:** Support and solar both depend more on transparent contracts and recovery semantics than on complex new infrastructure.

## Common Pitfalls

### Pitfall 1: Ticket created but no durable operator reference

**What goes wrong:** User sees success toast but no stable reference for follow-up.  
**Why it happens:** Endpoint only returns generic message.  
**How to avoid:** Require immutable `ticketRef` in success payload and persisted document.  
**Warning signs:** Support team cannot locate request with user-provided screenshot.

### Pitfall 2: Consent captured in UI copy only

**What goes wrong:** Cannot prove which policy version user accepted at submission time.  
**Why it happens:** Consent not persisted as structured data.  
**How to avoid:** Store consent snapshot fields in ticket and audit event.  
**Warning signs:** Compliance asks for evidence and only free-text logs exist.

### Pitfall 3: Solar output appears financing-grade

**What goes wrong:** Users interpret estimate as guaranteed quote.  
**Why it happens:** Single value without assumptions/limits.  
**How to avoid:** Always return ranges plus explicit limitations and confidence label.  
**Warning signs:** Users compare to installer quote and report “wrong calculator.”

### Pitfall 4: Retry guidance not actionable

**What goes wrong:** Errors shown, but user does not know whether to fix input or retry later.  
**Why it happens:** Status codes/errors not mapped to deterministic CTA text.  
**How to avoid:** Map 400 -> fix form, 429/503 -> wait+retry, 5xx -> retry now/later.  
**Warning signs:** Repeat submissions with identical invalid payload.

## Code Examples

Verified patterns from official sources and existing repository conventions:

### Support Submit Controller Skeleton

```javascript
// Source: repo patterns in appliance/content controllers + ApiResponse helpers
exports.submitSupportTicket = asyncHandler(async (req, res) => {
  const ticketRef = `SUP-${new Date().toISOString().slice(0, 10).replaceAll("-", "")}-${uuidv4().slice(0, 8).toUpperCase()}`;

  const ticket = await SupportTicket.create({
    userId: req.user._id,
    ticketRef,
    category: req.body.category,
    message: req.body.message,
    preferredContact: req.body.preferredContact,
    consent: req.body.consent,
    status: "OPEN",
    submittedAt: new Date(),
  });

  sendSuccess(res, 201, "Support request submitted successfully.", {
    ticketRef: ticket.ticketRef,
    status: ticket.status,
    submittedAt: ticket.submittedAt.toISOString(),
    requestId: req.id,
  });
});
```

### Retry-After Aware Temporary Failure Envelope

```javascript
// Source: MDN 503 + Retry-After semantics
res.set("Retry-After", "120");
return res.status(503).json({
  success: false,
  message: "Support service is temporarily unavailable. Please retry shortly.",
  errorCode: "TEMPORARY_UNAVAILABLE",
  requestId: req.id,
  timestamp: new Date().toISOString(),
});
```

### Flutter Retry State Mapping Pattern

```dart
// Source: existing manage_appliances_provider.dart mutation pattern
if (statusCode == 400) {
  state = state.copyWith(status: MutationStatus.validationError, actionLabel: 'Fix and retry');
} else if (statusCode == 429 || statusCode == 503 || statusCode >= 500) {
  state = state.copyWith(status: MutationStatus.retryableError, actionLabel: 'Retry');
} else {
  state = state.copyWith(status: MutationStatus.unknownError, actionLabel: 'Retry');
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| UUID guidance from RFC 4122 only | RFC 4122 lineage plus modern UUID implementations (`uuid` npm package) | RFC 4122 marked obsoleted by RFC 9562 | Keep using maintained library instead of custom ID logic. |
| Single-point calculators | Range + assumptions + confidence outputs | Widely adopted in consumer estimate tools | Better trust and lower legal/compliance risk. |
| Generic “something went wrong” UX | Actionable retry taxonomy with backoff hints | Modern API/client UX baseline | Higher completion and lower support friction. |

**Deprecated/outdated:**
- Hand-rolled unique ID generators for support references.
- Silent fallback from compute failure to stale solar results without explicit user message.

## Open Questions

1. **Support storage scope in v2.1**
   - What we know: Phase requires durable references and traceability.
   - What's unclear: Whether ticket assignment/workflow states beyond `OPEN` are needed now.
   - Recommendation: Keep v2.1 to `OPEN` creation contract + future-ready status enum.

2. **Tariff source for solar estimate savings conversion**
   - What we know: User `discom` exists; bill `units/amount` exist.
   - What's unclear: Canonical tariff source table for each discom/state in this phase.
   - Recommendation: Start with explicit fallback assumptions and surface tariff basis in output metadata.

3. **Attachment handling in support v1**
   - What we know: Requirement does not mandate file upload.
   - What's unclear: Whether image/doc attachments must be accepted in Phase 10.
   - Recommendation: Keep attachment field optional metadata-only in v1 unless UAT requires upload.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Jest 30.x (`backend`), Flutter `flutter_test` (`wattwise_app`) |
| Config file | `backend/package.json` scripts, Flutter default test runner |
| Quick run command | `npm --prefix backend test -- --runInBand --testPathPatterns "(support|solar)" && cd wattwise_app && flutter test test/feature/profile/contact_support_test.dart test/feature/solar/solar_calculator_test.dart` |
| Full suite command | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SUP-01 | support request validates required fields and submits | backend contract + flutter widget | `npm --prefix backend test -- --runInBand --runTestsByPath tests/support.contract.test.js && cd wattwise_app && flutter test test/feature/profile/contact_support_test.dart` | ❌ Wave 0 |
| SUP-02 | successful submit returns durable reference ID | backend contract + flutter provider | `npm --prefix backend test -- --runInBand --runTestsByPath tests/support.reference.contract.test.js && cd wattwise_app && flutter test test/feature/profile/contact_support_provider_test.dart` | ❌ Wave 0 |
| SUP-03 | failure states provide retry guidance | backend error contract + flutter state test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/support.retry.contract.test.js && cd wattwise_app && flutter test test/feature/profile/contact_support_retry_states_test.dart` | ❌ Wave 0 |
| SUP-04 | consent and support events are traceable | backend contract/integration | `npm --prefix backend test -- --runInBand --runTestsByPath tests/support.consent.audit.test.js` | ❌ Wave 0 |
| SOL-01 | required fields accepted/rejected correctly | backend validation + flutter form test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/solar.validation.contract.test.js && cd wattwise_app && flutter test test/feature/solar/solar_input_validation_test.dart` | ❌ Wave 0 |
| SOL-02 | output returns estimate range + assumptions | backend contract + flutter render test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/solar.range.contract.test.js && cd wattwise_app && flutter test test/feature/solar/solar_output_range_test.dart` | ❌ Wave 0 |
| SOL-03 | adjusting inputs recalculates deterministically | backend contract + provider state test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/solar.recalculate.contract.test.js && cd wattwise_app && flutter test test/feature/solar/solar_recalculate_provider_test.dart` | ❌ Wave 0 |
| SOL-04 | limitations/disclaimers always visible | backend contract + widget assertion | `npm --prefix backend test -- --runInBand --runTestsByPath tests/solar.limitations.contract.test.js && cd wattwise_app && flutter test test/feature/solar/solar_disclaimer_test.dart` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** one focused backend support/solar test + one focused Flutter support/solar test.
- **Per wave merge:** all support/solar backend tests and all support/solar Flutter tests.
- **Phase gate:** full backend + full Flutter test suites green before `/gsd-verify-work`.

### Wave 0 Gaps

- [ ] `backend/tests/support.contract.test.js` — support submit endpoint shape and required fields (SUP-01).
- [ ] `backend/tests/support.reference.contract.test.js` — durable `ticketRef` format and uniqueness contract (SUP-02).
- [ ] `backend/tests/support.retry.contract.test.js` — retryable error codes and `Retry-After` behavior (SUP-03).
- [ ] `backend/tests/support.consent.audit.test.js` — consent snapshot persistence and trace metadata (SUP-04).
- [ ] `backend/tests/solar.validation.contract.test.js` — input schema validation (SOL-01).
- [ ] `backend/tests/solar.range.contract.test.js` — output range + assumptions envelope (SOL-02).
- [ ] `backend/tests/solar.recalculate.contract.test.js` — deterministic recompute behavior (SOL-03).
- [ ] `backend/tests/solar.limitations.contract.test.js` — disclaimers and limitations contract (SOL-04).
- [ ] `wattwise_app/test/feature/profile/contact_support_test.dart` — support form loading/error/retry/success rendering.
- [ ] `wattwise_app/test/feature/profile/contact_support_provider_test.dart` — submit success + durable reference state.
- [ ] `wattwise_app/test/feature/profile/contact_support_retry_states_test.dart` — retry guidance mapping.
- [ ] `wattwise_app/test/feature/solar/solar_calculator_test.dart` — calculator screen state coverage.
- [ ] `wattwise_app/test/feature/solar/solar_input_validation_test.dart` — required field validation.
- [ ] `wattwise_app/test/feature/solar/solar_output_range_test.dart` — range and assumptions rendering.
- [ ] `wattwise_app/test/feature/solar/solar_recalculate_provider_test.dart` — instant recalculation behavior.
- [ ] `wattwise_app/test/feature/solar/solar_disclaimer_test.dart` — limitations/disclaimer visibility.

## Sources

### Primary (HIGH confidence)

- Repository implementation and conventions:
  - `backend/src/app.js`
  - `backend/src/routes/index.js`
  - `backend/src/utils/ApiResponse.js`
  - `backend/src/middleware/validation.middleware.js`
  - `backend/src/middleware/errorHandler.js`
  - `backend/src/middleware/logging.middleware.js`
  - `backend/src/controllers/appliance.controller.js`
  - `backend/src/controllers/content.controller.js`
  - `backend/src/models/User.model.js`
  - `backend/src/models/Bill.model.js`
  - `backend/src/models/Appliance.model.js`
  - `backend/tests/content.contract.test.js`
  - `backend/tests/content.cache.test.js`
  - `backend/tests/appliance.contract.test.js`
  - `wattwise_app/lib/core/network/api_client.dart`
  - `wattwise_app/lib/feature/profile/provider/manage_appliances_provider.dart`
  - `wattwise_app/lib/feature/content/provider/content_provider.dart`
  - `wattwise_app/lib/feature/content/repository/content_repository.dart`
  - `wattwise_app/lib/feature/profile/screens/profile_screen.dart`

- Official references:
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/202
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/503
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After
  - https://datatracker.ietf.org/doc/html/rfc4122

- Registry verification:
  - npm registry (`npm view ...`) outputs captured during research for package versions/date currency.

### Secondary (MEDIUM confidence)

- RFC4122 datatracker metadata noting obsoletion by RFC9562 (not deeply analyzed in this phase).

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - directly verified from repository + npm registry.
- Architecture: HIGH - grounded in existing content/appliance/profile production patterns.
- Pitfalls: MEDIUM - derived from repo behavior plus general HTTP semantics; real-world support ops still need UAT confirmation.

**Research date:** 2026-03-26  
**Valid until:** 2026-04-25
