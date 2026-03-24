# Requirements: WattWise Milestone v2.1

**Defined:** 2026-03-23
**Core Value:** Help users monitor their electricity consumption, discover insights, and generate actionable plans to reduce bills.

## v2.1 Requirements

### Profile Core

- [x] **PRO-01**: User can view current profile details and settings with clear loading and error states.
- [x] **PRO-02**: User can edit profile fields (name, avatar, phone or equivalent supported fields) and save successfully.
- [x] **PRO-03**: User sees inline validation feedback for invalid profile inputs before submission.
- [x] **PRO-04**: Updated profile data persists and is reflected after app restart or screen revisit.

### Appliances

- [ ] **APP-01**: User can add an appliance with validated fields and receive success or error feedback.
- [ ] **APP-02**: User can edit appliance details without losing unrelated appliance records.
- [ ] **APP-03**: User can delete an appliance with confirmation and immediate list refresh.
- [ ] **APP-04**: Appliance updates are concurrency-safe to avoid overwriting newer data from another session.

### Content Hub

- [ ] **CNT-01**: User can open FAQs and browse topics from backend-delivered content.
- [ ] **CNT-02**: User can search or filter FAQ content and see relevant results.
- [ ] **CNT-03**: User can open How to Read Bill guidance with structured sections and glossary support.
- [ ] **CNT-04**: User can access Legal documents (terms/privacy or equivalents) with visible version metadata.
- [ ] **CNT-05**: Content views can refresh to newer content versions without stale-cache confusion.

### Support Flow

- [ ] **SUP-01**: User can submit a support request with category, message, and contact details.
- [ ] **SUP-02**: User receives a durable support reference ID after successful submission.
- [ ] **SUP-03**: User gets clear retry guidance when support submission fails.
- [ ] **SUP-04**: Support submissions and legal consent events are logged with traceable metadata.

### Solar Calculator v1

- [ ] **SOL-01**: User can input required home and consumption fields to calculate a solar estimate.
- [ ] **SOL-02**: User sees estimate output as a transparent range with stated assumptions.
- [ ] **SOL-03**: User can adjust key inputs and instantly recalculate updated estimates.
- [ ] **SOL-04**: Calculator clearly communicates limits and avoids implying financing-grade precision.

### Non-Functional

- [ ] **NFR-01**: Each new profile utility screen handles loading, empty, error, and retry states consistently.
- [ ] **NFR-02**: API responses for new utility endpoints follow a normalized success/error envelope.
- [ ] **NFR-03**: End-to-end flows for profile, appliances, content, support, and solar pass milestone UAT.

## Future Requirements (v2.2+)

### Solar and Support Enhancements

- **SOL-05**: User can run financing and ROI optimization scenarios with lender-aware assumptions.
- **SUP-05**: User can view threaded support conversation history in-app.
- **CNT-06**: User gets personalized bill education and FAQ ranking based on usage patterns.

## Out of Scope

| Feature                                | Reason                                                            |
| -------------------------------------- | ----------------------------------------------------------------- |
| Full visual redesign of profile area   | Milestone targets functionalization using existing UI patterns    |
| Migration away from Riverpod           | Existing architecture already aligns with target state management |
| Installer-grade solar quotation engine | Requires policy, compliance, and partner data beyond v2.1         |

## Traceability

| Requirement | Phase    | Status  |
| ----------- | -------- | ------- |
| PRO-01      | Phase 7  | Complete |
| PRO-02      | Phase 7  | Complete |
| PRO-03      | Phase 7  | Complete |
| PRO-04      | Phase 7  | Complete |
| APP-01      | Phase 8  | Pending |
| APP-02      | Phase 8  | Pending |
| APP-03      | Phase 8  | Pending |
| APP-04      | Phase 8  | Pending |
| CNT-01      | Phase 9  | Pending |
| CNT-02      | Phase 9  | Pending |
| CNT-03      | Phase 9  | Pending |
| CNT-04      | Phase 9  | Pending |
| CNT-05      | Phase 9  | Pending |
| SUP-01      | Phase 10 | Pending |
| SUP-02      | Phase 10 | Pending |
| SUP-03      | Phase 10 | Pending |
| SUP-04      | Phase 10 | Pending |
| SOL-01      | Phase 10 | Pending |
| SOL-02      | Phase 10 | Pending |
| SOL-03      | Phase 10 | Pending |
| SOL-04      | Phase 10 | Pending |
| NFR-01      | Phase 11 | Pending |
| NFR-02      | Phase 11 | Pending |
| NFR-03      | Phase 11 | Pending |

**Coverage:**

- v2.1 requirements: 24 total
- Mapped to phases: 24
- Unmapped: 0

---

_Requirements defined: 2026-03-23_
_Last updated: 2026-03-23 after milestone v2.1 definition_
