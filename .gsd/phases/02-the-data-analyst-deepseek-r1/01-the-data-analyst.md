---
phase: 2
plan: 1
wave: 1
depends_on: ["1.2"]
files_modified: ["backend/src/agents/efficiency_plan/analyst.prompt.js", "backend/src/agents/efficiency_plan/analyst.node.js", "backend/package.json"]
autonomous: true

must_haves:
  truths:
    - "Physics Benchmark is strictly defined as JSON within a system prompt"
    - "Analyst uses DeepSeek-R1 logic via a compatible LangChain LLM client or direct Axios call"
    - "Returns exactly an array of structured anomalies detected in the user's dataset"
  artifacts:
    - "backend/src/agents/efficiency_plan/analyst.node.js"
    - "backend/src/agents/efficiency_plan/analyst.prompt.js"
---

# Plan 2.1: The Data Analyst (DeepSeek-R1 & Physics Benchmark)

<objective>
To build the "brain" of the Analyst node. It will take standard user appliance data (`userData`) and evaluate it against a hardcoded "Physics Benchmark" (standard wattages and run-times for typical Indian households). It will also handle raw slab-tariff calculations to append rupee impacts to any discovered anomalies, outputting a strict array of JSON anomalies.

Purpose: Offload deterministic logic and math to DeepSeek-R1, preventing the "Strategist" from making absurd assumptions down the line.
Output: A fully functioning DeepSeek-R1 interaction layer inside `analyst.node.js`.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/src/agents/efficiency_plan/state.js
- backend/package.json
</context>

<tasks>

<task type="auto">
  <name>Install @langchain/openai for DeepSeek compatibility</name>
  <files>backend/package.json</files>
  <action>
    Run `npm install @langchain/openai` in the `backend/` directory. 
    LangChain's OpenAI client is fully compatible with DeepSeek's API. This enables us to use `ChatOpenAI` and override the baseURL to point to `https://api.deepseek.com/v1`.
  </action>
  <verify>cat backend/package.json | grep "@langchain/openai"</verify>
  <done>Dependancy added successfully.</done>
</task>

<task type="auto">
  <name>Create Physics Benchmark & System Prompt</name>
  <files>backend/src/agents/efficiency_plan/analyst.prompt.js</files>
  <action>
    Create `analyst.prompt.js` exporting a `SystemMessage` string.
    Include a hardcoded JSON dictionary inside the prompt representing the "Indian Domestic Physics Benchmark" (e.g., "1.5 Ton AC": { "avgWattage": 1500, "maxNormalDailyHours": 10 }, "Washing Machine": { "avgWattage": 500, "maxNormalDailyHours": 2 }).
    Instruct the LLM that its SOLE job is mathematical calculation based on `userData` and detecting values exceeding the Benchmark, and that it must return ONLY a raw JSON array of anomalies.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/analyst.prompt.js</verify>
  <done>Prompt file exported successfully without syntax errors.</done>
</task>

<task type="auto">
  <name>Implement DeepSeek-R1 Node Logic</name>
  <files>backend/src/agents/efficiency_plan/analyst.node.js</files>
  <action>
    Refactor `analyst.node.js` to instantiate a LangChain `ChatOpenAI` client pointing to the DeepSeek API base URL (with model `deepseek-chat` or `deepseek-reasoner`).
    In `runAnalyst`, pass the imported System Prompt and stringified `state.userData` to the model.
    Parse the LLM response strictly as JSON to an array of objects `{ id, item, description, rupeeCostImpact }` and return `{ anomalies: parsedJson }`.
    AVOID: using standard `JSON.parse` without try/catch; implement basic sanitization to strip markdown code blocks from the raw LLM response.
  </action>
  <verify>node -c backend/src/agents/efficiency_plan/analyst.node.js</verify>
  <done>The node properly structures the LLM call and exports `runAnalyst`.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `analyst.node.js` correctly maps `state.userData` directly into the LLM query.
- [ ] The prompt mandates a strict JSON return schema.
</verification>

<success_criteria>
- [ ] Tasks implemented securely with proper try/catch blocks.
- [ ] Must-haves confirmed.
</success_criteria>
