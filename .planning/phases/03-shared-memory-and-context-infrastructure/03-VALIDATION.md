---
phase: 3
slug: shared-memory-and-context-infrastructure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Jest 30.x + Supertest 7.2.2 |
| **Config file** | backend/package.json (Jest via npm scripts) |
| **Quick run command** | `cd backend && npm test -- --runInBand tests/sanity.test.js` |
| **Full suite command** | `cd backend && npm test -- --runInBand` |
| **Estimated runtime** | ~70 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd backend && npm test -- --runInBand tests/memory.*.test.js`
- **After every plan wave:** Run `cd backend && npm test -- --runInBand tests/ai.compat.*.test.js tests/memory.*.test.js`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 3-01-01 | 01 | 0 | MEM-01 | integration | `cd backend && npm test -- --runInBand tests/memory.workspace.persistence.test.js` | ❌ W0 | ⬜ pending |
| 3-01-02 | 01 | 0 | MEM-02 | integration | `cd backend && npm test -- --runInBand tests/memory.context.continuity.test.js` | ❌ W0 | ⬜ pending |
| 3-01-03 | 01 | 0 | MEM-03 | unit+integration | `cd backend && npm test -- --runInBand tests/memory.provenance.schema.test.js` | ❌ W0 | ⬜ pending |
| 3-01-04 | 01 | 0 | OPS-02 | integration | `cd backend && npm test -- --runInBand tests/memory.trace.correlation.test.js` | ❌ W0 | ⬜ pending |
| 3-01-05 | 01 | 0 | MEM-02 | unit+integration | `cd backend && npm test -- --runInBand tests/memory.retrieval.budget.test.js` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `backend/tests/memory.workspace.persistence.test.js` — MEM-01 contract coverage
- [ ] `backend/tests/memory.context.continuity.test.js` — MEM-02 continuity coverage
- [ ] `backend/tests/memory.provenance.schema.test.js` — MEM-03 provenance/revision enforcement
- [ ] `backend/tests/memory.trace.correlation.test.js` — OPS-02 trace/log correlation
- [ ] `backend/tests/memory.retrieval.budget.test.js` — D-15/D-16 retrieval budget + fallback
- [ ] `backend/tests/helpers/memoryFixtures.js` — deterministic memory fixtures for ranking/continuity
- [ ] `cd backend && npm install js-tiktoken` — tokenizer dependency for budget-safe retrieval

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Archive storage observability after 30-day retention policy | MEM-01, MEM-02 | Time-window behavior and archive flow may depend on environment schedulers not fully reproducible in fast CI | Run retention/archival job in staging with seeded aged events, verify active keys expire while archive records remain write-only and runtime retrieval excludes archive |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
