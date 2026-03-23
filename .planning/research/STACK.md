# Stack Research

**Domain:** Production-grade collaborative multi-agent orchestration for WattWise backend v2.0
**Researched:** 2026-03-23
**Confidence:** MEDIUM-HIGH

## Recommended Stack

### Core Technologies

| Technology                               | Version                                     | Purpose                                                             | Why Recommended                                                                                                                                                              |
| ---------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Node.js + Express (existing)             | Keep current runtime + express@5.2.1        | API entrypoint and controller integration                           | Preserves existing backend contract and avoids migration risk while adding collaborative orchestration behind current endpoints.                                             |
| LangGraph (existing, keep)               | @langchain/langgraph@1.2.5                  | Multi-agent orchestration runtime                                   | Already integrated in the linear Analyst -> Strategist -> Copywriter pipeline; supports persistence, memory, and durable execution patterns required for collaborative mode. |
| Redis-backed LangGraph persistence (new) | @langchain/langgraph-checkpoint-redis@1.0.4 | Durable checkpoints + shared memory store for multi-agent workspace | Purpose-built checkpointer/store for LangGraph; enables thread continuity, cross-step recovery, and shared workspace memory without replacing core orchestration.            |

### Supporting Libraries

| Library                                   | Version | Purpose                                                            | When to Use                                                                                                                                    |
| ----------------------------------------- | ------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| @langchain/langgraph-checkpoint           | 1.0.1   | Checkpointer interfaces/types and memory saver compatibility layer | Keep as base dependency and use in tests or local fallback checkpointer flows.                                                                 |
| cockatiel                                 | 3.2.1   | Resilience policies: retry, timeout, circuit breaker, bulkhead     | Wrap external model calls and any remote tool/API calls in strategist/copywriter/debate nodes for graceful degradation and controlled retries. |
| @opentelemetry/api                        | 1.9.0   | Tracing API contracts across modules                               | Use to instrument orchestration steps, debate rounds, and quality gate decisions with trace IDs.                                               |
| @opentelemetry/sdk-node                   | 0.213.0 | Node telemetry SDK                                                 | Initialize once at app bootstrap to emit traces/metrics for collaborative pipeline execution.                                                  |
| @opentelemetry/auto-instrumentations-node | 0.71.0  | Automatic instrumentation for Express/HTTP and common libs         | Use for low-friction baseline telemetry before adding custom spans for agent/debate semantics.                                                 |
| @opentelemetry/exporter-trace-otlp-http   | 0.213.0 | OTLP trace export                                                  | Use in production to send traces to your APM/collector backend.                                                                                |
| @opentelemetry/exporter-metrics-otlp-http | 0.213.0 | OTLP metrics export                                                | Use when central metrics backend is available and you want unified OTEL pipeline.                                                              |
| prom-client                               | 15.1.3  | Prometheus counters/histograms/gauges                              | Expose milestone-critical SLI metrics: consensus pass rate, quality score distribution, retry counts, gate failures, and latency by node.      |
| pino                                      | 10.3.1  | Structured JSON logging                                            | Add for machine-parseable production logs linked with trace/span IDs.                                                                          |
| pino-http                                 | 11.0.0  | HTTP request log middleware for Express                            | Replace or phase out morgan in collaborative routes first, then broaden across API when stable.                                                |
| supertest                                 | 7.2.2   | HTTP integration testing for Express routes                        | Add route-level tests covering backward-compatible behavior and new collaborative mode toggles.                                                |
| testcontainers                            | 11.13.0 | Real dependency integration tests (Redis, optionally Mongo) in CI  | Use for production-like persistence/resilience tests (checkpoint recovery, thread memory continuity, restart behavior).                        |
| nock                                      | 14.0.11 | Deterministic mocking of outbound HTTP/LLM calls in tests          | Use to test debate/consensus/quality gate edge cases without flaky live model calls.                                                           |

### Development Tools

| Tool                                     | Purpose                                       | Notes                                                                                                            |
| ---------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Jest (existing)                          | Test runner and assertions                    | Keep current Jest setup and add dedicated suites for collaborative graph flows and resilience behavior.          |
| ESLint (existing)                        | Static quality checks                         | Keep current lint flow; add rules only if needed for new observability/testing files.                            |
| LangSmith tracing (optional integration) | Deep graph trace visualization and evaluation | Useful for development and tuning; do not make it a hard production dependency if policy/cost constraints apply. |

## Installation

```bash
# Core collaborative persistence + resilience + observability
npm install @langchain/langgraph-checkpoint-redis cockatiel \
  @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node \
  @opentelemetry/exporter-trace-otlp-http @opentelemetry/exporter-metrics-otlp-http \
  prom-client pino pino-http

# Testing additions
npm install -D supertest testcontainers nock
```

## Where Each Choice Applies

| Capability                                      | Recommended Library Choice                                                                    | Apply In                                                                                                                  |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Persistent workspace memory + thread continuity | @langchain/langgraph-checkpoint-redis (RedisSaver + RedisStore)                               | New collaborative graph compile path and runtime config, parallel to existing linear path.                                |
| Debate protocol + consensus voting              | No new framework; implement as LangGraph nodes/subgraph patterns with existing zod validation | New debate/cross-review nodes in efficiency planning subsystem only.                                                      |
| Quality gates                                   | zod (existing) + custom scoring module + prom-client metrics                                  | Gate node before final publication; enforce >=85 threshold and publish reason codes/metrics.                              |
| Observability                                   | OpenTelemetry + prom-client + pino                                                            | App bootstrap (telemetry init), middleware layer (HTTP traces/logs), agent nodes (manual spans + quality/debate metrics). |
| Resilience/error recovery                       | cockatiel + LangGraph checkpoint replay/restart                                               | Around outbound model/tool calls and around graph invocation boundary for retry/recovery.                                 |
| Production-grade integration tests              | Jest + supertest + testcontainers + nock                                                      | Backend tests folder; add CI-friendly suites for fault-injection and memory persistence.                                  |

