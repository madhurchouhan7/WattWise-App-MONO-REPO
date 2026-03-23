---
phase: 1
plan: 2
wave: 2
depends_on: ["1.1"]
files_modified: ["backend/src/agents/efficiency_plan/analyst.node.js", "backend/src/agents/efficiency_plan/strategist.node.js", "backend/src/agents/efficiency_plan/copywriter.node.js", "backend/src/agents/efficiency_plan/index.js"]
autonomous: true

must_haves:
  truths:
    - "Graph nodes export async functions taking State and returning partial state updates"
    - "Central `index.js` connects nodes and compiles the StateGraph"
  artifacts:
    - "backend/src/agents/efficiency_plan/index.js"
---

# Plan 1.2: Graph Nodes Boilerplate & Index Compilation

<objective>
To fully set up the skeleton of the sequential LangGraph pipeline. Create placeholder nodes for the three agents (Analyst, Strategist, Copywriter) and an `index.js` that orchestrates them into a `@langchain/langgraph` `StateGraph`, connecting `START` to `Analyst`, then `Strategist`, then `Copywriter`, then `END`.

Purpose: By compiling a complete but empty graph, we lock in the structural routing and allow subsequent phases to focus purely on prompt optimization and LLM API integration.
Output: Three node files and the compiled graph index.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/src/agents/efficiency_plan/state.js
</context>

<tasks>

<task type="auto">
  <name>Create Placeholder Nodes</name>
  <files>
    backend/src/agents/efficiency_plan/analyst.node.js,
    backend/src/agents/efficiency_plan/strategist.node.js,
    backend/src/agents/efficiency_plan/copywriter.node.js
  </files>
  <action>
    Create the three `.node.js` files. Give each file a dummy exported async function named `runAnalyst`, `runStrategist`, and `runCopywriter` respectively. 
    Each node function should log its execution to the console to prove the sequential relay works. 
    Each must return a mock updated state. 
    `analyst.node.js` -> return { anomalies: [{ id: "mock_anomaly" }] }
    `strategist.node.js` -> return { strategies: [{ action: "mock_strategy" }] }
    `copywriter.node.js` -> return { finalPlan: { mock_key: "mock_data" } }
  </action>
  <verify>ls backend/src/agents/efficiency_plan/*.node.js</verify>
  <done>The three node files exist and export default async functions representing the state modifier.</done>
</task>

<task type="auto">
  <name>Compile Graph Application</name>
  <files>backend/src/agents/efficiency_plan/index.js</files>
  <action>
    Create the graph compiler. 
    Import `StateGraph`, `START`, and `END` from `@langchain/langgraph`.
    Import `StateAnnotation` from `./state.js`.
    Import the three dummy node functions.
    Construct the workflow:
    `const workflow = new StateGraph(StateAnnotation)`
    Add the nodes via `workflow.addNode()`.
    Add edges: `START -> Analyst -> Strategist -> Copywriter -> END`.
    Compile the graph: `const app = workflow.compile(); export default app`.
    
    AVOID: Any actual LLM logic here. `index.js` is merely the router. Ensure it returns a compiled LangGraph app that can be globally executed via `app.invoke(...)`.
  </action>
  <verify>node -v ; node -e "require('./backend/src/agents/efficiency_plan/index.js')"</verify>
  <done>The graph compiler loads successfully without syntax errors, exporting the complied app.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] You can import the compiled graph without runtime or syntax errors.
- [ ] The directed edges strictly enforce the flow sequence mandated in `SPEC.md`.
</verification>

<success_criteria>
- [ ] All 4 artifacts created.
- [ ] All tasks verified
- [ ] Must-haves confirmed
</success_criteria>
