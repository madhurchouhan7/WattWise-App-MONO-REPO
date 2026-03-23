---
phase: 2
slug: compatibility-foundation-and-dual-path-routing
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property               | Value                                                             |
| ---------------------- | ----------------------------------------------------------------- |
| **Framework**          | jest 30.3.0                                                       |
| **Config file**        | backend/package.json (jest via npm scripts)                       |
| **Quick run command**  | `cd backend && npm test -- --runInBand tests/ai.compat.*.test.js` |
| **Full suite command** | `cd backend && npm test -- --runInBand`                           |
| **Estimated runtime**  | ~45 seconds                                                       |

---

## Sampling Rate

- **After every task commit:** Run `cd backend && npm test -- --runInBand tests/ai.compat.*.test.js`
- **After every plan wave:** Run `cd backend && npm test -- --runInBand`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type   | Automated Command                                                       | File Exists | Status     |
| ------- | ---- | ---- | ----------- | ----------- | ----------------------------------------------------------------------- | ----------- | ---------- |
| 2-01-01 | 01   | 0    | COMP-01     | integration | `cd backend && npm test -- --runInBand tests/ai.compat.legacy.test.js`  | ❌ W0       | ⬜ pending |
| 2-01-02 | 01   | 0    | COMP-02     | integration | `cd backend && npm test -- --runInBand tests/ai.compat.routing.test.js` | ❌ W0       | ⬜ pending |
| 2-01-03 | 01   | 0    | OPS-03      | integration | `cd backend && npm test -- --runInBand tests/ai.compat.errors.test.js`  | ❌ W0       | ⬜ pending |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

---

## Wave 0 Requirements

- [ ] `backend/tests/ai.compat.legacy.test.js` — legacy mode parity coverage for COMP-01
- [ ] `backend/tests/ai.compat.routing.test.js` — mode resolution matrix coverage for COMP-02
- [ ] `backend/tests/ai.compat.errors.test.js` — centralized error path coverage for OPS-03
- [ ] `backend/tests/helpers/mockOrchestrators.js` — deterministic legacy/collaborative invoke stubs
- [ ] `cd backend && npm install -D supertest` — route-level integration test dependency

---

## Manual-Only Verifications

| Behavior                                   | Requirement      | Why Manual                                                                                                 | Test Instructions                                                                                                                                |
| ------------------------------------------ | ---------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Metadata compatibility with mobile clients | COMP-01, COMP-02 | Existing mobile app compatibility is environment-dependent and may not be fully reproducible in backend CI | Hit `/api/v1/ai/generate-plan` from a staging client and verify legacy clients ignore new metadata fields while plan rendering remains unchanged |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
