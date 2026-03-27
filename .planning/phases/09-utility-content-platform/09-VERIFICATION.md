---
phase: 09-utility-content-platform
verified: 2026-03-26T14:37:16Z
status: human_needed
score: 5/5 must-haves verified
human_verification:
  - test: "Profile navigation to utility content surfaces"
    expected: "From Profile, How to read bill, FAQs, and Legal open functional screens with load/error/retry handling."
    why_human: "Requires runtime navigation and UX confirmation across multiple screens."
  - test: "Legal refresh user feedback semantics"
    expected: "Refresh shows unchanged feedback for 304 and updated feedback when backend content version changes."
    why_human: "Needs interactive refresh with live version change scenario to validate user-facing messaging."
  - test: "Visual readability and metadata clarity"
    expected: "Legal and bill guide metadata are visible and understandable on common mobile form factors."
    why_human: "Visual quality and readability cannot be fully validated by static source inspection."
---

# Phase 9: Utility Content Platform Verification Report

**Phase Goal:** Power FAQ, bill-reading education, and legal surfaces from backend-delivered content.
**Verified:** 2026-03-26T14:37:16Z
**Status:** human_needed
**Re-verification:** No - initial verification

## Goal Achievement

### Observable Truths

| #   | Truth                                                                      | Status     | Evidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| --- | -------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | FAQ list/topics load from backend and render in app.                       | ✓ VERIFIED | Backend routes and controller are mounted and implemented (`backend/src/routes/index.js`, `backend/src/routes/content.routes.js`, `backend/src/controllers/content.controller.js`). Flutter repository/provider/screen wiring exists and targeted tests pass (`wattwise_app/lib/feature/content/repository/content_repository.dart`, `wattwise_app/lib/feature/content/provider/content_provider.dart`, `wattwise_app/lib/feature/content/screens/faq_screen.dart`; `flutter test ...content_search_test.dart` passed). |
| 2   | FAQ search or filter returns relevant content reliably.                    | ✓ VERIFIED | Deterministic filter logic exists in backend (`filterFaqItems` in `backend/src/controllers/content.controller.js`) and client provider filtering path (`FaqContentNotifier._load` in `wattwise_app/lib/feature/content/provider/content_provider.dart`), with query/topic controls in `wattwise_app/lib/feature/content/screens/faq_screen.dart`. Backend and Flutter content tests passed.                                                                                                                             |
| 3   | Bill-reading guide displays structured educational sections and glossary.  | ✓ VERIFIED | Backend bill-guide route and payload mapping implemented (`backend/src/routes/content.routes.js`, `backend/src/controllers/content.controller.js`). Flutter bill guide screen renders `sections` and `glossary` from provider state (`wattwise_app/lib/feature/content/screens/bill_guide_screen.dart`). `flutter test ...bill_guide_test.dart` passed.                                                                                                                                                                 |
| 4   | Legal docs show version/date metadata and open correctly.                  | ✓ VERIFIED | Legal endpoint route and metadata fields are produced in backend (`backend/src/routes/content.routes.js`, `backend/src/controllers/content.controller.js`). Profile navigation opens legal screen (`wattwise_app/lib/feature/profile/screens/profile_screen.dart`), and legal screen renders version/effective/updated fields (`wattwise_app/lib/feature/content/screens/legal_content_screen.dart`). `flutter test ...legal_content_test.dart` passed.                                                                 |
| 5   | Content refresh path prevents stale-cache confusion after backend updates. | ✓ VERIFIED | Conditional GET semantics implemented with `ETag`, `If-None-Match`, and `304` handling in backend (`backend/src/controllers/content.controller.js`) and repository/provider refresh feedback logic in Flutter (`wattwise_app/lib/feature/content/repository/content_repository.dart`, `wattwise_app/lib/feature/content/provider/content_provider.dart`). `npm test -- --runInBand tests/content.contract.test.js tests/content.cache.test.js` passed.                                                                  |

**Score:** 5/5 truths verified

### Required Artifacts

