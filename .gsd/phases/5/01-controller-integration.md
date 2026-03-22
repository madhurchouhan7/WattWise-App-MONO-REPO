---
phase: 5
plan: 1
wave: 1
depends_on: ["4.1"]
files_modified: ["backend/src/controllers/ai.controller.js", "backend/src/services/gemini.service.js"]
autonomous: true

must_haves:
  truths:
    - "AI Controller invokes LangGraph efficiencyPlanApp instead of monolithic Gemini service"
    - "Controller performs Weather API and DB Tariff queries and passes them as LangGraph State input"
    - "Legacy monolithic gemini.service.js is deprecated/deactivated"
  artifacts:
    - "backend/src/controllers/ai.controller.js"
---

# Plan 5.1: Controller Integration & Deprecation

<objective>
To wire the new LangGraph pipeline (`efficiencyPlanApp`) into the existing Express API route. We need to extract the OpenWeather API logic from the old Gemini service and place it in the controller (or a separate utility) so it can be passed purely into the LangGraph state. Finally, the old `gemini.service.js` must be deprecated.

Purpose: The ultimate goal is production readiness. By handling external APIs in the Node controller, our LangGraph nodes become completely deterministic, stateless, and extremely easy to scale/test.
Output: An updated `ai.controller.js` that successfully returns a plan from the new `efficiencyPlanApp`.
</objective>

<context>
Load for context:
- .gsd/SPEC.md
- backend/src/controllers/ai.controller.js
- backend/src/services/gemini.service.js
- backend/src/agents/efficiency_plan/index.js
</context>

<tasks>

<task type="auto">
  <name>Extract Weather Fetch Logic</name>
  <files>backend/src/controllers/ai.controller.js</files>
  <action>
    Extract the OpenWeatherMap fetch logic currently inside `gemini.service.js` and move it to `ai.controller.js` (or a utility function in the controller).
    Store the resulting weather string in a `weatherContext` variable.
  </action>
  <verify>grep "api.openweathermap.org" backend/src/controllers/ai.controller.js</verify>
  <done>Weather API fetching is now executed before invoking the AI logic.</done>
</task>

<task type="auto">
  <name>Invoke LangGraph Application</name>
  <files>backend/src/controllers/ai.controller.js</files>
  <action>
    Remove the `generateEfficiencyPlan` from `gemini.service.js` in the imports.
    Import `efficiencyPlanApp` from `../agents/efficiency_plan/index.js`.
    In `getEfficiencyPlan`, construct the initial state object: `{ userData: userData, weatherContext: weatherContext }`.
    Call `await efficiencyPlanApp.invoke(initialState)`.
    Extract `result.finalPlan` from the returned state.
    Return the plan to the user using the existing `sendSuccess` mechanism.
    Throw an error if `result.finalPlan` is null.
  </action>
  <verify>node -c backend/src/controllers/ai.controller.js</verify>
  <done>Controller successfully invokes the LangGraph instance and handles the response.</done>
</task>

<task type="auto">
  <name>Deprecate Legacy Service</name>
  <files>backend/src/services/gemini.service.js</files>
  <action>
    Rename the file to `gemini.service.js.legacy` or simply comment out the contents with a large deprecation warning explaining the move to `src/agents/efficiency_plan`.
  </action>
  <verify>cat backend/src/services/gemini.service.js | grep "DEPRECATED"</verify>
  <done>Old monolithic service is deactivated to prevent accidental use.</done>
</task>

</tasks>

<verification>
- [ ] Controller handles failed weather API requests gracefully (passing fallback string) so the LangGraph still executes.
- [ ] No syntax errors in modified files.
</verification>

<success_criteria>
- [ ] API Controller acts as the pure infrastructure boundary, passing only JSON to the LangGraph logic layer.
- [ ] Must-haves verified.
</success_criteria>
