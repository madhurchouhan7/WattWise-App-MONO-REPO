# Feature Landscape

**Domain:** Functional profile utility screens for consumer energy app (milestone v2.1)
**Researched:** 2026-03-23
**Confidence:** MEDIUM-HIGH

## Scope

Target profile utility features for v2.1:

- Solar Calculator
- Bill Reading Education
- FAQs
- Contact Support
- Legal
- Edit Profile
- Manage Appliances

Goal: move current profile placeholders to functional, backend-connected experiences while preserving existing WattWise UI/UX patterns.

## Table Stakes

These are baseline expectations in utility/energy apps. Missing these usually feels broken to users.

| Feature Area           | Typical User-Centric Behavior                                                                                                           | Complexity | Dependencies                                                                                            | v2.1 vs Future                            |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| Edit Profile           | User can view and update identity + household metadata, save, and see success/error state immediately                                   | MEDIUM     | `GET/PUT /api/v1/users/me`, auth token, field validation, cache invalidation already present in backend | **v2.1**                                  |
| Manage Appliances      | User can add/remove appliances, adjust usage level/count/specs, save to backend, and see fresh list on reopen                           | MEDIUM     | Existing appliance screens/providers, `GET/POST /api/v1/appliances`, `/api/v1/appliances/bulk`          | **v2.1 hardening**                        |
| FAQs                   | Searchable FAQ list grouped by topics (billing, meter, tariff, app issues); each item expandable and easy to scan                       | LOW-MEDIUM | Static CMS JSON or backend FAQ endpoint, local cache, analytics on top queries                          | **v2.1** (static or remote-config-backed) |
| Contact Support        | In-app contact entry point with category selection, context payload (user id/app version), response expectations, and fallback channels | MEDIUM     | Support ticket endpoint/email relay, auth identity, device/app diagnostics                              | **v2.1 baseline**                         |
| Legal                  | Dedicated legal hub with Terms, Privacy, Data Consent, and policy version/date; links open reliably and are readable on mobile          | LOW        | Hosted legal docs URLs, deep-link/webview handler, version metadata                                     | **v2.1**                                  |
| Bill Reading Education | Structured walkthrough of bill sections (due date, usage, rate slab, taxes, arrears), glossary, and visual examples                     | MEDIUM     | Existing bill domain model, optional sample bill payloads, content authoring                            | **v2.1**                                  |

## Differentiators

These are high-value enhancements that can make profile utilities feel intelligent and product-defining.

| Feature Area           | Differentiator                                                                                                  | Value Proposition                                                         | Complexity  | Dependencies                                                                         | v2.1 vs Future                            |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------ | ----------------------------------------- |
| Solar Calculator       | Personalized savings estimator using user location, tariff, and current appliance profile with confidence range | Converts curiosity into concrete action and creates strong upgrade intent | HIGH        | Tariff logic, geo context, appliance usage baseline, optional irradiance data source | **Future (v2.2+)**                        |
| Bill Reading Education | Interactive "why this changed" explainer linked to user's latest bill trends                                    | Reduces bill anxiety and support tickets with contextual coaching         | HIGH        | Bill history APIs, explanation rules engine, chart overlays                          | **Future**                                |
| FAQs                   | Intent-aware FAQ ranking (top by user segment + season + recent behavior)                                       | Increases self-serve resolution and reduces support load                  | MEDIUM      | Analytics events, personalization layer, ranking logic                               | **Future**                                |
| Contact Support        | Smart pre-fill and triage (auto attach logs + account context + predicted issue category)                       | Faster first-response and fewer back-and-forth tickets                    | MEDIUM-HIGH | Ticketing integration, telemetry consent flow, issue taxonomy                        | **Future (phase after baseline support)** |
| Manage Appliances      | Appliance health nudges (usage anomaly, replacement threshold, efficiency score)                                | Creates ongoing retention loop and measurable savings outcomes            | HIGH        | Usage inference, benchmarks, notifications pipeline                                  | **Future**                                |

## Anti-Features

Features to explicitly avoid in v2.1, even if they sound attractive.

