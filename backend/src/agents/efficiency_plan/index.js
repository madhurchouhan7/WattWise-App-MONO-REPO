/**
 * WattWise Efficiency Plan LangGraph Definition
 * Compiles the Analyst, Strategist, and Copywriter nodes into a single workflow.
 */

const { StateGraph, START, END } = require("@langchain/langgraph");
const { StateAnnotation } = require("./state");
const { runAnalyst } = require("./analyst.node");
const { runStrategist } = require("./strategist.node");
const { runCopywriter } = require("./copywriter.node");

// 1. Initialize the graph with our state schema
const workflow = new StateGraph(StateAnnotation);

// 2. Add nodes
workflow.addNode("Analyst", runAnalyst);
workflow.addNode("Strategist", runStrategist);
workflow.addNode("Copywriter", runCopywriter);

// 3. Define structured edges to enforce the sequential assembly line
workflow.addEdge(START, "Analyst");
workflow.addEdge("Analyst", "Strategist");
workflow.addEdge("Strategist", "Copywriter");
workflow.addEdge("Copywriter", END);

// 4. Compile the application
const efficiencyPlanApp = workflow.compile();

module.exports = { efficiencyPlanApp };
