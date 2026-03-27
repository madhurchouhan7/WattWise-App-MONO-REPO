---
phase: 11
slug: reliability-and-milestone-closure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-27
---

# Phase 11 - Validation Strategy

## Test Infrastructure

| Property           | Value                                                                       |
| ------------------ | --------------------------------------------------------------------------- |
| Framework          | jest 30.x + flutter test                                                    |
| Config file        | backend/package.json, wattwise_app/pubspec.yaml                             |
| Quick run command  | npm --prefix backend test -- --runInBand tests/sanity.test.js               |
| Full suite command | npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test |
| Estimated runtime  | ~180 seconds                                                                |

## Sampling Rate

- After every task commit: run quick command
- After every plan wave: run full suite command
- Before verify-work: full suite must be green
- Max feedback latency: 180 seconds

## Per-Task Verification Map

| Task ID  | Plan | Wave | Requirement | Test Type   | Automated Command                                                                         | File Exists | Status  |
| -------- | ---- | ---- | ----------- | ----------- | ----------------------------------------------------------------------------------------- | ----------- | ------- |
| 11-01-01 | 01   | 1    | NFR-02      | integration | npm --prefix backend test -- --runInBand tests/sanity.test.js                             | Yes         | pending |
| 11-01-02 | 01   | 1    | NFR-01      | smoke       | cd wattwise_app && flutter test test/feature/profile/contact_support_test.dart            | Yes         | pending |
| 11-02-01 | 02   | 2    | NFR-03      | integration | npm --prefix backend test -- --runInBand                                                  | Yes         | pending |
| 11-02-02 | 02   | 2    | NFR-01      | integration | cd wattwise_app && flutter test                                                           | Yes         | pending |
| 11-03-01 | 03   | 3    | NFR-03      | evidence    | grep -n "Status" .planning/phases/11-reliability-and-milestone-closure/11-VERIFICATION.md | pending     | pending |

## Validation Sign-Off

- [ ] All tasks have automated verify or explicit evidence checks
- [ ] Fast and full loops executed and captured
- [ ] UAT closure evidence linked
- [ ] nyquist_compliant set true before phase completion

Approval: pending
