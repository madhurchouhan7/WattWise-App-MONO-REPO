# Phase 9: Utility Content Platform - Research

**Researched:** 2026-03-26
**Domain:** Backend-delivered utility content (FAQ, bill guide, legal) with version-safe refresh across Express + MongoDB + Flutter Riverpod
**Confidence:** HIGH

<phase_requirements>

## Phase Requirements

| ID     | Description                                                                                   | Research Support                                                                                                                                     |
| ------ | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| CNT-01 | User can open FAQs and browse topics from backend-delivered content.                          | Versioned content collection + `/content/faqs` API + Flutter FAQ provider/screen contract with loading/empty/error states.                           |
| CNT-02 | User can search or filter FAQ content and see relevant results.                               | Backend query contract (`q`, `topic`) + indexed fields + deterministic filter/search response model and client debounce pattern.                     |
| CNT-03 | User can open How to Read Bill guidance with structured sections and glossary support.        | Structured schema for bill-guide sections/glossary + typed endpoint + renderer model in Flutter.                                                     |
| CNT-04 | User can access Legal documents (terms/privacy or equivalents) with visible version metadata. | Legal document schema with `version`, `effectiveFrom`, `lastUpdatedAt` + UI metadata rendering requirements.                                         |
| CNT-05 | Content views can refresh to newer content versions without stale-cache confusion.            | ETag + `If-None-Match` conditional GET + Redis/user cache key invalidation + local provider refresh semantics and explicit "updated" metadata in UI. |

</phase_requirements>

## Summary

Phase 9 should be implemented as a contract-first content platform, not a UI-only patch. The current app has placeholder entries for FAQs, How to Read Bill, and Legal in the profile menu, and the backend has no content routes/models yet. Existing architecture already provides the patterns needed to deliver this phase correctly: Express route modules, Zod request validation, deterministic success/error envelopes, Redis-backed cache utility, and Riverpod `AsyncNotifier` patterns for loading/retry behavior.

For CNT-05 specifically, stale-cache confusion is the largest risk. The stack should use two coordinated layers: API-level conditional caching (`ETag` + `If-None-Match` + `304`) and app-level provider refresh semantics (store payload + etag + fetchedAt, display visible version metadata). This preserves network efficiency while making freshness understandable to users.

**Primary recommendation:** Build a versioned `utility_content` backend domain with conditional GET support, then wire dedicated Flutter content providers/screens that expose explicit `refresh` behavior and visible version metadata on every content view.

## Architecture Map

### Current Flow (Observed)

```text
Flutter Profile Screen
  - "How to read bill" -> coming soon snackbar
  - "FAQs"             -> coming soon snackbar
  - "Legal"            -> coming soon snackbar

Backend
  - No content routes mounted under /api/v1
  - Existing reusable patterns: ApiResponse envelope, validation middleware, CacheService
```

### Target Flow

```text
Flutter
  profile_screen.dart -> navigate to content screens
    -> ContentRepository (Dio)
      -> sends If-None-Match when cached etag exists
      -> maps envelope + metadata + 304 behavior
    -> Riverpod AsyncNotifier per content surface
      -> loading / error / empty / retry / refresh

Backend
  /api/v1/content
    - GET /faqs?q=&topic=
    - GET /bill-guide
    - GET /legal/:slug
  -> content.controller.js
    -> query Mongo content docs
    -> emit ETag + Cache-Control headers
    -> return 304 on If-None-Match match
    -> sendSuccess envelope with data + version metadata
```

### Key Gaps Found

- Content menu items are placeholders in `wattwise_app/lib/feature/profile/screens/profile_screen.dart`.
- No content route/model exists in backend route tree (`backend/src/routes/index.js`).
- Existing cache utility is available and proven (`backend/src/services/CacheService.js`) but not applied to content yet.
- Existing Flutter API layer (`wattwise_app/lib/core/network/api_client.dart`) does not yet include conditional GET helper behavior for content.

