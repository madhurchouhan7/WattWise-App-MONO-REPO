# Phase 09 Content Contract Matrix

Purpose: Freeze Phase 09 utility-content API and client expectations before runtime wiring to prevent backend/client drift.

## Canonical Routes

| Requirement    | Method | Route                | Purpose                                                         |
| -------------- | ------ | -------------------- | --------------------------------------------------------------- |
| CNT-01, CNT-02 | GET    | /content/faqs        | Fetch FAQ topics/items with optional search and topic filtering |
| CNT-03         | GET    | /content/bill-guide  | Fetch structured bill guide sections and glossary               |
| CNT-04, CNT-05 | GET    | /content/legal/:slug | Fetch legal content by slug with visible freshness metadata     |

## Request Contracts

### GET /content/faqs

| Field  | Location | Type           | Required | Notes                                                       |
| ------ | -------- | -------------- | -------- | ----------------------------------------------------------- |
| q      | query    | string         | no       | Full-text style keyword search over FAQ question and answer |
| topic  | query    | string         | no       | Exact topic key filter                                      |
| limit  | query    | integer string | no       | Page size; defaults to server standard                      |
| offset | query    | integer string | no       | Pagination offset                                           |

### GET /content/bill-guide

No query or path parameters in Phase 09 contract.

### GET /content/legal/:slug

| Field | Location | Type   | Required | Notes                                |
| ----- | -------- | ------ | -------- | ------------------------------------ |
| slug  | param    | string | yes      | Allowed values are terms and privacy |

## Response Envelope

All content routes must return the normalized success envelope.

```json
{
  "success": true,
  "message": "Content fetched.",
  "data": {
    "contentVersion": "2026.03.1",
    "lastUpdatedAt": "2026-03-26T00:00:00.000Z",
    "effectiveFrom": "2026-03-01T00:00:00.000Z"
  }
}
```

Error responses follow existing platform error envelope conventions (`success: false`, message, and error details where applicable).

## Payload Contracts

### FAQ Payload (`/content/faqs`)

```json
{
  "topics": [{ "id": "billing-basics", "label": "Billing Basics" }],
  "items": [
    {
      "id": "faq-1",
      "topic": "billing-basics",
      "question": "What is fixed charge?",
      "answer": "A monthly base charge."
    }
  ],
  "contentVersion": "2026.03.1",
  "lastUpdatedAt": "2026-03-26T00:00:00.000Z",
  "effectiveFrom": "2026-03-01T00:00:00.000Z"
}
```

### Bill Guide Payload (`/content/bill-guide`)

```json
{
  "sections": [
    {
      "id": "s1",
      "heading": "Fixed Charges",
      "body": "Base monthly fee."
    }
  ],
  "glossary": [
    {
      "term": "kWh",
      "definition": "Unit of electricity consumption."
    }
  ],
  "contentVersion": "2026.03.1",
  "lastUpdatedAt": "2026-03-26T00:00:00.000Z",
  "effectiveFrom": "2026-03-01T00:00:00.000Z"
}
```

### Legal Payload (`/content/legal/:slug`)

```json
{
  "slug": "terms",
  "title": "Terms and Conditions",
  "sections": [
    {
      "heading": "Scope",
      "paragraphs": ["...legal text..."]
    }
  ],
  "contentVersion": "2026.03.1",
  "lastUpdatedAt": "2026-03-26T00:00:00.000Z",
  "effectiveFrom": "2026-03-01T00:00:00.000Z"
}
```

## Conditional Refresh Contract (CNT-05)

The following HTTP validation headers are mandatory for all three routes:

- Response header `ETag` must be present on successful content responses.
- Request header `If-None-Match` is accepted for conditional refresh.
- If client validator matches current content validator, server returns `304 Not Modified` with no body.
- If content changed, server returns `200` with updated payload and new `ETag`.

Reference flow:

1. Client loads content and stores `ETag`, `contentVersion`, and `lastUpdatedAt`.
2. Client refresh sends `If-None-Match` with stored validator.
3. Server responds with `304` when unchanged or `200` when updated.
4. Client refresh feedback maps `304 -> already up to date` and `200 -> content updated`.

## Requirement Traceability

| Requirement | Route(s)                | Contract Guarantee                                                                       |
| ----------- | ----------------------- | ---------------------------------------------------------------------------------------- |
| CNT-01      | /content/faqs           | FAQ topics and item list served by backend contract                                      |
| CNT-02      | /content/faqs?q=&topic= | Search and filter semantics frozen in query contract                                     |
| CNT-03      | /content/bill-guide     | Structured sections and glossary payload contract                                        |
| CNT-04      | /content/legal/:slug    | Legal metadata fields (`contentVersion`, `effectiveFrom`, `lastUpdatedAt`) are mandatory |
| CNT-05      | all content routes      | Conditional refresh via `ETag`, `If-None-Match`, and `304` behavior                      |

## Integration Order (Deterministic)

1. Backend-first: implement routes/controllers for `/content/faqs`, `/content/bill-guide`, `/content/legal/:slug` and enforce envelope plus metadata and validator headers.
2. Backend verification: satisfy `backend/tests/content.contract.test.js` and `backend/tests/content.cache.test.js`.
3. Flutter wiring: implement content repository/provider/screens against this frozen matrix.
4. Flutter verification: satisfy `wattwise_app/test/feature/profile/content_search_test.dart`, `wattwise_app/test/feature/profile/bill_guide_test.dart`, and `wattwise_app/test/feature/profile/legal_content_test.dart`.

This order is required to avoid client-contract drift.
