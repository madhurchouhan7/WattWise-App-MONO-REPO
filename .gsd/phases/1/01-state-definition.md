---
phase: 1
plan: 1
wave: 1
depends_on: []
files_modified: ["backend/package.json", "backend/src/agents/efficiency_plan/state.js"]
autonomous: true

must_haves:
  truths:
    - "LangGraph and related Langchain packages are installed in the backend"
    - "The State object fully defines the input, intermediary outputs, and final response of the graph"
  artifacts:
    - "backend/src/agents/efficiency_plan/state.js"
---

# Plan 1.1: Dependency Installation & State Definition

<objective>
Install `@langchain/langgraph` and `@langchain/core` which are required for managing State and constructing the multi-agent graph. Then, define the precise State Channel object that will pass data sequentially from `START -> Analyst -> Strategist -> Copywriter -> END`.

Purpose: The State is the core schema for the LangGraph workflow; it dictates how nodes share information without mutating global state.
Output: Project dependencies updated and a `state.js` module.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/package.json
</context>

<tasks>

<task type="auto">
  <name>Install LangGraph Packages</name>
  <files>backend/package.json</files>
  <action>
    Run `npm install @langchain/langgraph @langchain/core` inside the `backend/` directory.
    AVOID: installing them in the monorepo root because the backend is an isolated Node application.
  </action>
  <verify>cat backend/package.json | grep "@langchain/langgraph"</verify>
  <done>The LangGraph packages are present in backend dependencies.</done>
</task>

<task type="auto">
  <name>Define Graph State Object</name>
  <files>backend/src/agents/efficiency_plan/state.js</files>
  <action>
    Create a new file exporting a `StateAnnotation` (using `Annotation.Root` from `@langchain/langgraph`).
    Define the following properties:
    - `userData`: Object (Input - appliances, bill data, MongoDB tariffs)
    - `weatherContext`: String (Input - OpenWeather snapshot)
    - `anomalies`: Array (Output from Data Analyst - JSON list of physical anomalies)
    - `strategies`: Array (Output from Strategist - JSON list of high-ROI actions)
    - `finalPlan`: Object (Output from Copywriter - final JSON formatted for Flutter)
    
    AVOID: Adding methods to the state. It should be a pure schema/annotation for data flow. Ensure each property has a default reducer if necessary, or just use `Annotation.Root({ ... })` with standard setup. Note: In JavaScript LangGraph, define the state using `Annotation.Root({ prop: Annotation() })` where `Annotation` is imported from `@langchain/langgraph`.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/state.js</verify>
  <done>The file compiles successfully and exports StateAnnotation.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `@langchain/langgraph` is in `backend/package.json`.
- [ ] `state.js` correctly exposes the `StateAnnotation` object with `userData`, `weatherContext`, `anomalies`, `strategies`, and `finalPlan`.
</verification>

<success_criteria>
- [ ] All tasks verified
- [ ] Must-haves confirmed
</success_criteria>