## Standard Stack

### Core

| Library          | Version                                | Purpose                                                   | Why Standard                                                                |
| ---------------- | -------------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------------------- |
| express          | 5.2.1                                  | Route/controller pipeline for content endpoints           | Already the backend routing foundation in this repository.                  |
| mongoose         | 9.3.3 (latest), repo currently 9.2.3   | Content document schema/indexes/version metadata          | Existing persistence layer and best fit for versioned content docs.         |
| zod              | 4.3.6                                  | Query/param validation for content filters and legal slug | Existing deterministic validation envelope pattern.                         |
| ioredis          | 5.10.1 (latest), repo currently 5.10.0 | Optional content response cache/invalidation              | Already integrated through `CacheService`; no new caching subsystem needed. |
| flutter_riverpod | workspace dependency (floating)        | Async content state + retry/refresh orchestration         | Matches current profile/appliance state-management architecture.            |
| dio              | 5.9.1 (workspace)                      | HTTP client + error mapping + conditional headers         | Already centralized in app network layer.                                   |

### Supporting

| Library            | Version                                | Purpose                                                    | When to Use                                                               |
| ------------------ | -------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------- |
| jest               | 30.3.0 (latest), repo currently 30.2.0 | Backend contract tests for content endpoints               | Validate envelope, filter behavior, and 304 semantics.                    |
| supertest          | 7.2.2                                  | Route-level HTTP behavior tests                            | Use for endpoint-level status/header assertions including ETag/304.       |
| flutter_test       | SDK                                    | Widget/provider tests for content loading/search/refresh   | Validate NFR-style loading/empty/error/retry behavior in content screens. |
| shared_preferences | 2.5.4 (workspace)                      | Persist minimal cached content metadata for restart safety | Use for storing etag/contentVersion/fetchedAt per content surface.        |

### Alternatives Considered

| Instead of                        | Could Use                              | Tradeoff                                                                                              |
| --------------------------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| MongoDB-backed content collection | Static JSON bundled in app assets      | Faster initial implementation but violates backend-delivered requirement and blocks remote updates.   |
| ETag + conditional GET            | TTL-only client cache                  | Simpler but leads to stale-cache ambiguity and unnecessary full payload transfer.                     |
| Server-side search/filter query   | Client-only filtering after full fetch | Works for tiny datasets, but harder to evolve and does not provide canonical backend search behavior. |

**Installation:**

```bash
# No mandatory new packages for Phase 9.
# Existing dependencies already cover API routes, validation, cache, and Flutter state/network.
```

**Version verification (executed 2026-03-26):**

```bash
npm view express version time.modified    # 5.2.1, 2026-03-08
npm view mongoose version time.modified   # 9.3.3, 2026-03-25
npm view zod version time.modified        # 4.3.6, 2026-01-25
npm view ioredis version time.modified    # 5.10.1, 2026-03-19
npm view jest version time.modified       # 30.3.0, 2026-03-10
npm view supertest version time.modified  # 7.2.2, 2026-01-06
```

## Content Contract Strategy

### Recommended Backend Content Schema

Use a single collection (`utility_contents`) keyed by `kind` + `slug` + `version`.

```js
// Suggested shape (Mongoose)
{
  kind: 'faq' | 'bill_guide' | 'legal',
  slug: 'faqs' | 'how-to-read-bill' | 'terms' | 'privacy',
  version: '2026.03.1',
  status: 'draft' | 'published',
  locale: 'en-IN',
  title: String,
  summary: String,

  // FAQ payload
  topics: [{ id: String, label: String }],
  items: [{
    id: String,
    question: String,
    answer: String,
    topicIds: [String],
    keywords: [String],
    order: Number
  }],

  // Bill guide payload
  sections: [{
    id: String,
    heading: String,
    body: String,
    order: Number
  }],
  glossary: [{
    term: String,
    definition: String,
    aliases: [String]
  }],

  // Legal payload
  legalBody: [{ heading: String, paragraphs: [String], order: Number }],
  effectiveFrom: Date,

  publishedAt: Date,
  lastUpdatedAt: Date,
  contentHash: String // stable hash for ETag generation
}
```