| Artifact                                                              | Expected                                          | Status     | Details                                                                       |
| --------------------------------------------------------------------- | ------------------------------------------------- | ---------- | ----------------------------------------------------------------------------- |
| `.planning/phases/09-utility-content-platform/09-CONTRACT-MATRIX.md`  | Frozen CNT-01..CNT-05 contract map                | ✓ VERIFIED | Includes route, payload, metadata, and refresh contract traceability.         |
| `backend/src/models/UtilityContent.model.js`                          | Versioned content schema for faq/bill_guide/legal | ✓ VERIFIED | Exists with indexed kind/slug/locale/status and metadata fields.              |
| `backend/src/controllers/content.controller.js`                       | Deterministic filters + conditional refresh       | ✓ VERIFIED | Implements filtering, content metadata envelope, and validator headers.       |
| `backend/src/routes/content.routes.js`                                | Content endpoint routing + validation             | ✓ VERIFIED | Defines `/faqs`, `/bill-guide`, `/legal/:slug` with schema validation.        |
| `backend/src/middleware/validation.middleware.js`                     | Validation schemas for content queries/params     | ✓ VERIFIED | Includes `getFaqContent`, `getBillGuideContent`, `getLegalContent`.           |
| `backend/src/services/CacheService.js`                                | Content cache key strategy                        | ✓ VERIFIED | Provides `generateContentKey(kind, slug, locale)`.                            |
| `wattwise_app/lib/feature/content/repository/content_repository.dart` | Typed API integration + conditional headers       | ✓ VERIFIED | Calls `/content/*` endpoints, sends `If-None-Match`, handles 304 cache reuse. |
| `wattwise_app/lib/feature/content/provider/content_provider.dart`     | Async state orchestration for FAQ/bill/legal      | ✓ VERIFIED | AsyncNotifier loading/error/retry/refresh with explicit unchanged feedback.   |
| `wattwise_app/lib/feature/content/screens/faq_screen.dart`            | FAQ UI with query/topic/filter states             | ✓ VERIFIED | Renders list, search, topic filter, retry, refresh, empty guidance.           |
| `wattwise_app/lib/feature/content/screens/bill_guide_screen.dart`     | Bill guide sections + glossary + metadata         | ✓ VERIFIED | Renders sections, glossary, retry, and metadata tile.                         |
| `wattwise_app/lib/feature/content/screens/legal_content_screen.dart`  | Legal content metadata + refresh feedback         | ✓ VERIFIED | Renders legal document selector, metadata, refresh feedback, retry.           |
| `wattwise_app/lib/feature/profile/screens/profile_screen.dart`        | Navigation wiring from Profile to content screens | ✓ VERIFIED | Push routes wired for How to read bill, FAQs, and Legal screens.              |

### Key Link Verification

| From                                                                  | To                                                | Via                           | Status | Details                                                                                                                    |
| --------------------------------------------------------------------- | ------------------------------------------------- | ----------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------- |
| `backend/src/routes/index.js`                                         | `backend/src/routes/content.routes.js`            | Route mount under `/content`  | WIRED  | `router.use("/content", contentRoutes)` present.                                                                           |
| `backend/src/routes/content.routes.js`                                | `backend/src/controllers/content.controller.js`   | GET handler wiring            | WIRED  | `getFaqs`, `getBillGuide`, `getLegalContent` wired to route paths.                                                         |
| `backend/src/middleware/validation.middleware.js`                     | `backend/src/routes/content.routes.js`            | Query/param validation        | WIRED  | `validate("getFaqContent", "query")`, `validate("getBillGuideContent", "query")`, `validate("getLegalContent", "params")`. |
| `backend/src/controllers/content.controller.js`                       | HTTP refresh contract                             | ETag / If-None-Match / 304    | WIRED  | `setConditionalHeaders`, `maybeNotModified`, and validator comparisons implemented.                                        |
| `wattwise_app/lib/feature/content/repository/content_repository.dart` | Backend `/api/v1/content`                         | Dio GET + conditional headers | WIRED  | Uses `/content/faqs`, `/content/bill-guide`, `/content/legal/:slug` and sends `If-None-Match`.                             |
| `wattwise_app/lib/feature/content/provider/content_provider.dart`     | `wattwise_app/lib/feature/content/screens/*.dart` | AsyncNotifier -> UI state     | WIRED  | Screens watch providers and trigger `retry`/`refreshContent`; feedback is rendered.                                        |
| `wattwise_app/lib/feature/profile/screens/profile_screen.dart`        | Content screens                                   | Menu action navigation        | WIRED  | Navigator push to `BillGuideScreen`, `FaqScreen`, `LegalContentScreen`.                                                    |

