# REQUIREMENTS.md

## Functional Requirements
| ID | Requirement | Source | Status |
|----|-------------|--------|--------|
| REQ-01 | **LangGraph Orchestration**: Implement a sequential graph (`START` -> `Analyst` -> `Strategist` -> `Copywriter` -> `END`). | SPEC Goal 5 | Pending |
| REQ-02 | **Data Analyst Node (DeepSeek-R1)**: Strictly performs math, calculates bill tariffs, and flags anomalies using a hardcoded Physics Benchmark. | SPEC Goal 2 | Pending |
| REQ-03 | **Strategist Node (Grok-2)**: Generates 3-5 high-impact saving actions based on Analyst's anomalies and weather context. | SPEC Goal 3 | Pending |
| REQ-04 | **Copywriter Node (Gemini Flash)**: Synthesizes data into an empathetic summary and monthly tip. | SPEC Goal 5 | Pending |
| REQ-05 | **Hard Context Injection**: Express controller must fetch MongoDB tariffs and OpenWeather data before graph execution. | SPEC Goal 1 | Pending |
| REQ-06 | **JSON Schema Compliance**: The final Copywriter node must output valid JSON matching the Flutter frontend's expected format. | SPEC Goal 4 | Pending |
| REQ-07 | **Anomaly Grounding**: Analyst node must use the Physics Benchmark JSON in its system prompt as the absolute source of truth. | SPEC Goal 1 | Pending |

## Technical Requirements
| ID | Requirement | Source | Status |
|----|-------------|--------|--------|
| TECH-01 | Use `@langchain/langgraph` for state management in the `backend/src/agents` directory. | Architecture Mandate | Pending |
| TECH-02 | Deploy within a serverless (Google Cloud Run) environment (stateless execution). | Constraint | Pending |
| TECH-03 | Ensure all LLM calls use the prescribed models (DeepSeek, Grok, Gemini). | Architecture Mandate | Pending |
| TECH-04 | Map the `src/agents/efficiency_plan/` directory with separate files for each node. | Architecture Mandate | Pending |
