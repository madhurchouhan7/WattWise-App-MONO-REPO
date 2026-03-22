# DECISIONS.md

> **Project DECISIONS (ADR)**

| ID | Decision | Rationale | Date | Status |
|----|----------|-----------|------|--------|
| ADR-01 | Use LangGraph for orchestrating nodes. | Sequential, serverless-ready state management across multiple LLMs. | 2026-03-22 | ACCEPTED |
| ADR-02 | Route math/logic tasks to DeepSeek-R1. | Superior reasoning/chain-of-thought for mathematical anomaly detection. | 2026-03-22 | ACCEPTED |
| ADR-03 | Route strategy to Grok-2. | Fast, blunt, and capable reasoning for practical saving advice. | 2026-03-22 | ACCEPTED |
| ADR-04 | Pre-inject weather and tariffs via controller. | Ensures the graph remains deterministic and avoids internal model API calls. | 2026-03-22 | ACCEPTED |
| ADR-05 | System prompt-based Physics Benchmark. | Eliminates reliance on internal LLM training data for household physics. | 2026-03-22 | ACCEPTED |
