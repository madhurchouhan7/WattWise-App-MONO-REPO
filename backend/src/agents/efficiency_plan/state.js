const { Annotation } = require("@langchain/langgraph");

/**
 * State Annotation for the WattWise Efficiency Plan Multi-Agent Workflow.
 * This defines the schema of the state object passed between nodes.
 */
const StateAnnotation = Annotation.Root({
    userData: Annotation({
        reducer: (curr, next) => next || curr,
        default: () => null
    }),
    weatherContext: Annotation({
        reducer: (curr, next) => next || curr,
        default: () => ""
    }),
    anomalies: Annotation({
        reducer: (curr, next) => next || curr,
        default: () => []
    }),
    strategies: Annotation({
        reducer: (curr, next) => next || curr,
        default: () => []
    }),
    finalPlan: Annotation({
        reducer: (curr, next) => next || curr,
        default: () => null
    }),
    memoryContext: Annotation({
        reducer: (_curr, next) => next || [],
        default: () => []
    }),
    memoryEventRefs: Annotation({
        reducer: (_curr, next) => next || [],
        default: () => []
    }),
    agentReflections: Annotation({
        reducer: (_curr, next) => next || [],
        default: () => []
    }),
    validationIssues: Annotation({
        reducer: (_curr, next) => next || [],
        default: () => []
    }),
    crossAgentChallenges: Annotation({
        reducer: (_curr, next) => next || [],
        default: () => []
    }),
    revisionCount: Annotation({
        reducer: (_curr, next) => Number.isFinite(next) ? next : 0,
        default: () => 0
    }),
    roleRetryBudgets: Annotation({
        reducer: (_curr, next) => next || {
            analyst: 0,
            strategist: 0,
            copywriter: 0,
            challengeRouting: 0,
        },
        default: () => ({
            analyst: 0,
            strategist: 0,
            copywriter: 0,
            challengeRouting: 0,
        })
    })
});

module.exports = { StateAnnotation };