### Endpoint Contract (Recommended)

- `GET /api/v1/content/faqs?q=&topic=&limit=&offset=`
- `GET /api/v1/content/bill-guide`
- `GET /api/v1/content/legal/:slug` where `slug in ['terms','privacy']`

All return the existing normalized envelope:

```json
{
  "success": true,
  "message": "FAQ content fetched.",
  "data": {
    "contentVersion": "2026.03.1",
    "lastUpdatedAt": "2026-03-26T10:00:00.000Z",
    "...": "surface-specific payload"
  }
}
```

## Versioning And Cache Invalidation

### HTTP Validation Strategy (CNT-05)

1. Server sends headers for content GET responses:
   - `ETag: "<contentHash>"`
   - `Cache-Control: no-cache`
   - optional `Last-Modified`
2. Client sends `If-None-Match` on subsequent refresh requests.
3. If unchanged, server returns `304 Not Modified` with no body.
4. If changed, server returns `200` + new envelope + new ETag.

### Server Cache Strategy

- Use existing Redis utility (`CacheService`) for read-through cache of published content payloads.
- Suggested cache key pattern:
  - `app:content:faq:published:en-IN`
  - `app:content:bill_guide:published:en-IN`
  - `app:content:legal:terms:published:en-IN`
- On publish/update of content document:
  - Invalidate matching Redis keys using `del` or `delPattern`.
  - New read repopulates cache and emits new ETag.

### Client Freshness Strategy

- Persist per-surface metadata in local storage:
  - `etag`
  - `contentVersion`
  - `lastUpdatedAt`
  - `fetchedAt`
- UI always displays `version` and `last updated` for legal/content pages.
- Manual pull-to-refresh always performs conditional request.
- Never show "updated" success unless server returns 200 with a newer version.

## Architecture Patterns

### Recommended Project Structure

```text
backend/src/
├── models/UtilityContent.model.js        # content schema + indexes
├── controllers/content.controller.js     # faq/bill/legal handlers
├── routes/content.routes.js              # content routes + validation
└── middleware/validation.middleware.js   # add content schemas

wattwise_app/lib/feature/content/
├── models/content_models.dart            # FAQ/Bill/Legal DTOs
├── repository/content_repository.dart    # Dio + conditional headers
├── provider/content_provider.dart        # AsyncNotifier state orchestration
└── screens/                              # faq, bill-guide, legal screens
```

### Pattern 1: Contract-First Content Endpoints

**What:** Add explicit content routes with strict query/param validation and deterministic envelopes.
**When to use:** Every content endpoint in Phase 9.
**Example:**

```javascript
// Source: repo route pattern + zod validation middleware
router.get(
  "/faqs",
  validate("getFaqContent", "query"),
  contentController.getFaqs,
);
router.get("/bill-guide", contentController.getBillGuide);
router.get(
  "/legal/:slug",
  validate("getLegalContent", "params"),
  contentController.getLegalDoc,
);
```

### Pattern 2: Conditional GET With ETag

**What:** Use `If-None-Match` and `ETag` for refresh-safe content delivery.
**When to use:** FAQ, bill-guide, legal fetch endpoints.
**Example:**

```javascript
// Source: MDN ETag / If-None-Match guidance
if (req.headers["if-none-match"] === computedEtag) {
  res.setHeader("ETag", computedEtag);
  return res.status(304).end();
}
res.setHeader("ETag", computedEtag);
res.setHeader("Cache-Control", "no-cache");
sendSuccess(res, 200, "Content fetched.", payload);
```

### Pattern 3: Riverpod Async Content Notifier

