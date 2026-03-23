---
phase: 4
plan: 1
wave: 1
depends_on: ["3.1"]
files_modified: ["backend/src/agents/efficiency_plan/copywriter.prompt.js", "backend/src/agents/efficiency_plan/copywriter.node.js", "backend/package.json"]
autonomous: true

must_haves:
  truths:
    - "Copywriter node uses Gemini Flash via @langchain/google-genai"
    - "Final output perfectly mirrors the Mongoose Plan.model.js structure required by Flutter"
    - "Outputs an empathetic summary and monthly tip reflecting the previous agents' work"
  artifacts:
    - "backend/src/agents/efficiency_plan/copywriter.node.js"
    - "backend/src/agents/efficiency_plan/copywriter.prompt.js"
---

# Plan 4.1: The Copywriter (Gemini Flash & JSON Schema formatting)

<objective>
To implement the final layer of the LangGraph pipeline: The Copywriter. Using Gemini 1.5/2.5 Flash, it will read the mathematical anomalies (from DeepSeek) and the strategies (from Grok-2) and assemble them into a cohesive, empathetic JSON structure that exactly matches the `Plan` MongoDB schema `Plan.model.js`.

Purpose: The frontend Flutter app expects a strict schema for rendering the UI. Gemini's strength is fast, reliable JSON formatting and empathetic tone generation.
Output: `copywriter.node.js` successfully outputting the final `finalPlan` state.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/src/models/Plan.model.js
- backend/src/agents/efficiency_plan/state.js
</context>

<tasks>

<task type="auto">
  <name>Install Google GenAI package</name>
  <files>backend/package.json</files>
  <action>
    Run `npm install @langchain/google-genai` inside `backend/` to allow seamless Langchain integration with Gemini for the final node.
    AVOID: using standard axios; stick to the LangGraph/LangChain ecosystem for consistency.
  </action>
  <verify>cat backend/package.json | grep "@langchain/google-genai"</verify>
  <done>Package installed successfully.</done>
</task>

<task type="auto">
  <name>Create Copywriter System Prompt</name>
  <files>backend/src/agents/efficiency_plan/copywriter.prompt.js</files>
  <action>
    Create `copywriter.prompt.js` with a `SystemMessage`.
    Instruct the LLM it is a friendly, empathetic Energy Management Assistant.
    Provide the exact JSON schema it must return. It must map `state.strategies` into the `keyActions` array (adding `priority: "high"|"medium"|"low"` based on `projectedSavings`). It must formulate a `summary`, `efficiencyScore`, `quickWins` and `monthlyTip`.
    Demand strict JSON without markdown wrapping.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/copywriter.prompt.js</verify>
  <done>Prompt file exported and syntactically sound.</done>
</task>

<task type="auto">
  <name>Implement Gemini Node Logic</name>
  <files>backend/src/agents/efficiency_plan/copywriter.node.js</files>
  <action>
    Refactor `copywriter.node.js` using `ChatGoogleGenerativeAI` from `@langchain/google-genai`.
    In `runCopywriter`, collect `state.anomalies`, `state.strategies`, `state.userData`, and `state.weatherContext` into the prompt.
    Call Gemini (`modelName: 'gemini-2.5-flash'`).
    Parse the response and return `{ finalPlan: parsedJson }`.
    In case of failure or if no keys are found, return a robust fallback matching the Mongoose schema.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/copywriter.node.js</verify>
  <done>Node properly parses state and exports the `runCopywriter` function.</done>
</task>

</tasks>

<verification>
- [ ] Ensure `copywriter.node.js` checks for `process.env.GEMINI_API_KEY`.
- [ ] Fallback `finalPlan` matches `Plan.model.js` expected schema formatting.
</verification>

<success_criteria>
- [ ] Tasks applied completely and without syntax errors.
- [ ] Must-haves verified.
</success_criteria>
