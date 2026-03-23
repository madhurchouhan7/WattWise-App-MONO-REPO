# ROADMAP.md

> **Current Phase**: Not started
> **Milestone**: v1.0 - Multi-Agent LangGraph Implementation

## Must-Haves (from SPEC)
- [ ] Working LangGraph sequential workflow (`START` -> `Analyst` -> `Strategist` -> `Copywriter` -> `END`).
- [ ] DeepSeek-R1 logic for tariff and anomaly detection.
- [ ] Grok-2 strategy generation with weather awareness.
- [ ] Gemini Flash final presentation layer.
- [ ] Robust Express controller for context injection.

## Phases

### Phase 1: Foundation & State Mapping
**Status**: ✅ Complete
**Objective**: Build the boilerplate for the LangGraph workflow and state object.
**Requirements**: TECH-01, TECH-04
- Set up `src/agents/efficiency_plan/` directory.
- Define the `State` object (input, analyst output, strategist output, final output).
- Core `index.js` for graph compilation.

### Phase 2: The Data Analyst (DeepSeek-R1)
**Status**: ✅ Complete
**Objective**: Implement the math-heavy anomaly detection node.
**Requirements**: REQ-02, REQ-07, TECH-03
- Develop `analyst.node.js`.
- Define the "Physics Benchmark" system prompt.
- Implement tariff calculation logic with DeepSeek-R1 integration.

### Phase 3: The Strategist (Grok-2)
**Status**: ✅ Complete
**Objective**: Develop the action-oriented strategy node.
**Requirements**: REQ-03, REQ-05, TECH-03
- Develop `strategist.node.js` for Grok-2.
- Integrate anomaly data and `weatherContext` relay.
- High-impact advice generation and rupee savings calculation.

### Phase 4: The Copywriter & Final Schema (Gemini Flash)
**Status**: ✅ Complete
**Objective**: Finalize the presentation and formatting layer for Flutter.
**Requirements**: REQ-04, REQ-06, TECH-03
- Develop `copywriter.node.js` for Gemini Flash.
- Summary, Monthly Tip, and strict JSON mapping.
- Integration test for Flutter-side parsing.

### Phase 5: Controller Integration & Deprecation
**Status**: ✅ Complete
**Objective**: Wire the new graph to the Express router and context helpers.
**Requirements**: REQ-05, TECH-02
- Update Express controller for MongoDB Tariff and OpenWeather API calls.
- Invoke the LangGraph `invoke` method.
- Deprecate `gemini.service.js`.
- Final end-to-end testing and deployment.

### Phase 6: Fix AI Plan Activation Routing
**Status**: âœ… Complete
**Goal**: plan_ready_screen.dart correctly pushes to active_plan_screen.dart instead of falling back to design_plan_screen.dart.
**Requirements**: REQ-06
**Plans**: 2 plans (2/2 complete)
- Backend returns full user on plan update.
- Frontend repository synchronizes cache and returns data.
- UI invalidates state and clears staging before navigation.
- Added direct navigation and loading guards to prevent UI flickering.