### Requirements Coverage

| Requirement | Source Plan         | Description                                                                            | Status      | Evidence                                                                                                        |
| ----------- | ------------------- | -------------------------------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------- |
| CNT-01      | 09-01, 09-02, 09-03 | User can open FAQs and browse topics from backend-delivered content.                   | ✓ SATISFIED | Route/controller delivery + profile navigation + FAQ provider/screen + passing backend/Flutter tests.           |
| CNT-02      | 09-01, 09-02, 09-03 | User can search or filter FAQ content and see relevant results.                        | ✓ SATISFIED | Backend `filterFaqItems` query/topic logic and provider/screen query+topic filtering with tests.                |
| CNT-03      | 09-01, 09-02, 09-03 | User can open How to Read Bill guidance with structured sections and glossary support. | ✓ SATISFIED | Bill-guide route payload plus Flutter bill guide sections/glossary rendering with passing test.                 |
| CNT-04      | 09-01, 09-02, 09-03 | User can access Legal documents with visible version metadata.                         | ✓ SATISFIED | Legal route + metadata fields + legal screen metadata rendering + passing test.                                 |
| CNT-05      | 09-01, 09-02, 09-03 | Content views refresh to newer versions without stale-cache confusion.                 | ✓ SATISFIED | Backend ETag/304 behavior and Flutter conditional refresh feedback with passing contract/cache and legal tests. |

Orphaned requirements for Phase 9: None found.

### Anti-Patterns Found

| File                                                                  | Line     | Pattern                                              | Severity | Impact                                                          |
| --------------------------------------------------------------------- | -------- | ---------------------------------------------------- | -------- | --------------------------------------------------------------- |
| `backend/src/controllers/content.controller.js`                       | 282      | `return null` from `maybeNotModified` fallback       | ℹ️ Info  | Non-stub defensive control-flow; no blocker.                    |
| `wattwise_app/lib/feature/content/repository/content_repository.dart` | 240      | `return null` when header absent                     | ℹ️ Info  | Expected optional-header handling; no blocker.                  |
| `backend/src/services/CacheService.js`                                | multiple | `return null` / empty values when Redis disconnected | ℹ️ Info  | Expected graceful degradation path; no blocker to Phase 9 goal. |

No blocker or warning-level stubs detected in Phase 9 key files.

### Human Verification Required

### 1. Profile Navigation to Utility Content Surfaces

**Test:** Open Profile and tap How to read bill, FAQs, and Legal.
**Expected:** Each opens its functional screen with loading, error, retry, and refresh affordances.
**Why human:** End-to-end navigation feel and interaction quality need runtime validation.

### 2. Legal Refresh Feedback Semantics

**Test:** Open Legal screen, refresh once with unchanged backend data, then refresh after backend content version change.
**Expected:** Unchanged state shows "Already up to date." and changed state shows updated version feedback.
**Why human:** Requires live state transition across actual backend content revisions.

### 3. Metadata Readability Across Devices

**Test:** Verify bill-guide and legal metadata visibility on common phone sizes.
**Expected:** Version/effective/updated fields remain legible and non-truncated in typical layouts.
**Why human:** Visual accessibility and readability are not deterministically testable via static analysis.

---

_Verified: 2026-03-26T14:37:16Z_
_Verifier: the agent (gsd-verifier)_
