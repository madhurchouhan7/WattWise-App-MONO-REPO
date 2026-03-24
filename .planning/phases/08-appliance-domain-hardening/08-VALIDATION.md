---
phase: 8
slug: appliance-domain-hardening
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-24
---

# Phase 8 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property               | Value                                                                         |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Framework**          | jest 30.x + flutter test                                                      |
| **Config file**        | backend/package.json, wattwise_app/pubspec.yaml                               |
| **Quick run command**  | `npm --prefix backend test -- --runInBand tests/appliance.contract.test.js`   |
| **Full suite command** | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |
| **Estimated runtime**  | ~120 seconds                                                                  |

---

## Sampling Rate

- **After every task commit:** Run `npm --prefix backend test -- --runInBand tests/appliance.contract.test.js`
- **After every plan wave:** Run `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID  | Plan | Wave | Requirement | Test Type          | Automated Command                                                                              | File Exists | Status     |
| -------- | ---- | ---- | ----------- | ------------------ | ---------------------------------------------------------------------------------------------- | ----------- | ---------- |
| 08-01-01 | 01   | 1    | APP-01      | integration        | `npm --prefix backend test -- --runInBand --testPathPatterns appliance`                        | ⚠️ W0       | ⬜ pending |
| 08-01-02 | 01   | 1    | APP-02      | integration        | `npm --prefix backend test -- --runInBand --testPathPatterns appliance`                        | ⚠️ W0       | ⬜ pending |
| 08-03-01 | 03   | 3    | APP-03      | widget/integration | `cd wattwise_app && flutter test test/feature/profile/manage_appliances_delete_flow_test.dart` | ⚠️ W0       | ⬜ pending |
| 08-02-02 | 02   | 2    | APP-04      | integration        | `npm --prefix backend test -- --runInBand tests/appliance.concurrency.contract.test.js`        | ⚠️ W0       | ⬜ pending |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

---

## Wave 0 Requirements

- [ ] `backend/tests/appliance.contract.test.js` - deterministic create/update/delete contract tests
- [ ] `backend/tests/appliance.concurrency.contract.test.js` - stale-write/conflict behavior tests
- [ ] `backend/tests/appliance.validation.test.js` - schema and field-error envelope tests
- [ ] `wattwise_app/test/feature/profile/manage_appliances_retry_states_test.dart` - loading/error/retry state handling
- [ ] `wattwise_app/test/feature/profile/manage_appliances_delete_flow_test.dart` - delete confirmation + immediate refresh behavior

---

## Manual-Only Verifications

| Behavior                                                            | Requirement | Why Manual                                                       | Test Instructions                                                                                               |
| ------------------------------------------------------------------- | ----------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Delete flow confirms and immediately updates appliance list         | APP-03      | UX timing and confirmation affordance are interaction-sensitive  | Open Manage Appliances, delete one appliance, confirm dialog, verify immediate list update and success feedback |
| Concurrent edit from second session triggers safe conflict handling | APP-04      | Multi-session workflow is hard to fully simulate in widget tests | Open same appliance in two sessions, save first then second, verify conflict and recovery guidance              |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
