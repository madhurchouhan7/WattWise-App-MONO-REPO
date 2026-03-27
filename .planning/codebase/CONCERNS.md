# Codebase Concerns

**Analysis Date:** 2026-03-23

## Tech Debt

**Auth & Account Recovery Flows (Backend):**
- Issue: Email verification and password reset methods are placeholder implementations that return success-like responses without performing token verification, email dispatch, or password updates.
- Files: `backend/src/services/UserService.js`, `backend/src/controllers/user.controller.js`
- Impact: User-facing auth flows can report success while account state remains unchanged, creating trust, support, and security issues.
- Fix approach: Replace placeholder methods with real token lifecycle and password-reset logic (token issuance, hashing/storage, expiry checks, invalidation, and audit logs). Add negative-path tests for invalid/expired/reused tokens.

**Health/Metrics Reliability:**
- Issue: Health checks include mock disk usage values and metrics endpoints that return hard-coded zeros for operational counters.
- Files: `backend/src/controllers/health.controller.js`
- Impact: Monitoring can show healthy/degraded states that do not represent real system health, delaying incident detection.
- Fix approach: Replace mock disk logic with actual filesystem metrics, wire active connections/request rate/error rate to real instrumentation, and add contract tests for health endpoints.

**Product Logic Backed by Mock Defaults (Flutter):**
- Issue: Multiple providers/screens use baseline/mock values and fallback assumptions in production code paths.
- Files: `wattwise_app/lib/feature/insights/providers/insights_provider.dart`, `wattwise_app/lib/feature/bill/widgets/current_cycle_card.dart`, `wattwise_app/lib/feature/dashboard/screens/dashboard_screen.dart`
- Impact: Users can see inaccurate consumption/cost insights and confidence signals detached from actual bill data.
- Fix approach: Gate placeholder data behind explicit dev flags, enforce null-safe empty states in UI, and show data quality indicators when inferred values are used.

**AI Plan Pipeline Fallbacks:**
- Issue: Agent nodes fall back to mock anomalies/strategies/content when provider API keys are absent or requests fail.
- Files: `backend/src/agents/efficiency_plan/analyst.node.js`, `backend/src/agents/efficiency_plan/strategist.node.js`, `backend/src/agents/efficiency_plan/copywriter.node.js`
- Impact: Generated plans may look valid while being synthetic, reducing user trust and making QA results inconsistent between environments.
- Fix approach: Mark fallback-originated output explicitly, make fallback mode opt-in, and emit structured telemetry so dashboards can distinguish real vs mock plans.

## Known Bugs

**Password Reset and Email Verification Return Success Without State Change:**
- Symptoms: Endpoints can return success messages even when no reset/verification business logic is executed.
- Files: `backend/src/services/UserService.js`, `backend/src/controllers/user.controller.js`
- Trigger: Call verify/reset endpoints with any token-like value; service methods currently return placeholders.
- Workaround: Not applicable for production correctness; requires implementation of real token flows.

**Silent Error Swallowing in Client Data Paths:**
- Symptoms: UI silently falls back to stale/default data when exceptions occur, with no user-visible warning.
- Files: `wattwise_app/lib/feature/auth/repository/auth_repository.dart`, `wattwise_app/lib/feature/bill/providers/fetch_bill_provider.dart`, `wattwise_app/lib/feature/bill/widgets/current_cycle_card.dart`, `wattwise_app/lib/feature/notifications/providers/notification_provider.dart`
- Trigger: Network failures, parse failures, or cached payload corruption in try/catch blocks using `catch (_) {}`.
- Workaround: Restart app or re-trigger refresh; failures remain opaque to users and support.

**Unfinished Navigation Actions in Insights:**
- Symptoms: Tapping expected CTAs does not navigate to intended flows.
- Files: `wattwise_app/lib/feature/insights/widgets/subsidy_section_widget.dart`, `wattwise_app/lib/feature/insights/widgets/upgrade_card_widget.dart`
- Trigger: Use the related UI actions where TODO markers indicate missing routes.
- Workaround: None in-app.

## Security Considerations

**Credential Artifact Present in Source Tree:**
- Risk: A Firebase service account JSON file exists inside the backend config directory.
- Files: `backend/config/wattwise-firebase-adminsdk.json`, `backend/config/firebase.js`
- Current mitigation: Alternate environment-variable credential path exists in code.
- Recommendations: Remove credential file from tracked source, rotate keys, enforce secret scanning in CI, and load credentials from secure secret managers only.

**Potential Token/PII Exposure in Client Logs:**
- Risk: FCM token logging and verbose Dio request/response body logging can expose sensitive payloads in device logs.
- Files: `wattwise_app/lib/main.dart`, `wattwise_app/lib/core/network/api_client.dart`
- Current mitigation: None detected beyond standard exception handling.
- Recommendations: Disable verbose body logging for release builds, redact sensitive fields centrally, and remove token logging entirely.

