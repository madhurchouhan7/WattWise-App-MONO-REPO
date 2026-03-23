# Technology Stack Delta: Milestone v2.1 Profile Utility Functionalization

**Project:** WattWise Flutter + Backend
**Scope:** Solar Calculator, How to Read Bill, FAQs, Contact Support, Legal, Edit Profile, Manage Appliances
**Researched:** 2026-03-23
**Confidence:** HIGH for baseline reuse, MEDIUM for optional tooling

## Stack Changes (Required)

Minimal-change recommendation: keep existing app architecture and add only one Flutter dependency.

### Flutter (required)

| Package      | Version Constraint | Purpose                                                     | Why                                                                                                |
| ------------ | ------------------ | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| url_launcher | ^6.3.2             | Open email/phone/website/legal links from profile utilities | Required for Contact Support and Legal in a cross-platform way; stable and official plugin family. |

### Backend (required)

No new backend package is required for v2.1.

Reuse existing stack:

- `express` `^5.2.1` for new routes
- `zod` `^4.3.6` for request/response shape validation
- existing auth middleware and `/users/me` route grouping

### Why this is enough

- Networking is already solved (`dio` `^5.9.1` + auth interceptor/retry).
- State management is already solved (`flutter_riverpod`).
- Local lightweight persistence is already solved (`shared_preferences`).
- Appliance/profile storage already exists server-side through current user endpoints.

## Optional Dependencies (Only if you choose richer UX/tooling)

These are optional, not required for milestone completion.

### Flutter optional

| Package          | Version Constraint | When to add                                                    | Risk                                                                |
| ---------------- | ------------------ | -------------------------------------------------------------- | ------------------------------------------------------------------- |
| flutter_markdown | ^0.7.7+1           | If FAQs/Legal pages are served as Markdown from backend or CMS | Low; simple renderer, but introduces formatting ownership concerns. |

### Backend optional

| Package                        | Version Constraint | When to add                                                  | Risk                                                                                              |
| ------------------------------ | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| @asteasolutions/zod-to-openapi | ^8.5.0             | If you want auto-generated OpenAPI from existing Zod schemas | Low-medium; requires schema annotation discipline.                                                |
| swagger-ui-express             | ^5.0.1             | If you want hosted API docs route for frontend alignment     | Low; exposes docs surface to secure in non-prod/prod.                                             |
| openapi-typescript             | ^7.13.0            | If you want generated TS API types in tooling pipelines      | Medium in this repo because Flutter is Dart-first; mostly benefits backend/internal TS utilities. |

## Backend Contracts for v2.1

Recommended route additions under existing authenticated user domain:

### 1) Profile edit flow

- `GET /users/me/profile`
  - Returns editable profile payload (`name`, `phone`, `address`, `householdSize`, `billingProvider`, etc.)
- `PATCH /users/me/profile`
  - Partial update for editable fields
  - Validate with expanded Zod schema (reuse existing profile/address validators)

### 2) Utility content flow (FAQ, bill help, legal, contact)

- `GET /users/me/utility-content`
  - Returns versioned content bundle:
    - `faqItems[]`
    - `billHelpSections[]`
    - `legalLinks[]`
    - `supportChannels[]` (email, phone, site URL)
  - Include `contentVersion` for cache invalidation in Flutter

### 3) Solar calculator support

Two valid patterns, choose one and keep it consistent:

- Client-compute (preferred for v2.1 speed):
  - No new endpoint; Flutter computes from locally entered values and optional tariff fetched from existing profile/billing data.
- Server-compute (if business logic must be centralized):
  - `POST /users/me/solar/estimate`
  - Body validated by Zod (`monthlyUnits`, `rooftopArea`, `city`, `tariffPerUnit`, optional `budget`)
  - Returns deterministic estimate payload and assumptions used

### 4) Manage appliances

- Keep existing `GET/POST/PATCH /users/me/appliances` family.
- No schema/library change needed unless introducing new appliance categories.

## State Management and Persistence Pattern (v2.1)

Keep current app pattern; do not switch frameworks.

- Repository layer:
  - Add `ProfileUtilityRepository` using current `ApiClient` conventions.
- Riverpod providers:
  - `FutureProvider` for utility content bundle.
  - `StateNotifier/Notifier` for profile edit form state and optimistic saves.
- Local cache:
  - Use `shared_preferences` for content version + last fetched utility content timestamp.
  - Continue server as source of truth for profile/appliances.

## No-Go Additions (Do Not Add for v2.1)

| Avoid                                                | Why not now                                              | Existing coverage                                                    |
| ---------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------- |
| `graphql` client/server stack                        | Large contract migration and infra churn                 | Existing REST routes are already in place and authenticated.         |
| New Flutter state framework (`bloc`, `getx`, `mobx`) | Rewriting stable Riverpod architecture                   | `flutter_riverpod` already adopted across repositories/providers.    |
| New local DB for this feature (`isar`, `sqflite`)    | Unneeded complexity for utility pages/forms              | `shared_preferences` + existing server persistence is sufficient.    |
| WebView-only legal/help integration as default       | Adds platform-specific behavior and maintenance overhead | Use API content and `url_launcher` for external legal/support links. |
| New backend ORM/query layer                          | High risk with no feature value                          | Existing `mongoose` model/repository path is sufficient.             |

## Integration and Migration Risks

| Area                                            | Risk                                           | Mitigation                                                                                 |
| ----------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Unpinned Flutter dependencies already present   | Transitive breakage between builds             | Pin newly added deps explicitly and consider gradually pinning existing blank constraints. |
| Placeholder UI callbacks in profile screen      | Feature appears complete but is non-functional | Wire all callbacks to routes/use-cases first, then add API calls.                          |
| Utility content drift across app versions       | Stale FAQ/legal/support information            | Use `contentVersion` from backend and invalidate cache by version.                         |
| Solar estimate inconsistency (client vs server) | Different numbers shown across clients         | Declare one source of truth; if client-compute, freeze formula constants by app version.   |

## Install Commands

```bash
# Flutter (required)
flutter pub add url_launcher:^6.3.2

# Optional backend docs tooling
npm install @asteasolutions/zod-to-openapi@^8.5.0 swagger-ui-express@^5.0.1
npm install -D openapi-typescript@^7.13.0
```

## Final Recommendation

1. Add only `url_launcher` on Flutter.
2. Add no required backend dependency.
3. Implement new routes + Zod schemas for profile utility content and profile edit.
4. Keep Dio + Riverpod + existing user route patterns unchanged.

This gives full v2.1 functionality with minimal risk and no architectural churn.

## Sources

- Pub API (latest stable): `url_launcher` `6.3.2`.
- npm registry (latest stable): `@asteasolutions/zod-to-openapi` `8.5.0`.
- npm registry (latest stable): `swagger-ui-express` `5.0.1`.
- npm registry (latest stable): `openapi-typescript` `7.13.0`.