**What:** Encapsulate fetch/search/filter/refresh in one provider per surface.
**When to use:** FAQ list/search, bill guide, legal screens.
**Example:**

```dart
// Source: existing profile AsyncNotifier pattern + Riverpod docs
final faqProvider =
    AsyncNotifierProvider<FaqNotifier, FaqViewState>(FaqNotifier.new);

class FaqNotifier extends AsyncNotifier<FaqViewState> {
  @override
  Future<FaqViewState> build() async => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
```

### Anti-Patterns to Avoid

- **Hardcoding FAQ/legal copy in Flutter assets:** breaks backend-delivered and version-refresh requirements.
- **TTL-only cache without validator headers:** causes stale confusion and redundant payload transfer.
- **Returning content without visible version metadata:** violates CNT-04 and weakens trust in legal content freshness.
- **Mixed envelope formats by endpoint:** breaks existing client error/success parsing patterns.

## Don't Hand-Roll

| Problem                                      | Don't Build                               | Use Instead                                  | Why                                                                   |
| -------------------------------------------- | ----------------------------------------- | -------------------------------------------- | --------------------------------------------------------------------- |
| HTTP cache validation protocol               | Custom query params like `?version=` only | Standard `ETag` + `If-None-Match` + `304`    | Standards-based, efficient, and directly supports stale-safe refresh. |
| New cache framework for content              | Custom in-memory per-route maps           | Existing `CacheService` (`ioredis`)          | Already integrated and environment-aware fallback behavior exists.    |
| Widget-local async flags for content screens | Multiple booleans per screen              | Riverpod `AsyncNotifier`/`AsyncValue` states | Consistent with profile flow and testable retry behavior.             |
| Ad-hoc payload parsing in UI                 | Dynamic map traversal everywhere          | Typed DTO mapping in repository layer        | Reduces runtime parsing errors and keeps screens simple.              |

**Key insight:** CNT-05 is solved by protocol correctness (validator headers + explicit metadata), not by shortening cache TTLs.

## Common Pitfalls

### Pitfall 1: Stale content appears "fresh"

**What goes wrong:** UI shows old FAQ/legal text after backend publish.
**Why it happens:** Endpoint uses plain 200 responses with no ETag strategy.
**How to avoid:** Implement conditional requests and display version metadata in UI.
**Warning signs:** Pull-to-refresh always returns 200 but content version never changes.

### Pitfall 2: Search results drift from backend truth

**What goes wrong:** Client-side filtering misses backend topic/keyword updates.
**Why it happens:** Search implemented only on local stale snapshot.
**How to avoid:** Keep search/filter query params in API contract and use local filter only as secondary UX optimization.
**Warning signs:** Same query yields different results across devices.

### Pitfall 3: Legal docs lack audit metadata

**What goes wrong:** Terms/privacy displayed without effective date/version.
**Why it happens:** Legal content treated as plain static text page.
**How to avoid:** Include `version`, `effectiveFrom`, `lastUpdatedAt` in legal payload and render prominently.
**Warning signs:** Support cannot confirm which legal version a user viewed.

### Pitfall 4: Cache invalidation misses publish path

**What goes wrong:** Redis keeps serving outdated content after content update.
**Why it happens:** Publish/update path does not call `cacheService.del(...)`/`delPattern(...)`.
**How to avoid:** Make invalidation mandatory in content publish/update service method.
**Warning signs:** DB shows new version; API still emits old ETag.

## Code Examples

Verified patterns from official sources and existing repo conventions:

### Conditional GET (ETag)

```javascript
// Source: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
// Source: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match
const etag = `"${contentHash}"`;
res.setHeader("ETag", etag);
res.setHeader("Cache-Control", "no-cache");

if (req.headers["if-none-match"] === etag) {
  return res.status(304).end();
}

sendSuccess(res, 200, "Content fetched.", payload);
```