| Anti-Feature                                                                         | Why Teams Ask For It           | Why It Hurts                                 | Better Alternative                                      |
| ------------------------------------------------------------------------------------ | ------------------------------ | -------------------------------------------- | ------------------------------------------------------- |
| Fake precision in Solar Calculator (single exact payback number with no uncertainty) | Marketing-friendly output      | Undermines trust when real bills differ      | Show low/med/high ranges and assumptions                |
| Overly long bill education articles with no guided flow                              | Easier to dump content quickly | Users abandon before understanding           | Progressive, section-by-section explainers with visuals |
| Contact Support as only external email link                                          | Fastest implementation         | Breaks context handoff and slows resolution  | In-app form first, then fallback channels               |
| Legal hidden behind tiny footer links                                                | Cleaner-looking UI             | Compliance and trust risk                    | Dedicated Legal screen from profile menu                |
| Appliance editor that allows invalid states (zero count, missing category)           | Less validation code initially | Causes backend errors and inconsistent plans | Client validation mirroring backend constraints         |
| Shipping all features as webviews only                                               | Fast to launch                 | Inconsistent UX and weak offline behavior    | Native shells with selective webview fallback           |

## Feature Requirements By Area

### 1) Solar Calculator

| Requirement    | User Behavior Contract                                                         | Complexity | Dependencies                                   | Recommendation                                                  |
| -------------- | ------------------------------------------------------------------------------ | ---------- | ---------------------------------------------- | --------------------------------------------------------------- |
| Input capture  | User enters roof type/size, monthly bill, location, tariff or utility          | MEDIUM     | Profile address, bill history, tariff defaults | v2.1: lightweight calculator with transparent assumptions       |
| Output clarity | Show estimated generation (kWh), bill offset (%), savings range, payback range | HIGH       | Calculation model + assumptions library        | v2.1: include range-based estimate only, no financing optimizer |
| Explainability | User can inspect assumptions (sun hours, losses, tariff)                       | MEDIUM     | Content + model metadata                       | v2.1 required                                                   |

### 2) Bill Reading Education

| Requirement      | User Behavior Contract                                                               | Complexity | Dependencies                    | Recommendation |
| ---------------- | ------------------------------------------------------------------------------------ | ---------- | ------------------------------- | -------------- |
| Bill anatomy     | User taps each bill section and sees plain-language meaning + "why it matters"       | MEDIUM     | Content model, bill field map   | v2.1 required  |
| Glossary         | User can search terms like kWh, fixed charge, subsidy, slab                          | LOW        | Local glossary data             | v2.1 required  |
| Contextual hints | User sees likely reason for higher bill (seasonal use, tariff slab, appliance usage) | HIGH       | Bill history + insights linkage | Future         |

### 3) FAQs

| Requirement        | User Behavior Contract                                                                         | Complexity | Dependencies                          | Recommendation |
| ------------------ | ---------------------------------------------------------------------------------------------- | ---------- | ------------------------------------- | -------------- |
| Fast discovery     | User can search and filter FAQs by topic in <3 taps                                            | LOW        | FAQ data source                       | v2.1 required  |
| Self-serve handoff | If FAQ doesn't solve issue, user can escalate directly to Contact Support with topic prefilled | LOW-MEDIUM | Navigation + support form integration | v2.1 required  |
| Adaptive ranking   | Most relevant FAQs appear first for user's context                                             | MEDIUM     | Analytics + ranking logic             | Future         |

### 4) Contact Support

| Requirement       | User Behavior Contract                                                     | Complexity | Dependencies                                  | Recommendation                       |
| ----------------- | -------------------------------------------------------------------------- | ---------- | --------------------------------------------- | ------------------------------------ |
| Structured ticket | User selects issue type, adds message/screenshots, submits, gets ticket ID | MEDIUM     | Ticket endpoint/service provider, file upload | v2.1 required                        |
| Transparent SLA   | User sees expected response time and status updates                        | MEDIUM     | Ticket status sync                            | v2.1 baseline (status can be simple) |
| Emergency routing | User sees clear alternate channels for urgent power/billing issues         | LOW        | Content + locale config                       | v2.1 required                        |

### 5) Legal

| Requirement        | User Behavior Contract                                          | Complexity | Dependencies                            | Recommendation                     |
| ------------------ | --------------------------------------------------------------- | ---------- | --------------------------------------- | ---------------------------------- |
| Policy access      | User opens Terms/Privacy/Consent docs from one legal hub        | LOW        | URLs + webview/deep-link                | v2.1 required                      |
| Version visibility | User sees last updated date + policy version                    | LOW        | Metadata in docs service                | v2.1 required                      |
| Consent actions    | User can review and update data-sharing/marketing consent state | MEDIUM     | Existing user consent fields in backend | v2.1 if UX scope allows, else v2.2 |

### 6) Edit Profile

