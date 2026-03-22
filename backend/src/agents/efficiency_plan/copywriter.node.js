/**
 * Copywriter Node (Powered by Gemini Flash)
 * Purpose: Synthesizes data into the final JSON schema required by Flutter.
 */
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { getCopywriterPrompt } = require("./copywriter.prompt");

// Initialize LangChain Gemini Client
const llm = new ChatGoogleGenerativeAI({
    model: "gemini-2.5-flash", 
    apiKey: process.env.GEMINI_API_KEY || "dummy", 
    temperature: 0.4, // Slight variance for empathetic tone
});

async function runCopywriter(state) {
    console.log("--> [Node] Copywriter Executing");
    
    try {
        const systemMessage = getCopywriterPrompt();
        
        // Construct the prompt context
        const contextString = `
Current Weather Context: ${state.weatherContext || "Unknown"}
User Provided Data: ${JSON.stringify(state.userData || {}, null, 2)}
Anomalies Detected (Analyst): ${JSON.stringify(state.anomalies || [], null, 2)}
Strategies Generated (Strategist): ${JSON.stringify(state.strategies || [], null, 2)}
`;
        const userMessage = { 
            role: "user", 
            content: contextString
        };

        if (process.env.GEMINI_API_KEY) {
            const response = await llm.invoke([systemMessage, userMessage]);
            
            // Basic JSON extraction and sanitization
            let rawJsonStr = response.content;
            if (rawJsonStr.startsWith("```json")) {
                rawJsonStr = rawJsonStr.replace(/```json\n?/g, "").replace(/```\n?/g, "");
            } else if (rawJsonStr.startsWith("```")) {
                rawJsonStr = rawJsonStr.replace(/```\n?/g, "");
            }
            
            const parsedFinalPlan = JSON.parse(rawJsonStr.trim());
            console.log(`--> [Node] Copywriter completed successfully.`);
            
            return {
                finalPlan: parsedFinalPlan
            };
        } else {
             console.log("--> [Node] Copywriter using mock fallback (no GEMINI_API_KEY found).");
             return {
                 finalPlan: {
                     planType: "efficiency",
                     title: "Your Custom Energy Saving Plan",
                     status: "draft",
                     summary: "Hello! We noticed a few areas where you can save significantly on your energy bill this month.",
                     estimatedCurrentMonthlyCost: 2000,
                     estimatedSavingsIfFollowed: {
                        units: 50,
                        rupees: 450,
                        percentage: 22
                     },
                     efficiencyScore: 78,
                     keyActions: (state.strategies && state.strategies.length > 0 ? state.strategies : [{ actionSummary: "Follow this action", fullDescription: "Save money effortlessly", projectedSavings: 0 }]).map((s, i) => ({
                         priority: "high",
                         appliance: "Appliance",
                         action: s.actionSummary || "Follow this action",
                         impact: s.fullDescription || "Save money effortlessly",
                         estimatedSaving: s.projectedSavings?.toString() || "0"
                     })),
                     slabAlert: {
                        isInDangerZone: false,
                        warning: ""
                     },
                     quickWins: ["Turn off lights", "Use natural ventilation"],
                     monthlyTip: "Keep your AC filters clean for peak summer performance."
                 }
             };
        }

    } catch (error) {
        console.error("Copywriter Node Error:", error.message);
        // Fail gracefully
        return { finalPlan: null }; // Returning null so the Express controller knows it failed
    }
}

module.exports = { runCopywriter };
