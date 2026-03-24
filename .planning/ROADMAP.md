# Milestone v2.1 Roadmap

**5 phases** | **24 requirements mapped** | Coverage complete ✓

Phase numbering continues from prior milestone phases.

| #   | Phase                              | Goal                                                                                                   | Requirements                                                   | Success Criteria |
| --- | ---------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- | ---------------- |
| 7   | Contract Freeze and Profile Wiring | Finalize profile and settings contracts, then connect profile screens to real providers and endpoints. | PRO-01, PRO-02, PRO-03, PRO-04                                 | 5                |
| 8   | Appliance Domain Hardening         | Make appliance CRUD safe, deterministic, and user-recoverable                                          | APP-01, APP-02, APP-03, APP-04                                 | 5                |
| 9   | Utility Content Platform           | Deliver dynamic FAQ, bill-help, and legal content with version-safe refresh                            | CNT-01, CNT-02, CNT-03, CNT-04, CNT-05                         | 5                |
| 10  | Support and Solar Workflows        | Ship durable support flow and Solar Calculator v1 behavior                                             | SUP-01, SUP-02, SUP-03, SUP-04, SOL-01, SOL-02, SOL-03, SOL-04 | 6                |
| 11  | Reliability and Milestone Closure  | Harden cross-feature behavior and close v2.1 verification gaps                                         | NFR-01, NFR-02, NFR-03                                         | 5                |

## Phase Details

### Phase 7: Contract Freeze and Profile Wiring

Goal: Finalize profile and settings contracts, then connect profile screens to real providers and endpoints.
Requirements: PRO-01, PRO-02, PRO-03, PRO-04
**Plans:** 3/3 plans executed

Plans:

- [x] 07-01-PLAN.md - Freeze profile/settings contract matrix, route Edit Profile navigation, and create Wave-0 profile test scaffolding.
- [x] 07-02-PLAN.md - Enforce backend profile update contract with route validation and inline-mappable field error details.
- [x] 07-03-PLAN.md - Wire Riverpod profile providers/screens with full async feedback and restart-safe persistence.

Success criteria:

1. Endpoint contract matrix exists for profile/settings load and save paths.
2. Profile screen actions navigate to functional flows (no placeholders).
3. Profile fetch/update states include loading, error, retry, and success feedback.
4. Validation errors are surfaced inline before submit.
5. Saved profile data is visible after reopen and app restart.

### Phase 8: Appliance Domain Hardening

Goal: Ensure Manage Appliances operations are safe under real-world mutation and refresh conditions.
Requirements: APP-01, APP-02, APP-03, APP-04
**Plans:** 3 plans

Plans:

- [x] 08-01-PLAN.md - Freeze appliance mutation contracts, create Wave-0 tests, and define migration-safety guardrails.
- [x] 08-02-PLAN.md - Harden backend appliance create/patch/delete behavior with non-destructive and concurrency-safe mutations.
- [ ] 08-03-PLAN.md - Wire Manage Appliances client delete/retry/conflict UX for deterministic recovery behavior.

Success criteria:

1. Add/edit/delete appliance operations complete with deterministic success/error states.
2. Updates are non-destructive and do not remove unrelated appliance records.
3. Delete path requires confirmation and updates list immediately.
4. Concurrency-safe update strategy prevents stale-write overwrite.
5. Appliance mutation failures provide retry and recovery guidance.

### Phase 9: Utility Content Platform

Goal: Power FAQ, bill-reading education, and legal surfaces from backend-delivered content.
Requirements: CNT-01, CNT-02, CNT-03, CNT-04, CNT-05
Success criteria:

1. FAQ list/topics load from backend and render in app.
2. FAQ search or filter returns relevant content reliably.
3. Bill-reading guide displays structured educational sections and glossary.
4. Legal docs show version/date metadata and open correctly.
5. Content refresh path prevents stale-cache confusion after backend updates.

### Phase 10: Support and Solar Workflows

Goal: Deliver complete support request handling and dynamic Solar Calculator v1.
Requirements: SUP-01, SUP-02, SUP-03, SUP-04, SOL-01, SOL-02, SOL-03, SOL-04
Success criteria:

1. Contact Support submission captures required fields and posts successfully.
2. Successful support submission returns and shows durable reference ID.
3. Failed support submission gives actionable retry options.
4. Support and legal-consent events are traceable in backend logs or audit records.
5. Solar Calculator computes and displays a transparent estimate range.
6. Solar assumptions and limitations are clearly visible to users.

### Phase 11: Reliability and Milestone Closure

Goal: Validate end-to-end resilience and finalize v2.1 verification evidence.
Requirements: NFR-01, NFR-02, NFR-03
Success criteria:

1. All new utility screens handle loading/empty/error/retry consistently.
2. New endpoints return normalized success and error envelopes.
3. Negative-path tests pass for profile, appliances, content, support, and solar flows.
4. Milestone UAT checklist is completed with no critical open gaps.
5. Verification artifacts are documented for milestone closure.

## Requirement Coverage Matrix

- Phase 7 -> PRO-01, PRO-02, PRO-03, PRO-04
- Phase 8 -> APP-01, APP-02, APP-03, APP-04
- Phase 9 -> CNT-01, CNT-02, CNT-03, CNT-04, CNT-05
- Phase 10 -> SUP-01, SUP-02, SUP-03, SUP-04, SOL-01, SOL-02, SOL-03, SOL-04
- Phase 11 -> NFR-01, NFR-02, NFR-03

All active milestone requirements are mapped to exactly one phase.
