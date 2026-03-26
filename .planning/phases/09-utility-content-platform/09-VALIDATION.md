---
phase: 9
slug: utility-content-platform
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-24
---

# Phase 9 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property               | Value                                                                         |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Framework**          | jest 30.x + flutter test                                                      |
| **Config file**        | backend/package.json, wattwise_app/pubspec.yaml                               |
| **Quick run command**  | `npm --prefix backend test -- --runInBand tests/content.contract.test.js`     |
| **Full suite command** | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |
| **Estimated runtime**  | ~140 seconds                                                                  |

## Sampling Rate

- **After every task commit:** Run quick command above
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 140 seconds

## Per-Task Verification Map

| Task ID  | Plan | Wave | Requirement | Test Type          | Automated Command                                                               | File Exists | Status     |
| -------- | ---- | ---- | ----------- | ------------------ | ------------------------------------------------------------------------------- | ----------- | ---------- |
| 09-01-01 | 01   | 1    | CNT-01      | integration        | `npm --prefix backend test -- --runInBand tests/content.contract.test.js`       | ⚠️ W0       | ⬜ pending |
| 09-01-02 | 01   | 1    | CNT-05      | integration        | `npm --prefix backend test -- --runInBand tests/content.cache.test.js`          | ⚠️ W0       | ⬜ pending |
| 09-02-01 | 02   | 2    | CNT-02      | widget             | `cd wattwise_app && flutter test test/feature/profile/content_search_test.dart` | ⚠️ W0       | ⬜ pending |
| 09-02-02 | 02   | 2    | CNT-03      | widget/integration | `cd wattwise_app && flutter test test/feature/profile/bill_guide_test.dart`     | ⚠️ W0       | ⬜ pending |
| 09-03-01 | 03   | 3    | CNT-04      | widget/integration | `cd wattwise_app && flutter test test/feature/profile/legal_content_test.dart`  | ⚠️ W0       | ⬜ pending |

## Wave 0 Requirements

- [ ] `backend/tests/content.contract.test.js`
- [ ] `backend/tests/content.cache.test.js`
- [ ] `wattwise_app/test/feature/profile/content_search_test.dart`
- [ ] `wattwise_app/test/feature/profile/bill_guide_test.dart`
- [ ] `wattwise_app/test/feature/profile/legal_content_test.dart`

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Wave 0 covers all planned tests
- [ ] Feedback latency < 140s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
