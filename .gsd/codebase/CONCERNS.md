# Codebase Concerns
**Analysis Date: 2026-03-22**

## Tech Debt

**Data Migration:**
- Issue: The `migrateUserData.js` script supports an `AUTO_CLEANUP` mode which deletes embedded data after migration.
- Files: `backend/scripts/migrateUserData.js`, `backend/MIGRATION_GUIDE.md`
- Impact: Potential data loss if the migration fails or if the script is run without verified backups.
- Fix approach: Implement a dry-run mode and mandatory backup verification step in the script.

**Debug Logging:**
- Issue: Raw OCR text is logged to the console with a TODO to remove it.
- Files: `wattwise_app/lib/feature/bill/providers/ocr_provider.dart`
- Impact: Potential exposure of PII (Personally Identifiable Information) in production logs if not removed.
- Fix approach: Replace with a conditional logging flag or use a structured logging framework that scrubs sensitive data.

**Rate Limiting Fallback:**
- Issue: `rateLimit.middleware.js` falls back to a memory store if Redis is unavailable.
- Files: `backend/src/middleware/rateLimit.middleware.js`
- Impact: Inconsistent rate limits across multiple API instances (containers/serverless) if Redis fails, potentially allowing bypasses.
- Fix approach: Ensure Redis is a hard dependency for production or implement a more robust fallback mechanism with alerts.

## Performance Bottlenecks

**LLM Reasoning Latency:**
- Problem: DeepSeek-R1 reasoning time may exceed default serverless timeouts.
- Files: `.gsd/STATE.md`, `backend/src/agents/efficiency_plan/`
- Cause: Complexity of reasoning models and network latency.
- Improvement path: Implement asynchronous task processing (e.g., via BullMQ or similar) instead of waiting for the response in the HTTP request cycle.

## Fragile Areas

**OCR Extraction Logic:**
- Files: `wattwise_app/lib/feature/bill/providers/ocr_provider.dart`
- Why fragile: Uses basic regex `RegExp(r'([\d,]+\.\d+|[\d,]+)')` to extract numbers from OCR text. This is highly dependent on the bill format and OCR accuracy.
- Safe modification: Transition to a more robust parsing strategy or use the LLM to structure the OCR output (as hinted in the agent architecture).

**AI/Frontend Schema Alignment:**
- Files: `.gsd/STATE.md`
- Why fragile: Gemini Flash outputs must match Flutter frontend expectations exactly. Any variance in the AI response schema can crash the frontend parsing.
- Safe modification: Use Zod or similar validation on the backend to "fix" or validate AI responses before sending them to the Flutter client.

## Dependencies at Risk

**Express 5.x:**
- Risk: Using `express@^5.2.1` which is a major shift from the stable 4.x line.
- Impact: Potential instability or breaking changes as the 5.x ecosystem matures.
- Migration plan: Monitor stability and keep middleware updated, as many community middlewares were designed for 4.x.
