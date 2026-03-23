---
phase: 3
plan: 1
wave: 1
depends_on: ["2.1"]
files_modified: ["backend/src/agents/efficiency_plan/strategist.prompt.js", "backend/src/agents/efficiency_plan/strategist.node.js"]
autonomous: true

must_haves:
  truths:
    - "Strategist takes Analyst anomalies and weatherContext to formulate exact actions"
    - "Strategist uses Grok-2 logic via an x.ai compatible OpenAI client"
    - "Returns exclusively a JSON array of specific high-ROI strategies"
  artifacts:
    - "backend/src/agents/efficiency_plan/strategist.node.js"
    - "backend/src/agents/efficiency_plan/strategist.prompt.js"
---

# Plan 3.1: The Strategist (Grok-2)

<objective>
To build the critical reasoning layer that turns mathematical anomalies into highly practical, weather-aware actions for the Indian household using Grok-2.

Purpose: Eliminate friction. If the weather is 45°C, telling the user to "turn off the AC" is awful advice. The Strategist understands human behavior, weather, and the exact rupee impact of the anomaly (calculated by DeepSeek) and generates Blunt, actionable alternatives (e.g., "Set AC to 26°C, run Ceiling Fan").
Output: `strategist.node.js` executing Grok-2.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/src/agents/efficiency_plan/state.js
</context>

<tasks>

<task type="auto">
  <name>Create Strategist Prompt</name>
  <files>backend/src/agents/efficiency_plan/strategist.prompt.js</files>
  <action>
    Create `strategist.prompt.js` with a `SystemMessage` declaring the persona "Expert Home Energy Strategist for Indian households".
    Instruct it to take the mathematical `anomalies` array (output by the Analyst) and the current `weatherContext` string.
    Mandate that the generated advice MUST be practical, low-friction, and blunt. No fluffy language. It must also adopt the `rupeeCostImpact` from the Analyst as the potential savings.
    Require strict JSON array response schema: `[{ id, actionSummary, fullDescription, projectedSavings }]`.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/strategist.prompt.js</verify>
  <done>Prompt is syntactically sound and explicitly demands a JSON array schema.</done>
</task>

<task type="auto">
  <name>Implement Grok-2 Node Logic</name>
  <files>backend/src/agents/efficiency_plan/strategist.node.js</files>
  <action>
    Refactor `strategist.node.js` to use `ChatOpenAI` initialized with the x.ai base URL (`https://api.x.ai/v1`), model `grok-2-latest`, and the `XAI_API_KEY`.
    In `runStrategist`, skip generation if `state.anomalies` is empty, returning `[]` for strategies.
    Otherwise, construct the prompt using the imported System Prompt and a user string containing `state.anomalies` and `state.weatherContext`.
    Parse the response back into the state variable as `{ strategies: parsedJson }`, ensuring proper code-block sanitization.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/strategist.node.js</verify>
  <done>Node properly parses state and exports the `runStrategist` function.</done>
</task>

</tasks>

<verification>
- [ ] Ensure `grok-2-latest` model is configured with the correct baseURL.
- [ ] Node uses `state.weatherContext` correctly in the user message.
</verification>

<success_criteria>
- [ ] Tasks applied without disrupting previous Analyst node code.
- [ ] Must-haves verified.
</success_criteria>