| Requirement         | User Behavior Contract                                                        | Complexity | Dependencies                                   | Recommendation |
| ------------------- | ----------------------------------------------------------------------------- | ---------- | ---------------------------------------------- | -------------- |
| Profile editing     | Update name/avatar/address/budget/currency with immediate validation feedback | MEDIUM     | `PUT /api/v1/users/me`, model validators       | v2.1 required  |
| Preferences editing | Update household/plan preferences without breaking active plan behavior       | MEDIUM     | User service update paths + cache invalidation | v2.1 required  |
| Reliability states  | Clear loading/success/error states and retry path                             | LOW        | Existing UI patterns (shimmer/snackbar)        | v2.1 required  |

### 7) Manage Appliances

| Requirement           | User Behavior Contract                                          | Complexity | Dependencies                              | Recommendation |
| --------------------- | --------------------------------------------------------------- | ---------- | ----------------------------------------- | -------------- |
| CRUD integrity        | Add/edit/remove appliances and persist accurately               | MEDIUM     | Existing appliance repository + endpoints | v2.1 required  |
| Validation guardrails | Prevent invalid counts, categories, dropdown mismatch           | MEDIUM     | Client validators + backend schema        | v2.1 hardening |
| State consistency     | Reopen screen and see server-truth state (no ghost local edits) | MEDIUM     | Init provider + robust refresh after save | v2.1 required  |

## Dependency Graph

```text
Auth + Profile APIs
    -> Edit Profile
    -> Contact Support (identity prefill)

Appliance APIs
    -> Manage Appliances
    -> Solar Calculator personalization

Bill APIs + Bill Domain Content
    -> Bill Reading Education
    -> FAQ topics
    -> Solar Calculator assumptions (bill baseline)

Support Ticketing Integration
    -> Contact Support
    -> FAQ escalation

Legal Docs Hosting + Consent Fields
    -> Legal
    -> Edit Profile consent controls
```

## Milestone Recommendation

### Include In v2.1 (Must Ship)

1. Edit Profile fully functional on existing `GET/PUT /api/v1/users/me`.
2. Manage Appliances reliability hardening and validation pass.
3. FAQs (topic + search + escalation to support).
4. Contact Support baseline ticket form and fallback channels.
5. Legal hub with Terms/Privacy/Consent links and metadata.
6. Bill Reading Education v1 (guided static + glossary + simple examples).
7. Solar Calculator v1 (assumption-based range output, not financing-grade).

### Defer To Future (v2.2+)

1. Solar financing optimizer (loan/EMI, subsidy scenarios, installer marketplace).
2. AI bill anomaly explainers personalized per billing cycle.
3. Dynamic FAQ ranking and intent personalization.
4. Full support inbox with threaded conversation history and push updates.
5. Advanced appliance efficiency scoring and proactive lifecycle nudges.

## Confidence Assessment

| Area                                         | Confidence  | Notes                                                                            |
| -------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| Edit Profile + Manage Appliances feasibility | HIGH        | Directly supported by current Flutter providers and backend routes/controllers.  |
| FAQ/Support/Legal baseline expectations      | MEDIUM-HIGH | Strongly consistent across major utility help centers and account apps.          |
| Solar calculator best-practice output format | MEDIUM      | Reliable formula patterns are clear; regional tariff/financing specifics vary.   |
| Bill education interaction design            | MEDIUM-HIGH | Utility sites consistently use bill anatomy, glossary, and comparison workflows. |

## Sources

### Internal (HIGH confidence)

- `.planning/PROJECT.md`
- `README.md`
- `wattwise_app/lib/feature/profile/screens/profile_screen.dart`
- `wattwise_app/lib/feature/profile/screens/manage_appliances_screen.dart`
- `wattwise_app/lib/feature/profile/provider/manage_appliances_provider.dart`
- `wattwise_app/lib/feature/on_boarding/provider/on_boarding_page_5_notifier.dart`
- `wattwise_app/lib/feature/on_boarding/repository/appliance_repository.dart`
- `backend/src/routes/user.routes.js`
- `backend/src/routes/appliance.routes.js`
- `backend/src/routes/bill.routes.js`
- `backend/src/controllers/user.controller.js`
- `backend/src/models/User.model.js`

### External (MEDIUM confidence)

- U.S. DOE Energy Saver: https://www.energy.gov/energysaver/estimating-appliance-and-home-electronic-energy-use
- PG&E Bill Education: https://www.pge.com/en/account/billing-and-assistance/understand-your-bill.html
- Octopus Help and FAQs: https://www.octopus.energy/help-and-faqs/
- ENERGY STAR incentives context: https://www.energystar.gov/about/federal_tax_credits
