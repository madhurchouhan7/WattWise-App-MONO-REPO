---
phase: 10
slug: support-and-solar-workflows
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-24
---

# Phase 10 - Validation Strategy

## Test Infrastructure

| Property               | Value                                                                         |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Framework**          | jest 30.x + flutter test                                                      |
| **Config file**        | backend/package.json, wattwise_app/pubspec.yaml                               |
| **Quick run command**  | `npm --prefix backend test -- --runInBand tests/support.contract.test.js`     |
| **Full suite command** | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |
| **Estimated runtime**  | ~150 seconds                                                                  |

## Sampling Rate

- After every task commit: quick command
- After every wave: full suite
- Before verify-work: full suite green
- Max feedback latency: 150 seconds

## Per-Task Verification Map

| Task ID  | Plan | Wave | Requirement | Test Type   | Automated Command                                                                 | File Exists | Status     |
| -------- | ---- | ---- | ----------- | ----------- | --------------------------------------------------------------------------------- | ----------- | ---------- |
| 10-01-01 | 01   | 1    | SUP-01      | integration | `npm --prefix backend test -- --runInBand tests/support.contract.test.js`         | ⚠️ W0       | ⬜ pending |
| 10-01-02 | 01   | 1    | SUP-04      | integration | `npm --prefix backend test -- --runInBand tests/support.audit.test.js`            | ⚠️ W0       | ⬜ pending |
| 10-02-01 | 02   | 2    | SOL-01      | integration | `npm --prefix backend test -- --runInBand tests/solar.contract.test.js`           | ⚠️ W0       | ⬜ pending |
| 10-03-01 | 03   | 3    | SOL-03      | widget      | `cd wattwise_app && flutter test test/feature/profile/solar_calculator_test.dart` | ⚠️ W0       | ⬜ pending |

## Wave 0 Requirements

- [ ] backend/tests/support.contract.test.js
- [ ] backend/tests/support.audit.test.js
- [ ] backend/tests/solar.contract.test.js
- [ ] wattwise_app/test/feature/profile/contact_support_test.dart
- [ ] wattwise_app/test/feature/profile/solar_calculator_test.dart

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Feedback latency < 150s
- [ ] nyquist_compliant set true after alignment

**Approval:** pending