### Mongoose version metadata fields

```javascript
// Source: https://mongoosejs.com/docs/guide.html
const utilityContentSchema = new Schema(
  {
    kind: {
      type: String,
      enum: ["faq", "bill_guide", "legal"],
      required: true,
    },
    slug: { type: String, required: true },
    version: { type: String, required: true },
    status: { type: String, enum: ["draft", "published"], required: true },
    contentHash: { type: String, required: true },
    lastUpdatedAt: { type: Date, required: true },
  },
  { timestamps: true },
);
```

### Riverpod async loading/retry

```dart
// Source: https://riverpod.dev/docs/concepts2/providers
final billGuideProvider = FutureProvider<BillGuide>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.fetchBillGuide();
});
```

## State of the Art

| Old Approach                  | Current Approach                                              | When Changed                                              | Impact                                                            |
| ----------------------------- | ------------------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------- |
| Time-based cache only         | Validator-based HTTP caching (`ETag`, `If-None-Match`, `304`) | Standardized in modern HTTP semantics (RFC 9110/9111 era) | Safer freshness with lower bandwidth.                             |
| Static legal/help copy in-app | Backend-delivered, versioned content documents                | Current common mobile content ops pattern                 | Enables urgent legal/content updates without app release.         |
| Screen-local async handling   | Provider-level async state model                              | Matured with Riverpod architecture adoption               | More predictable loading/error/retry behavior and easier testing. |

**Deprecated/outdated:**

- Assuming `no-cache` means "never store" (it means revalidate before reuse; use `no-store` when storage must be forbidden).
- Using `If-Modified-Since` as primary validator when strong `ETag` is available.

## Open Questions

1. **Editorial source of truth for content updates**
   - What we know: Phase requires backend-delivered content and refresh-safe updates.
   - What's unclear: Whether updates are manual DB/script driven in v2.1 or require admin CMS surface.
   - Recommendation: Keep Phase 9 scope to read APIs + seeded/published content records; defer CMS tooling.

2. **Localization scope in v2.1**
   - What we know: Current requirement text does not mandate multilingual content.
   - What's unclear: Whether locale fallback behavior is needed now.
   - Recommendation: Include `locale` in schema now, but ship with single locale (`en-IN`) for this phase.

3. **Search ranking sophistication**
   - What we know: Requirement asks search/filter relevant results.
   - What's unclear: Need for advanced ranking/fuzzy behavior vs deterministic contains/topic match.
   - Recommendation: Start with deterministic query + topic filter; avoid advanced ranking engine in Phase 9.

## Validation Architecture

### Test Framework

