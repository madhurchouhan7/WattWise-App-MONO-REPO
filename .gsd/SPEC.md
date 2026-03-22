# SPEC.md — Project Specification

> **Status**: `FINALIZED`
> **Project Name**: WattWise Agentic Migration (Multi-Agent LangGraph Workflow)
> **Goal**: Replace the monolithic Gemini LLM prompt with a specialized multi-agent assembly line.

## Vision
Migrate the core energy analysis and plan generation engine from a single, hallucination-prone prompt (Gemini) to a deterministic, high-accuracy LangGraph-powered multi-agent system. By routing specific reasoning tasks to DeepSeek-R1 (Math/Logic), Grok-2 (Strategy), and Gemini Flash (Formatting), we aim to provide 100% mathematically accurate billing advice and biologically/physically sound energy-saving recommendations for Indian households.

## Goals
1.  **Eliminate Hallucinations**: Prevent "impossible" advice (e.g., cooling usage when it's temperate) by using hard context (weather, tariffs) and specialized LLMs.
2.  **Mathematical Accuracy**: Use DeepSeek-R1's chain-of-thought to calculate exact domestic slab-rate costs based on hard-injected tariff data from MongoDB.
3.  **Specialized Reasoning**: Leverages Grok-2 for blunt, practical strategy generation that avoids high-friction advice.
4.  **Schema Compliance**: Ensure the final output perfectly matches the Flutter frontend's required JSON schema using Gemini Flash's formatting strengths.
5.  **Agentic State Management**: Use `langgraph` state objects to relay context sequentially, enabling a clean, serverless execution on Google Cloud Run.

## Non-Goals (Out of Scope)
- Making live API calls from within the LangGraph nodes (keep context injection pure).
- Redesigning the Flutter UI (maintain existing data consumption patterns).
- Adding multi-user collaboration to energy plans.
- Migrating the entire backend to a new framework.

## Users
Existing WattWise mobile app users who rely on the "AI Efficiency Plan" to manage their energy bills and appliance usage.

## Constraints
- **Technical**: Must use `@langchain/langgraph` on Node.js.
- **Environment**: Deployment on Google Cloud Run (no local file system persistence during inference).
- **Latency**: Each generation cycle should ideally complete within 10-15 seconds (DeepSeek-R1 reasoning can be slow).
- **Hard Context**: Weather and tariffs MUST be injected by the controller, never inferred by LLMs.

## Architectural Mandates
- **Directory Structure**: `backend/src/agents/efficiency_plan/` will contain all agents and the graph definition.
- **Physics Benchmark**: The Analyst node's system prompt must include a hardcoded JSON dictionary of standard Indian domestic appliance physics (e.g., `Washing Machine max 2 hrs/day`).
- **Model Routing**: 
    - `analyst.node.js` -> DeepSeek-R1 (Logic / Math)
    - `strategist.node.js` -> Grok-2 (Strategy / Weather-aware actions)
    - `copywriter.node.js` -> Gemini Flash (Presentation / JSON)

## Success Criteria
- [ ] 0% Hallucinations on "impossible" appliance usage flags.
- [ ] 100% Matching between LLM-calculated costs and ground-truth Slab-Rate math.
- [ ] Generated plans successfully render in the Flutter app without parsing errors.
- [ ] LangGraph state correctly passes information from Node 1 to Node 3.
- [ ] Legacy `gemini.service.js` is deprecated and unused.
