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
    })
});

module.exports = { StateAnnotation };