| Property           | Value                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| Framework          | Jest 30.x (`backend`), Flutter `flutter_test` (`wattwise_app`)                                                                |
| Config file        | `backend/package.json` scripts, Flutter default test runner (no custom test config file)                                      |
| Quick run command  | `npm --prefix backend test -- --runInBand --testPathPatterns content && cd wattwise_app && flutter test test/feature/content` |
| Full suite command | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test`                                                 |

### Phase Requirements -> Test Map

| Req ID | Behavior                                                                  | Test Type                                            | Automated Command                                                                                                                                                                                | File Exists? |
| ------ | ------------------------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------ |
| CNT-01 | FAQs/topics are served from backend and rendered in app                   | backend contract + flutter widget                    | `npm --prefix backend test -- --runInBand --runTestsByPath tests/content.contract.test.js && cd wattwise_app && flutter test test/feature/content/faq_screen_test.dart`                          | ❌ Wave 0    |
| CNT-02 | FAQ search/filter returns relevant results                                | backend contract + provider test                     | `npm --prefix backend test -- --runInBand --runTestsByPath tests/content.search.contract.test.js && cd wattwise_app && flutter test test/feature/content/faq_search_provider_test.dart`          | ❌ Wave 0    |
| CNT-03 | Bill guide shows structured sections and glossary                         | backend contract + flutter widget                    | `npm --prefix backend test -- --runInBand --runTestsByPath tests/content.bill_guide.contract.test.js && cd wattwise_app && flutter test test/feature/content/bill_guide_screen_test.dart`        | ❌ Wave 0    |
| CNT-04 | Legal docs include visible version/effective metadata                     | backend contract + flutter widget                    | `npm --prefix backend test -- --runInBand --runTestsByPath tests/content.legal.contract.test.js && cd wattwise_app && flutter test test/feature/content/legal_screen_test.dart`                  | ❌ Wave 0    |
| CNT-05 | Refresh path handles unchanged vs changed content without stale confusion | backend HTTP header contract + provider refresh test | `npm --prefix backend test -- --runInBand --runTestsByPath tests/content.versioning.contract.test.js && cd wattwise_app && flutter test test/feature/content/content_refresh_behavior_test.dart` | ❌ Wave 0    |

### Sampling Rate

- **Per task commit:** run one targeted backend content test and one targeted Flutter content/provider test.
- **Per wave merge:** run all backend `tests/content.*.test.js` plus `wattwise_app/test/feature/content/*`.
- **Phase gate:** full backend Jest + full Flutter content tests green before `/gsd-verify-work`.

### Wave 0 Gaps

- [ ] `backend/tests/content.contract.test.js` - FAQ/topic list envelope + schema assertions.
- [ ] `backend/tests/content.search.contract.test.js` - query/topic filter behavior and empty-result envelope.
- [ ] `backend/tests/content.bill_guide.contract.test.js` - sections/glossary shape validation.
- [ ] `backend/tests/content.legal.contract.test.js` - legal metadata (`version`, `effectiveFrom`, `lastUpdatedAt`) assertions.
- [ ] `backend/tests/content.versioning.contract.test.js` - ETag/If-None-Match/304 behavior.
- [ ] `wattwise_app/test/feature/content/faq_screen_test.dart` - loading/empty/error/retry rendering.
- [ ] `wattwise_app/test/feature/content/faq_search_provider_test.dart` - query/filter state transitions.
- [ ] `wattwise_app/test/feature/content/bill_guide_screen_test.dart` - section/glossary rendering.
- [ ] `wattwise_app/test/feature/content/legal_screen_test.dart` - visible legal version metadata rendering.
- [ ] `wattwise_app/test/feature/content/content_refresh_behavior_test.dart` - 304 unchanged vs 200 updated handling.

## Sources

### Primary (HIGH confidence)

- Repository code:
  - `wattwise_app/lib/feature/profile/screens/profile_screen.dart`
  - `wattwise_app/lib/feature/profile/provider/profile_provider.dart`
  - `wattwise_app/lib/feature/profile/repository/profile_repository.dart`
  - `wattwise_app/lib/core/network/api_client.dart`
  - `backend/src/routes/index.js`
  - `backend/src/utils/ApiResponse.js`
  - `backend/src/middleware/validation.middleware.js`
  - `backend/src/services/CacheService.js`
  - `backend/src/controllers/user.controller.js`
  - `backend/tests/appliance.validation.test.js`
  - `backend/tests/appliance.concurrency.contract.test.js`

- Official docs:
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/304
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
  - https://mongoosejs.com/docs/guide.html
  - https://expressjs.com/en/guide/routing.html
  - https://riverpod.dev/docs/concepts2/providers

### Secondary (MEDIUM confidence)

- npm registry metadata via `npm view` commands (versions and modified timestamps).
- Riverpod homepage/getting-started docs for high-level framework patterns.

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - verified from workspace manifests and npm registry checks.
- Architecture: HIGH - based on direct repository pattern tracing and official HTTP/Riverpod guidance.
- Pitfalls: HIGH - grounded in observed placeholder state and proven cache/version failure modes.

**Research date:** 2026-03-26
**Valid until:** 2026-04-25