## Backward Compatibility Plan (Must Keep Unchanged)

| Keep Unchanged                                                         | Why                                                                                |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Existing linear graph entrypoint and exports in efficiency plan module | Prevents controller/API breakage and allows staged rollout via feature flag.       |
| Existing state channels used by current nodes                          | Maintains compatibility with current analyst/strategist/copywriter node contracts. |
| Existing Express routes/controller contract                            | Avoids frontend/mobile/API client changes during architecture evolution.           |
| Existing Redis and Mongo foundations (ioredis, mongoose)               | Reuses known infra and operational patterns; no datastore migration required.      |

## Alternatives Considered

| Recommended                           | Alternative                              | When to Use Alternative                                                                                                                 |
| ------------------------------------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| @langchain/langgraph-checkpoint-redis | @langchain/langgraph-checkpoint-postgres | Use Postgres saver if your org has stronger Postgres ops maturity than Redis Stack modules.                                             |
| cockatiel                             | p-retry                                  | Use p-retry only for very simple retry-only wrappers; cockatiel is better for circuit breaker + timeout + bulkhead in one policy model. |
| OpenTelemetry + prom-client           | vendor-specific APM SDK only             | Use vendor SDK directly only if your org is fully locked into one APM and avoids OTEL standardization.                                  |

## What NOT to Use

| Avoid                                                                    | Why                                                                                                                               | Use Instead                                                                                                  |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Replacing LangGraph with a new orchestration framework in this milestone | High migration risk and unnecessary churn; current stack already supports required capabilities with persistence add-ons.         | Keep LangGraph and add Redis checkpointer/store plus new collaborative nodes.                                |
| Introducing Kafka/NATS for intra-graph coordination now                  | Adds operational complexity before proving product value; not required for v2.0 collaborative behavior in single backend service. | Use LangGraph state + Redis checkpoint/store first; revisit message bus only after proven scale bottlenecks. |
| Moving tests to a new test runner                                        | Tool churn without clear milestone benefit; Jest already in place.                                                                | Keep Jest and add supertest/testcontainers/nock suites.                                                      |
| Adding multiple logging stacks simultaneously                            | Duplicative logs and operational noise.                                                                                           | Standardize on pino JSON logs and phase out morgan gradually.                                                |

## Stack Patterns by Variant

**If rollout needs strict safety:**

- Keep legacy linear execution as default.
- Add collaborative graph behind a feature flag per request/tenant.
- Write to the same API response shape.

**If high throughput starts stressing synchronous request path:**

- Keep orchestration logic unchanged.
- Add BullMQ@5.71.0 only for asynchronous plan generation jobs and retries.
- Expose polling/webhook status to avoid long HTTP blocking.

## Version Compatibility

| Package A                                   | Compatible With                                       | Notes                                                                                                 |
| ------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| @langchain/langgraph@1.2.5                  | @langchain/langgraph-checkpoint@1.0.1                 | Base checkpointer APIs aligned with current LangGraph generation.                                     |
| @langchain/langgraph@1.2.5                  | @langchain/langgraph-checkpoint-redis@1.0.4           | Production Redis saver/store available and current.                                                   |
| @langchain/langgraph-checkpoint-redis@1.0.4 | Redis 8+ (or Redis Stack with RedisJSON + RediSearch) | Critical infrastructure requirement; validate before rollout.                                         |
| @opentelemetry/sdk-node@0.213.0             | @opentelemetry/api@1.9.0                              | Keep OTEL package family versions aligned to avoid instrumentation mismatch.                          |
| pino@10.3.1                                 | pino-http@11.0.0                                      | Standard pairing for structured service + request logs.                                               |
| jest@30.x                                   | supertest@7.2.2, testcontainers@11.13.0               | Works for Node backend integration tests; ensure Docker availability in CI for testcontainers suites. |

## Integration Rationale and Churn Control

1. Preserve existing orchestration shape and add a parallel collaborative graph path.
2. Prefer additive dependencies over replacements (checkpointing, telemetry, resilience, tests).
3. Reuse existing Redis presence to avoid new infrastructure category.
4. Keep API/controller contracts unchanged and enforce compatibility via supertest regression tests.
5. Defer heavyweight distributed systems additions unless telemetry proves a scaling need.

## Sources

- https://docs.langchain.com/oss/javascript/langgraph/overview - LangGraph orchestration and durability positioning (HIGH)
- https://docs.langchain.com/oss/javascript/langgraph/persistence - threads, checkpoints, store, production checkpointer options (HIGH)
- https://www.npmjs.com/package/@langchain/langgraph-checkpoint-redis - Redis saver/store capabilities and Redis module requirements (MEDIUM-HIGH)
- https://opentelemetry.io/docs/languages/js/getting-started/nodejs/ - Node OTEL setup and auto-instrumentation guidance (HIGH)
- https://github.com/siimon/prom-client - Prometheus metrics client capabilities (MEDIUM)
- https://github.com/connor4312/cockatiel - resilience policy support (retry/circuit breaker/timeout/bulkhead) (MEDIUM)
- https://www.npmjs.com/package/testcontainers - Node testcontainers package availability/current version (MEDIUM)
- https://jestjs.io/docs/getting-started - Jest baseline guidance and compatibility context (HIGH)
- npm registry version checks executed on 2026-03-23 for package pin recommendations (HIGH)

---

_Stack research for: WattWise backend milestone v2.0 collaborative multi-agent system_
_Researched: 2026-03-23_
