---
phase: 11
slug: reliability-and-milestone-closure
artifact: endpoint-envelope-audit
status: complete
created: 2026-03-27
updated: 2026-03-27
requirements:
  - NFR-02
---

# Phase 11 Endpoint Envelope Audit

This audit records normalized success/error envelope expectations for v2.1 utility flows mounted under /api/v1.

## Route Inventory (from backend router)

- /api/v1/users
- /api/v1/appliances
- /api/v1/content
- /api/v1/support
- /api/v1/solar

## Envelope Baseline

### Success Envelope

Expected shape (normalized):

- success: true
- message: string
- data: object | array
- requestId: string (when propagated by middleware)
- timestamp: ISO-8601 string (or server-side createdAt for persisted entities)

### Error Envelope

Expected shape (normalized):

- success: false
- error: object
- error.code: string
- error.message: string
- requestId: string
- timestamp: ISO-8601 string
- details: array (validation/field issues when relevant)

## Endpoint-Level Audit

| Endpoint Group | Representative Paths                                                          | Success Expectations                                                                                   | Error Expectations                                                                                   | Status |
| -------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- | ------ |
| Users/Profile  | /api/v1/users/me                                                              | Returns updated or fetched profile payload deterministically in data.                                  | Validation failures include structured details and stable error code.                                | Pass   |
| Appliances     | /api/v1/appliances, /api/v1/appliances/:id                                    | Create/update/delete return deterministic payloads reflecting mutation result.                         | Stale-write conflict returns PRECONDITION_FAILED semantics with traceability fields.                 | Pass   |
| Content        | /api/v1/content/faqs, /api/v1/content/bill-guide, /api/v1/content/legal/:slug | Returns published content payload and stable metadata for cache/refresh behavior.                      | Missing/invalid requests return normalized error envelope without transport ambiguity.               | Pass   |
| Support        | /api/v1/support/tickets                                                       | Returns durable ticket reference and submitted metadata in success data.                               | Retryable failures return TEMPORARY_UNAVAILABLE class with actionable guidance.                      | Pass   |
| Solar          | /api/v1/solar/estimate                                                        | Returns low/base/high range estimates with assumptions, limitations, confidence label, and disclaimer. | Validation and backend failures return deterministic error envelope consumable by Flutter providers. | Pass   |

## Regression Guard

- backend/tests/sanity.test.js now enforces that central router mounts all v2.1 endpoint groups.
- This gives a fast baseline check for accidental route envelope drift via missing mounts.

## NFR Mapping

- NFR-02 is satisfied when all listed endpoint groups keep normalized success/error envelope semantics and mount continuity.
