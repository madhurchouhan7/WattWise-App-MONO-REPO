/**
 * Copywriter Node (Powered by Gemini Flash)
 * Purpose: Synthesizes data into the final JSON schema required by Flutter.
 */

async function runCopywriter(state) {
    console.log("--> [Node] Copywriter Executing");
    
    // Placeholder logic: in the future this will call Gemini Flash
    // formatting state.strategies and state.anomalies into a cohesive presentation array
    
    return {
        finalPlan: {
            summary: "Mock empathetic summary",
            monthlyTip: "Mock seasonal tip",
            actions: state.strategies || []
        }
    };
}

module.exports = { runCopywriter };
