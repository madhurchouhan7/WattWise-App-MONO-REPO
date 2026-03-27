---
phase: 7
slug: contract-freeze-and-profile-wiring
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 7 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property               | Value                                                                         |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Framework**          | jest 30.x + flutter test                                                      |
| **Config file**        | backend/package.json, wattwise_app/pubspec.yaml                               |
| **Quick run command**  | `npm --prefix backend test -- --runInBand --testPathPatterns profile`         |
| **Full suite command** | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` |
| **Estimated runtime**  | ~180 seconds                                                                  |

---

## Sampling Rate

- **After every task commit:** Run `npm --prefix backend test -- --runInBand --testPathPatterns profile`
- **After every plan wave:** Run `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID  | Plan | Wave | Requirement | Test Type   | Automated Command                                                             | File Exists | Status     |
| -------- | ---- | ---- | ----------- | ----------- | ----------------------------------------------------------------------------- | ----------- | ---------- |
| 07-01-01 | 01   | 1    | PRO-01      | integration | `npm --prefix backend test -- --runInBand --testPathPatterns profile`         | ⚠️ W0       | ⬜ pending |
| 07-01-02 | 01   | 1    | PRO-02      | integration | `npm --prefix backend test -- --runInBand --testPathPatterns profile`         | ⚠️ W0       | ⬜ pending |
| 07-02-01 | 02   | 1    | PRO-03      | unit        | `cd wattwise_app && flutter test test/feature/profile`                        | ⚠️ W0       | ⬜ pending |
| 07-02-02 | 02   | 1    | PRO-04      | integration | `npm --prefix backend test -- --runInBand && cd wattwise_app && flutter test` | ⚠️ W0       | ⬜ pending |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

---

## Wave 0 Requirements

- [ ] `backend/tests/profile.contract.test.js` - contract tests for GET/PUT `/users/me`
- [ ] `backend/tests/profile.validation.test.js` - update payload schema error-path tests
- [ ] `wattwise_app/test/feature/profile/edit_profile_provider_test.dart` - provider state transitions
- [ ] `wattwise_app/test/feature/profile/edit_profile_screen_test.dart` - form validation and save states

---

## Manual-Only Verifications

| Behavior                                                    | Requirement | Why Manual                                              | Test Instructions                                                                        |
| ----------------------------------------------------------- | ----------- | ------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Profile menu routes to Edit Profile flow from ProfileScreen | PRO-01      | Navigation + animation timing is UX-sensitive in-device | Launch app, open Profile, tap Edit Profile, confirm route opens and initial data appears |
| Successful profile save reflects after app restart          | PRO-04      | Requires device lifecycle and persisted auth context    | Edit profile, save, restart app, re-open profile, verify persisted values                |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