**Permissive CORS Fallback Behavior:**
- Risk: If `ALLOWED_ORIGINS` is empty, CORS callback allows all origins.
- Files: `backend/src/app.js`
- Current mitigation: `ALLOWED_ORIGINS` env can restrict origins when configured.
- Recommendations: Fail closed when allowlist is missing in non-development environments, and add startup validation for required security env vars.

## Performance Bottlenecks

**High-Cost Logging on Hot Paths:**
- Problem: Request/response middleware logs frequently and serializes request bodies/query structures; Flutter client interceptor logs full request/response bodies.
- Files: `backend/src/middleware/logging.middleware.js`, `wattwise_app/lib/core/network/api_client.dart`
- Cause: Verbose structured logging enabled broadly without environment gating by payload size/sensitivity.
- Improvement path: Add sampling/size limits, disable body logging in production, and move heavy logging behind debug flags.

**Large Multi-Responsibility Files Increase Change Cost:**
- Problem: Several large service/controller/screen files concentrate many concerns.
- Files: `backend/src/services/UserService.js`, `backend/src/services/CacheService.js`, `backend/src/middleware/logging.middleware.js`, `wattwise_app/lib/feature/dashboard/screens/dashboard_screen.dart`, `wattwise_app/lib/feature/bill/screen/add_bill_screen.dart`, `wattwise_app/lib/feature/plans/screens/active_plan_screen.dart`
- Cause: Feature growth without modular decomposition.
- Improvement path: Split by domain responsibilities, isolate pure utility functions, and enforce max-file-size guardrails in lint/CI.

## Fragile Areas

**OCR Parsing Heuristics:**
- Files: `wattwise_app/lib/feature/bill/providers/ocr_provider.dart`
- Why fragile: Heuristic regex extraction and positional assumptions can break across bill format variations; debug raw-text logging is still present.
- Safe modification: Add snapshot test corpus by biller/template before parser changes; isolate parser rules into testable strategies.
- Test coverage: No parser-specific test suite detected.

**Response Method Monkey-Patching in Middleware:**
- Files: `backend/src/middleware/logging.middleware.js`
- Why fragile: Overriding `res.end` and `res.send` can conflict with other middleware behavior and response streaming semantics.
- Safe modification: Prefer event hooks and framework-supported instrumentation points; add middleware-order tests around streamed/large responses.
- Test coverage: No middleware integration tests detected.

## Scaling Limits

**Rate Limiting Degrades to Process-Local Memory:**
- Current capacity: Stronger limits when Redis is available.
- Limit: On Redis failure/unavailability, memory store is per-process and loses global consistency in multi-instance deployments.
- Scaling path: Make Redis mandatory in production, add health probes/alerts on limiter store mode, and support circuit-breaker behavior when backing store is unavailable.

**Operational Metrics Not Backed by Real Telemetry:**
- Current capacity: Health endpoints respond but include mock/zeroed values for key counters.
- Limit: Autoscaling and incident response cannot rely on endpoint-reported throughput/error metrics.
- Scaling path: Integrate metrics backend (Prometheus/OpenTelemetry or equivalent), expose real counters, and define SLO-based alerts.

## Dependencies at Risk

**External LLM Provider Dependency via Environment Keys:**
- Risk: AI plan quality and behavior depend on third-party APIs and env-key presence; missing keys trigger mock output.
- Impact: Production behavior can silently shift to synthetic responses or reduced functionality.
- Migration plan: Centralize provider health checks, add provider-agnostic abstraction with explicit degraded mode, and introduce contract tests against canned provider responses.

## Missing Critical Features

**End-to-End Auth Recovery Flows:**
- Problem: Full verify-email and reset-password lifecycle is not implemented server-side.
- Blocks: Reliable account recovery, secure user lifecycle operations, and compliance-grade authentication behavior.

**Meaningful Automated Test Suite:**
- Problem: Backend and Flutter tests are currently sanity checks only.
- Blocks: Safe refactoring of complex modules and confidence in release quality.

## Test Coverage Gaps

**Backend Core Business Flows Untested:**
- What's not tested: Auth recovery, rate limiting behavior, middleware order/interactions, repository/service edge cases.
- Files: `backend/tests/sanity.test.js`, `backend/src/services/UserService.js`, `backend/src/middleware/rateLimit.middleware.js`, `backend/src/middleware/logging.middleware.js`
- Risk: Regressions in security and correctness can ship undetected.
- Priority: High

**Flutter Critical Data and Notification Paths Untested:**
- What's not tested: OCR parsing reliability, provider fallback behavior, notification registration/read-state sync, API interceptor error handling.
- Files: `wattwise_app/test/widget_test.dart`, `wattwise_app/lib/feature/bill/providers/ocr_provider.dart`, `wattwise_app/lib/feature/notifications/providers/notification_provider.dart`, `wattwise_app/lib/core/network/api_client.dart`
- Risk: UI can present stale/inaccurate data and silent failures without automated detection.
- Priority: High

---

*Concerns audit: 2026-03-23*
